import '../../../../core/network/result.dart';
import '../models/sales_order.dart';
import '../models/picking_wave.dart';
import '../models/packing_session.dart';

abstract class IOutboundRepository {
  Future<Result<List<SalesOrder>>> getSalesOrders({
    OutboundStatus? status,
    String? archetypeId,
  });

  Future<Result<SalesOrder>> getSalesOrderById(String id);

  Future<Result<SalesOrder>> createSalesOrder(SalesOrder order);

  Future<Result<SalesOrder>> updateSalesOrderStatus(
    String orderId,
    OutboundStatus newStatus,
  );

  Future<Result<PickingWave>> generatePickingWave({
    required List<String> orderIds,
    String? assignedPickerName,
    String? zone,
  });

  Future<Result<List<PickingWave>>> getActiveWaves();

  Future<Result<PickingWave>> confirmPickTask({
    required String waveId,
    required String taskId,
    required double quantityPicked,
  });

  Future<Result<PackingSession>> startPackingSession(String orderId);

  Future<Result<PackingSession>> verifyScanItem({
    required String sessionId,
    required String scannedBarcode,
  });

  Future<Result<PackingSession>> completePackingAndShip({
    required String sessionId,
    required double totalWeightKg,
    required String carrier,
    required int boxCount,
  });
}
