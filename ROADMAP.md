# Master Development Roadmap & Progress Tracker

---

## 📊 Phase Overview

```mermaid
gantt
    title Universal WMS Development Roadmap
    dateFormat  YYYY-MM-DD
    section Phase 1
    Project & Archetype Foundation       :done,    p1, 2026-09-25, 3d
    section Phase 2
    Master Catalog & Dynamic Schema     :done,    p2, after p1, 4d
    section Phase 3
    Inbound, QC & Outbound Fulfillment  :active,  p3, after p2, 5d
    section Phase 4
    Hardware Bridge & Scanning Engine   :         p4, after p3, 4d
    section Phase 5
    2D Digital Twin & Advanced AI       :         p5, after p4, 5d
    section Phase 6
    Desktop Grid & Multi-Platform Launch:         p6, after p5, 4d
```

---

## 📌 Detailed Milestone Checklist

### ✅ Phase 1: Foundation, Architecture & Archetype Engine
- [x] Project Documentation Suite (`README`, `OVERVIEW`, `ARCHITECTURE`, `RULES`, `RBAC`, `ROADMAP`).
- [x] Initialize Flutter multi-platform workspace (`com.rudraksha.warehouse`).
- [x] Configure `pubspec.yaml` with Riverpod, GoRouter, Drift, ML Kit, Thermal Printer, Icons.
- [x] Implement Core Dynamic Archetype Schema Engine (Leather, Grocery, Electronics, Hospitality/Bars, Fashion, Hardware, Healthcare/Pharma).
- [x] Strategy-pattern dynamic theming engine with environmental ergonomic palettes (`IArchetypeThemeStrategy`).
- [x] Establish `Result<T>` functional error handling & AppFailure hierarchy.
- [x] Build Design System (Tokens, AppColors, AppTypography, ResponsiveBreakpoints).
- [x] Build Shell Navigation (Desktop Sidebar + Mobile Drawer) with GoRouter.
- [x] Live Dynamic 1-Click Showcase Demo Bar (`DemoArchetypeSwitcherBar`).

### ✅ Phase 2: Master Data, Product Catalog & Dynamic Schema
- [x] Abstract `IProductRepository`, `ICategoryRepository`, `IUomRepository`.
- [x] Universal `Product` entity with dynamic polymorphic `customAttributes` and validation rules.
- [x] Typed Wrapper/Decorator Pattern for compile-time safe vertical models (`LeatherProductWrapper`, `GroceryProductWrapper`, `ElectronicsProductWrapper`, `HospitalityProductWrapper`, `FashionProductWrapper`, `HardwareProductWrapper`, `HealthcareProductWrapper`).
- [x] Multi-Variant Matrix Generator ($\text{Size} \times \text{Color} \times \text{Material}$) with Cartesian SKU builder.
- [x] Recipe / Bill of Materials (BOM) composer engine with component cost rollup and stock bottleneck limits.
- [x] Unit of Measure (UOM) conversion calculation engine (Area, Weight, Volume, Length, Count & Packaging).
- [x] In-Memory / Drift pre-seeded repository with comprehensive demo catalog across all 7 archetypes.
- [x] 5-Tab dynamic Product Form (`ProductFormScreen`) and interactive Product Detail Modal with custom attribute chips.
- [x] Comprehensive test suite for all Phase 2 domain calculation engines & wrappers.

### 🔲 Phase 3: Inbound, QC & Outbound Fulfillment
- [ ] **Inbound:**
  - [ ] Purchase Order (PO) creation, tracking, and status pipeline.
  - [ ] Goods Receipt Note (GRN) scanning intake.
  - [ ] Quality Control (QC) inspection gate with photo capture.
  - [ ] Directed Putaway suggestion engine (Aisle $\rightarrow$ Rack $\rightarrow$ Shelf $\rightarrow$ Bin).
- [ ] **Outbound:**
  - [ ] Sales Order (SO) intake and validation.
  - [ ] Intelligent Picking Engine (Single, Wave, Batch, and Zone Picking).
  - [ ] Packing Station barcode verification scan.
  - [ ] Shipping label generator (ZPL / PDF preview) and packing manifest.

### 🔲 Phase 4: Hardware Bridge & Multi-Barcode Scanner
- [ ] Camera Multi-Barcode AR Batch Scanner (ML Kit) with bounding box overlays.
- [ ] Zebra DataWedge & Honeywell Android Broadcast Receiver bridge for laser PDAs.
- [ ] Bluetooth & Network Thermal Printer Engine (ESC/POS, ZPL, TSPL label formats).
- [ ] BLE & Serial COM Scale Driver for auto-capturing scrap/roll/freight weight.

### 🔲 Phase 5: Digital Twin Floorplan, Voice Picking & Advanced Innovations
- [ ] Interactive 2D Warehouse Floorplan Canvas (draw walls, aisles, racks, loading docks).
- [ ] Live Stock Density Heatmap visualizer.
- [ ] Shortest Walking Path A* / Dijkstra route visualizer for pickers.
- [ ] Voice-Directed Picking (VDP) assistant with TTS and Speech-to-Text confirmation digits.
- [ ] Expiry countdown & dynamic markdown suggestion algorithm.
- [ ] B2B Client "Live Packing & Tracking" Magic Link web preview.

### 🔲 Phase 6: Desktop Grid Optimization, Role-Based Access & Launch
- [ ] High-density editable Data Grid with multi-column sorting, filtering, and grouping.
- [ ] Full Role-Based Permission Matrix integration with `<CapabilityGuard>` across all screens.
- [ ] Multi-window and keyboard shortcut navigation for Desktop (Windows, macOS, Linux).
- [ ] Data Export / Import Engine (Excel, CSV, JSON, PDF reports).
- [ ] Comprehensive unit, widget, and golden test suite.
