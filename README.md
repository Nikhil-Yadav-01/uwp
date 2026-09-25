# Universal Warehouse & Inventory Management System (WMS)
> **Omnichannel, Multi-Platform, Multi-Tenant Warehouse & Stock Management Suite for Any Business Vertical.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-00D2B8)](https://riverpod.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Web-blue)](#multi-platform-support)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-orange)](#architecture)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#)

---

## 🌟 Executive Summary

**Universal WMS** is an enterprise-grade, cross-platform stock and warehouse management solution designed to morph dynamically into any industry vertical without custom code changes. Whether managing raw materials like **Leather Hides & Textiles**, expiry-sensitive **Grocery & Cold-Chain Goods**, serial-tracked **Electronics & Mobile Gadgets**, batch-metered **Bars, Restaurants & Cafes**, or multi-variant **Retail & Fashion Apparel**, Universal WMS adapts its data schemas, unit conversions, and validation workflows seamlessly.

---

## 🚀 Key Capabilities & Highlights

* **Zero-Code Business Archetype Morphing:** Select your vertical during setup or per warehouse. Field names, metrics, and workflows reconfigure instantly.
* **Interactive 2D/3D Digital Twin Warehouse Map:** Design physical floorplans with drag-and-drop aisles, racks, bins, and staging zones with live heatmaps and pick-path visualization.
* **AI-Powered Multi-Barcode AR Batch Scanner:** Scan 5–10 barcodes concurrently using Google ML Kit / Camera AR with real-time pass/fail bounding boxes.
* **Voice-Directed Picking (VDP):** Hands-free warehouse operation with Bluetooth headset audio guidance and voice check-digit confirmation.
* **Native Industrial Hardware Bridge:** Built-in drivers for Zebra DataWedge & Honeywell Laser PDAs, ESC/POS, ZPL, and TSPL thermal printers, and Bluetooth/Serial weighing scales.
* **Granular Role-Based & Feature-Based Access Control (RBAC):** Fine-grained permission matrix spanning Super Admins, Warehouse Managers, Pickers, QC Inspectors, Auditors, POS Clerks, and B2B Clients.
* **Backend-Agnostic & Offline-First:** Fully functional without active network connectivity. Built with clean abstract repository contracts, ready to plug into Spring Boot, .NET, Go, Supabase, or custom REST/GraphQL backends.

---

## 📱 Multi-Platform Support

| Platform | Target Persona / Hardware | Key UX Features |
| :--- | :--- | :--- |
| **Desktop (Windows, macOS, Linux)** | Warehouse Directors, Inventory Managers, Procurement | Multi-window, keyboard shortcut navigation, high-density data tables, large-screen floorplan designer. |
| **Mobile (Android & iOS)** | Floor Pickers, Packers, Stock Auditors, Delivery Drivers | 1-handed thumb navigation, haptic feedback, camera AR scanner, offline caching. |
| **Rugged Industrial PDAs** | Forklift Operators, Staging Crew, Heavy-duty Logistics | Zebra DataWedge, Honeywell Mobility SDK, hardware laser trigger integration, ultra-high contrast dark UI. |
| **Web (Browsers)** | B2B Wholesale Clients, Remote Auditors, Management | Zero-install dashboard, shareable Live Packing & Tracking magic links. |

---

## 🧭 Project Documentation Map

* 📖 [**PROJECT_OVERVIEW.md**](./PROJECT_OVERVIEW.md) — Detailed domain requirements, archetype specifications, and end-to-end operational workflows.
* 🏛️ [**ARCHITECTURE.md**](./ARCHITECTURE.md) — Clean Architecture, Riverpod 2.x state management, data flow, dynamic schema engine, and hardware abstractions.
* 📏 [**RULES_AND_GUIDELINES.md**](./RULES_AND_GUIDELINES.md) — Code conventions, naming standards, error handling patterns (`Result<T>`), and UI design tokens.
* 🔐 [**RBAC_AND_PERMISSIONS.md**](./RBAC_AND_PERMISSIONS.md) — User roles, granular permission keys, and UI capability guard contracts.
* 🗺️ [**ROADMAP.md**](./ROADMAP.md) — Step-by-step milestone checklist for tracking development progress.

---

## 🛠️ Tech Stack

* **Framework:** Flutter 3.x (Multi-Platform)
* **Language:** Dart 3.x (Null safety, pattern matching, records)
* **State Management:** Riverpod 2.x with code generation (`flutter_riverpod`, `riverpod_annotation`)
* **Routing:** `go_router` (Type-safe routing, deep linking, auth guards)
* **Local Persistence:** In-Memory & Drift (Type-safe SQLite)
* **Vision & Hardware:** `mobile_scanner`, Google ML Kit, `flutter_thermal_printer`, Zebra DataWedge Intent Bridge

---

## 📦 Package Identity

* **Project Name:** `warehouse`
* **Organization:** `com.rudraksha`
* **Bundle / Package ID:** `com.rudraksha.warehouse`
