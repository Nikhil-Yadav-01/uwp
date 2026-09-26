/// High-precision calculation engine for piece-counting by weight,
/// leather remnant area derivation, and freight tolerance verification.
class PieceCounterCalculator {
  const PieceCounterCalculator();

  /// Calculates number of fastener pieces based on net weight and unit piece weight.
  /// Example: 2.5 kg of M8 bolts with 0.005 kg/bolt unit weight = 500 bolts.
  int calculatePieceCount({
    required double netWeightKg,
    required double unitWeightKg,
  }) {
    if (unitWeightKg <= 0 || netWeightKg <= 0) return 0;
    return (netWeightKg / unitWeightKg).round();
  }

  /// Calculates leather surface area in sq ft from hide scrap/roll weight.
  /// Average bovine leather density is approx 0.12 kg per sq. ft. (varies by thickness).
  double calculateLeatherAreaFromWeight({
    required double weightKg,
    double densityKgPerSqFt = 0.12,
  }) {
    if (weightKg <= 0 || densityKgPerSqFt <= 0) return 0.0;
    return weightKg / densityKgPerSqFt;
  }

  /// Verifies if actual weight on scale matches expected calculated weight
  /// within an allowable percentage tolerance (e.g., 5%).
  bool verifyFreightWeight({
    required double actualWeightKg,
    required double expectedWeightKg,
    double tolerancePercent = 5.0,
  }) {
    if (expectedWeightKg <= 0) return true;
    final diffPercent = ((actualWeightKg - expectedWeightKg).abs() / expectedWeightKg) * 100.0;
    return diffPercent <= tolerancePercent;
  }
}
