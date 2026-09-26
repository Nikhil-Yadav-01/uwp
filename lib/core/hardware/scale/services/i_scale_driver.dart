import '../models/weight_reading.dart';

abstract class IWeighingScaleDriver {
  Stream<WeightReading> get weightStream;

  Future<void> connect(String address);

  Future<void> disconnect();

  Future<void> tare();

  Future<void> zero();

  void simulateWeightChange(double targetGrossKg);
}
