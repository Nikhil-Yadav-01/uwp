# Role-Based & Feature-Based Access Control (RBAC) Specification

---

## 1. Overview

Universal WMS employs a dual-tiered authorization model:
1. **Role Profiles:** High-level personas assigned to staff members.
2. **Granular Feature Permission Keys:** Low-level action flags that can be customized per user or role.

---

## 2. Predefined User Roles

```
┌─────────────────────────┐
│     Super Admin         │ ── Full Access to Organizations, Finances, Configuration
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│   Warehouse Manager     │ ── Approvals, Wave Dispatch, Staff Assignment, Master Data
└───────────┬─────────────┘
            ├──────────────────────────┬──────────────────────────┐
            ▼                          ▼                          ▼
┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
│ Floor Picker / Packer │  │     QC Inspector      │  │   Inventory Auditor   │
│ • Picklists & Waves   │  │ • Pass/Fail Gateways  │  │ • Blind/Scan Audits   │
│ • Pack Station Scan   │  │ • Damage Photo Logs   │  │ • Discrepancy Logs    │
└───────────────────────┘  └───────────────────────┘  └───────────────────────┘
            │
            ├──────────────────────────┬──────────────────────────┐
            ▼                          ▼                          ▼
┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
│ Cashier / POS Clerk   │  │  Procurement Officer  │  │  B2B Client / Vendor  │
│ • Counter Sales       │  │ • Create POs          │  │ • View Assigned PO/SO │
│ • Receipt Print       │  │ • Vendor Catalogues   │  │ • Live Order Tracking │
└───────────────────────┘  └───────────────────────┘  └───────────────────────┘
```

---

## 3. Granular Permission Key Catalog

### Category: Master Data & Catalog (`perm:catalog:*`)
* `perm:catalog:view` — View products, categories, variants, and recipes.
* `perm:catalog:create` — Create new products, units of measure, and BOMs.
* `perm:catalog:edit` — Edit existing product details, pricing, and barcodes.
* `perm:catalog:delete` — Archive or delete products from the catalog.
* `perm:catalog:view_cost` — View supplier cost prices and margin calculations.

### Category: Inbound Operations (`perm:inbound:*`)
* `perm:inbound:po_create` — Create and submit Purchase Orders.
* `perm:inbound:po_approve` — Approve Purchase Orders above threshold amounts.
* `perm:inbound:receive` — Scan and receive incoming shipments at the dock.
* `perm:inbound:qc_inspect` — Perform quality control inspections and log defect photos.
* `perm:inbound:putaway` — Confirm putaway of stock to designated shelf/bin locations.

### Category: Outbound & Fulfillment (`perm:outbound:*`)
* `perm:outbound:so_create` — Create Sales Orders / Customer Invoices.
* `perm:outbound:wave_dispatch` — Create and dispatch wave and batch picklists.
* `perm:outbound:pick` — Execute item picking tasks on the floor.
* `perm:outbound:pack` — Verify and seal packages at the packing station.
* `perm:outbound:ship` — Generate shipping labels and mark orders as dispatched.

### Category: Inventory & Stock Control (`perm:inventory:*`)
* `perm:inventory:view_stock` — View live stock levels and bin locations.
* `perm:inventory:transfer` — Initiate stock transfers between warehouses or zones.
* `perm:inventory:adjust` — Perform stock quantity and scrap adjustments.
* `perm:inventory:audit_count` — Conduct cycle counts and physical inventory audits.
* `perm:inventory:approve_adjustment` — Approve stock write-offs and shrinkage claims.

### Category: POS & Billing (`perm:pos:*`)
* `perm:pos:checkout` — Process point-of-sale transactions and print receipts.
* `perm:pos:apply_discount` — Apply custom item or cart-level discounts.
* `perm:pos:refund` — Process customer refunds and return stock.

### Category: Regulated & Healthcare Compliance (`perm:compliance:*`)
* `perm:compliance:narcotics_vault_access` — Unlock and manage high-security narcotics and Schedule II–V drug storage.
* `perm:compliance:dual_signoff_witness` — Act as secondary authorized witness for controlled substance dispensing & disposal.
* `perm:compliance:quarantine_override` — Place or release lots from QC / Expiry / Recall quarantine holds.
* `perm:compliance:ward_allocation` — Allocate sub-stock to hospital wards, crash carts, and emergency departments.

### Category: Administration & Settings (`perm:admin:*`)
* `perm:admin:manage_users` — Create, edit, and assign roles to users.
* `perm:admin:manage_roles` — Customize granular permission sets for roles.
* `perm:admin:warehouse_layout` — Design and edit the 2D digital twin floorplan.
* `perm:admin:hardware_config` — Configure scanners, printers, and scale parameters.
* `perm:admin:system_settings` — Select active business archetype and global settings.

---

## 4. Role vs. Permission Matrix

| Permission Key | Super Admin | Warehouse Mgr | Picker / Packer | QC Inspector | Auditor | POS Clerk | Pharmacist / Nurse | B2B Client |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `perm:catalog:view` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ (Catalog Only) |
| `perm:catalog:edit` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `perm:catalog:view_cost` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `perm:inbound:receive` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `perm:inbound:qc_inspect`| ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ |
| `perm:inbound:putaway` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `perm:outbound:pick` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `perm:outbound:pack` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `perm:inventory:adjust` | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| `perm:inventory:audit` | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ |
| `perm:compliance:vault` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `perm:compliance:dual_signoff` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `perm:pos:checkout` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| `perm:admin:system` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 5. UI Capability Guard Implementation Contract

```dart
class CapabilityGuard extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget fallback;

  const CapabilityGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPermissions = ref.watch(currentUserPermissionsProvider);
    final hasPermission = userPermissions.contains(permission) ||
                          userPermissions.contains('perm:admin:*');

    return hasPermission ? child : fallback;
  }
}
```
