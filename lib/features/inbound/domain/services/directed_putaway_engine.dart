import '../models/putaway_task.dart';
import '../models/purchase_order.dart';

/// Calculation engine that inspects product archetype and custom attributes
/// to suggest the optimal storage zone, aisle, rack, and bin location.
class DirectedPutawayEngine {
  const DirectedPutawayEngine();

  /// Determines optimal StorageZoneType based on archetype and item attributes.
  StorageZoneType resolveZoneType({
    required String archetypeId,
    required Map<String, dynamic> customAttributes,
  }) {
    switch (archetypeId) {
      case 'healthcare_pharma':
        final isNarcotic = customAttributes['isNarcotic'] == true ||
            (customAttributes['controlledSchedule'] != null &&
                customAttributes['controlledSchedule'] != 'None');
        if (isNarcotic) return StorageZoneType.narcoticsVault;

        final isColdChain = customAttributes['requiresColdChain'] == true ||
            customAttributes['storageTemp'] == 'Chilled (+2°C to +8°C)';
        if (isColdChain) return StorageZoneType.coldRoomChilled;

        final isCryo = customAttributes['storageTemp'] == 'Cryo (-20°C)';
        if (isCryo) return StorageZoneType.deepFrozen;

        return StorageZoneType.ambient;

      case 'grocery_foods':
        final temp = customAttributes['storageZone'] ?? customAttributes['storageTemp'];
        if (temp == 'Chilled (+4°C)' || temp == 'Cold Room (+2°C to +8°C)') {
          return StorageZoneType.coldRoomChilled;
        }
        if (temp == 'Deep Frozen (-18°C)') {
          return StorageZoneType.deepFrozen;
        }
        return StorageZoneType.bulkPalletRacks;

      case 'electronics_tech':
        return StorageZoneType.secureHighValueCage;

      case 'fashion_apparel':
        return StorageZoneType.hangingRacks;

      case 'leather_textiles':
        return StorageZoneType.rollRacks;

      case 'hardware_industrial':
        final isHazmat = customAttributes['isHazmat'] == true ||
            customAttributes['hazmatClass'] != null;
        if (isHazmat) return StorageZoneType.flammableHazmat;
        return StorageZoneType.bulkPalletRacks;

      case 'bars_hospitality':
        final isDraftKeg = customAttributes['isDraftKeg'] == true ||
            customAttributes['unit'] == 'keg';
        if (isDraftKeg) return StorageZoneType.coldRoomChilled;
        return StorageZoneType.ambient;

      default:
        return StorageZoneType.ambient;
    }
  }

  /// Generates a human-readable directed putaway coordinate string.
  String generateSuggestedBinLocation({
    required StorageZoneType zoneType,
    required String sku,
  }) {
    // Generate deterministic yet distinct aisle/rack/bin coordinates based on SKU hash
    final hash = sku.hashCode.abs();
    final aisle = (hash % 8 + 1).toString().padLeft(2, '0');
    final rack = (hash % 5 + 1).toString().padLeft(2, '0');
    final shelf = (hash % 4 + 1).toString().padLeft(2, '0');
    final bin = (hash % 12 + 1).toString().padLeft(2, '0');

    switch (zoneType) {
      case StorageZoneType.narcoticsVault:
        return 'Vault-N01 • Safe-$rack • Locker-$bin [Dual-Key Required]';
      case StorageZoneType.coldRoomChilled:
        return 'ColdZone-A • Chiller-$aisle • Shelf-$shelf • Bin-$bin (+4°C)';
      case StorageZoneType.deepFrozen:
        return 'Freezer-F02 • Bay-$aisle • Pallet-$rack (-18°C)';
      case StorageZoneType.secureHighValueCage:
        return 'SecurityCage-E • Aisle-$aisle • LockedBay-$shelf • Bin-$bin';
      case StorageZoneType.hangingRacks:
        return 'Mezzanine-M01 • Rail-$aisle • Section-$shelf • Tier-$bin';
      case StorageZoneType.rollRacks:
        return 'TextileBay-T • RollRack-$aisle • Tier-$shelf • Slot-$bin';
      case StorageZoneType.flammableHazmat:
        return 'HazmatCabinet-H03 • FireResistShelf-$rack • Bin-$bin';
      case StorageZoneType.bulkPalletRacks:
        return 'BulkFloor-B • Aisle-$aisle • Rack-$rack • Level-$shelf • Pos-$bin';
      case StorageZoneType.ambient:
        return 'MainFloor • Aisle-$aisle • Rack-$rack • Shelf-$shelf • Bin-$bin';
    }
  }

  /// Builds a complete PutawayTask for a received PurchaseOrderItem.
  PutawayTask createPutawayTask({
    required String poId,
    required String poNumber,
    required String archetypeId,
    required PurchaseOrderItem item,
  }) {
    final zoneType = resolveZoneType(
      archetypeId: archetypeId,
      customAttributes: item.customAttributes,
    );

    final suggestedLoc = generateSuggestedBinLocation(
      zoneType: zoneType,
      sku: item.sku,
    );

    return PutawayTask(
      id: 'PT-${DateTime.now().millisecondsSinceEpoch}-${item.sku}',
      poId: poId,
      poNumber: poNumber,
      productId: item.productId,
      productName: item.productName,
      sku: item.sku,
      quantity: item.receivedQty > 0 ? item.receivedQty : item.orderedQty,
      uom: item.uom,
      suggestedLocation: suggestedLoc,
      zoneType: zoneType,
      createdAt: DateTime.now(),
    );
  }
}
