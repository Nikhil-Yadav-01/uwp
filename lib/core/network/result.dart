import '../errors/failures.dart';

/// A functional Result type to encapsulate success and failure without throwing raw exceptions.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppFailure failure) = FailureResult<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  });

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  AppFailure? get failureOrNull => isFailure ? (this as FailureResult<T>).failure : null;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    return onSuccess(data);
  }
}

class FailureResult<T> extends Result<T> {
  final AppFailure failure;
  const FailureResult(this.failure);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    return onFailure(failure);
  }
}
