import '../../../../core/network/result.dart';
import '../models/printer_device.dart';

abstract class IThermalPrinterDriver {
  Future<Result<List<PrinterDevice>>> discoverPrinters();

  Future<Result<void>> connect(PrinterDevice device);

  Future<Result<void>> disconnect();

  Future<Result<void>> printRaw(String rawData, {PrinterLanguage language = PrinterLanguage.zpl});

  Future<Result<void>> printTestLabel(PrinterDevice device);
}
