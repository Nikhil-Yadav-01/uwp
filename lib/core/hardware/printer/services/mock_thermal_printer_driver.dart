import '../../../../core/errors/failures.dart';
import '../../../../core/network/result.dart';
import '../models/printer_device.dart';
import 'i_printer_driver.dart';
import 'zpl_template_generator.dart';

class MockThermalPrinterDriver implements IThermalPrinterDriver {
  final List<PrinterDevice> _devices = [
    const PrinterDevice(
      id: 'PRN-NET-01',
      name: 'Zebra ZT411 Industrial (Dock 01)',
      connectionType: PrinterConnectionType.networkTcp,
      address: '192.168.1.120',
      port: 9100,
      supportedLanguages: [PrinterLanguage.zpl],
      isConnected: true,
      dpi: 203,
    ),
    const PrinterDevice(
      id: 'PRN-BT-02',
      name: 'Zebra ZQ630 Mobile Belt Printer',
      connectionType: PrinterConnectionType.bluetoothSpp,
      address: 'AC:3F:A4:11:88:99',
      port: 0,
      supportedLanguages: [PrinterLanguage.zpl, PrinterLanguage.tspl],
      isConnected: false,
      dpi: 203,
    ),
    const PrinterDevice(
      id: 'PRN-POS-03',
      name: 'Epson TM-T88VI Receipt Printer',
      connectionType: PrinterConnectionType.usbCom,
      address: 'COM3',
      port: 0,
      supportedLanguages: [PrinterLanguage.escPos],
      isConnected: false,
      dpi: 203,
    ),
  ];

  PrinterDevice? _connectedDevice;
  final List<String> _printLog = [];
  final ZplTemplateGenerator _zplGen;

  MockThermalPrinterDriver({ZplTemplateGenerator? zplGen})
      : _zplGen = zplGen ?? const ZplTemplateGenerator() {
    _connectedDevice = _devices.first;
  }

  List<String> get printLog => List.unmodifiable(_printLog);
  PrinterDevice? get connectedDevice => _connectedDevice;

  @override
  Future<Result<List<PrinterDevice>>> discoverPrinters() async {
    return Result.success(List.from(_devices));
  }

  @override
  Future<Result<void>> connect(PrinterDevice device) async {
    _connectedDevice = device.copyWith(isConnected: true);
    return Result.success(null);
  }

  @override
  Future<Result<void>> disconnect() async {
    _connectedDevice = null;
    return Result.success(null);
  }

  @override
  Future<Result<void>> printRaw(String rawData, {PrinterLanguage language = PrinterLanguage.zpl}) async {
    if (_connectedDevice == null) {
      return Result.failure(
        const HardwareFailure('No thermal printer connected.', hardwareType: 'printer'),
      );
    }
    _printLog.insert(0, '[${DateTime.now().toIso8601String()}] (${language.name.toUpperCase()}) to ${_connectedDevice!.name}:\n$rawData');
    return Result.success(null);
  }

  @override
  Future<Result<void>> printTestLabel(PrinterDevice device) async {
    final zpl = _zplGen.generateBinLocationLabel(
      locationString: 'Zone A • Aisle 01 • Bin 01',
      zoneName: 'Main Warehouse',
      barcodeValue: 'BIN-ZA-A01-B01',
    );
    return printRaw(zpl, language: PrinterLanguage.zpl);
  }
}
