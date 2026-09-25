/// Core failure models representing domain and infrastructure errors.
abstract class AppFailure {
  final String message;
  final String? code;
  final dynamic details;

  const AppFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'AppFailure(code: $code, message: $message)';
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {super.code, super.details});
}

class CacheFailure extends AppFailure {
  const CacheFailure(super.message, {super.code, super.details});
}

class ValidationFailure extends AppFailure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors, super.code, super.details});
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([super.message = 'Unauthorized access'])
      : super(code: 'UNAUTHORIZED');
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, {super.code});
}

class HardwareFailure extends AppFailure {
  final String hardwareType; // 'scanner', 'printer', 'scale'
  const HardwareFailure(super.message, {required this.hardwareType, super.code});
}
