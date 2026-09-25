import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'loading_indicator.dart';

class StateBuilder extends StatelessWidget {
  final ViewState state;
  final Widget Function(BuildContext context) builder;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyMessage;

  const StateBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage = 'No data available.',
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return const LoadingIndicator();
      case ViewState.error:
        return ErrorView(
          message: errorMessage ?? 'An unexpected error occurred.',
          onRetry: onRetry,
        );
      case ViewState.empty:
        return EmptyView(message: emptyMessage);
      case ViewState.idle:
      case ViewState.success:
        return builder(context);
    }
  }
}
