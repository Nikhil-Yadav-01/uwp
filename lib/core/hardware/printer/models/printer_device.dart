import 'package:flutter/foundation.dart';

enum PrinterConnectionType {
  networkTcp,
  bluetoothSpp,
  usbCom,
  virtualSimulator,
}

enum PrinterLanguage {
  zpl,   // Zebra Programming Language (ZPL-II)
  tspl,  // TSC Printer Language
  escPos // Epson ESC/POS (Standard POS Receipt)
}

@immutable
class PrinterDevice {
  final String id;
  final String name;
  final PrinterConnectionType connectionType;
  final String address; // IP Address, Bluetooth MAC, or COM port
  final int port;       // Default 9100 for raw TCP thermal print
  final List<PrinterLanguage> supportedLanguages;
  final bool isConnected;
  final int dpi;        // 203 DPI or 300 DPI

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.connectionType,
    required this.address,
    this.port = 9100,
    this.supportedLanguages = const [PrinterLanguage.zpl, PrinterLanguage.escPos],
    this.isConnected = false,
    this.dpi = 203,
  });

  PrinterDevice copyWith({
    String? id,
    String? name,
    PrinterConnectionType? connectionType,
    String? address,
    int? port,
    List<PrinterLanguage>? supportedLanguages,
    bool? isConnected,
    int? dpi,
  }) {
    return PrinterDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      connectionType: connectionType ?? this.connectionType,
      address: address ?? this.address,
      port: port ?? this.port,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      isConnected: isConnected ?? this.isConnected,
      dpi: dpi ?? this.dpi,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connectionType': connectionType.name,
        'address': address,
        'port': port,
        'supportedLanguages': supportedLanguages.map((l) => l.name).toList(),
        'isConnected': isConnected,
        'dpi': dpi,
      };

  factory PrinterDevice.fromJson(Map<String, dynamic> json) => PrinterDevice(
        id: json['id'] as String,
        name: json['name'] as String,
        connectionType: PrinterConnectionType.values.firstWhere(
          (e) => e.name == json['connectionType'],
          orElse: () => PrinterConnectionType.virtualSimulator,
        ),
        address: json['address'] as String,
        port: json['port'] as int? ?? 9100,
        supportedLanguages: (json['supportedLanguages'] as List? ?? [])
            .map((l) => PrinterLanguage.values.firstWhere((e) => e.name == l, orElse: () => PrinterLanguage.zpl))
            .toList(),
        isConnected: json['isConnected'] as bool? ?? false,
        dpi: json['dpi'] as int? ?? 203,
      );
}
