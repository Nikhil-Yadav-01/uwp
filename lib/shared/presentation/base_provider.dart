import 'package:flutter/material.dart';

enum ViewState { idle, loading, success, error, empty }

/// Base Controller class handling ViewState and automated safe async execution
abstract class BaseProvider extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;
  bool get isSuccess => _state == ViewState.success;

  void setViewState(ViewState state, [String? errorMessage]) {
    _state = state;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  /// Automatically wraps async tasks with loading and exception handling
  Future<T?> executeSafely<T>(Future<T> Function() asyncTask) async {
    try {
      setViewState(ViewState.loading);
      final result = await asyncTask();
      setViewState(ViewState.success);
      return result;
    } catch (e) {
      setViewState(ViewState.error, e.toString());
      return null;
    }
  }
}
