import 'dart:async';
import '../models/weight_reading.dart';
import 'i_scale_driver.dart';

class MockWeighingScaleDriver implements IWeighingScaleDriver {
  final _controller = StreamController<WeightReading>.broadcast();
  double _grossKg = 2.450;
  double _tareKg = 0.0;
  bool _isConnected = true;

  MockWeighingScaleDriver() {
    // Emit initial reading
    _emitReading();
  }

  @override
  Stream<WeightReading> get weightStream => _controller.stream;

  bool get isConnected => _isConnected;
  double get currentGrossKg => _grossKg;
  double get currentTareKg => _tareKg;
  double get currentNetKg => (_grossKg - _tareKg).clamp(0.0, double.infinity);

  void _emitReading() {
    final net = (_grossKg - _tareKg).clamp(0.0, double.infinity);
    _controller.add(
      WeightReading(
        grossWeight: _grossKg,
        tareWeight: _tareKg,
        netWeight: net,
        unit: WeightUnit.kg,
        isStable: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> connect(String address) async {
    _isConnected = true;
    _emitReading();
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
  }

  @override
  Future<void> tare() async {
    _tareKg = _grossKg;
    _emitReading();
  }

  @override
  Future<void> zero() async {
    _grossKg = 0.0;
    _tareKg = 0.0;
    _emitReading();
  }

  @override
  void simulateWeightChange(double targetGrossKg) {
    _grossKg = targetGrossKg;
    _emitReading();
  }

  void dispose() {
    _controller.close();
  }
}
