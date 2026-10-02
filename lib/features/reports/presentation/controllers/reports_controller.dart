import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReportType {
  inventoryStock,
  purchaseInbound,
  salesOutbound,
  stockAgingAudit,
}

extension ReportTypeExtension on ReportType {
  String get label {
    switch (this) {
      case ReportType.inventoryStock:
        return 'Inventory Valuation & Stock';
      case ReportType.purchaseInbound:
        return 'Inbound Purchase & GRN';
      case ReportType.salesOutbound:
        return 'Outbound Sales & Dispatch';
      case ReportType.stockAgingAudit:
        return 'Stock Movement & Audit';
    }
  }
}

enum DateRangeFilter {
  today,
  thisWeek,
  thisMonth,
  thisQuarter,
  custom,
}

extension DateRangeFilterExtension on DateRangeFilter {
  String get label {
    switch (this) {
      case DateRangeFilter.today:
        return 'Today';
      case DateRangeFilter.thisWeek:
        return 'This Week';
      case DateRangeFilter.thisMonth:
        return 'This Month (Sep 2026)';
      case DateRangeFilter.thisQuarter:
        return 'Q3 2026';
      case DateRangeFilter.custom:
        return 'Custom Range';
    }
  }
}

class ReportsState {
  final ReportType selectedType;
  final DateRangeFilter dateRange;
  final String searchQuery;

  const ReportsState({
    this.selectedType = ReportType.inventoryStock,
    this.dateRange = DateRangeFilter.thisMonth,
    this.searchQuery = '',
  });

  ReportsState copyWith({
    ReportType? selectedType,
    DateRangeFilter? dateRange,
    String? searchQuery,
  }) {
    return ReportsState(
      selectedType: selectedType ?? this.selectedType,
      dateRange: dateRange ?? this.dateRange,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState());

  void setReportType(ReportType type) {
    state = state.copyWith(selectedType: type);
  }

  void setDateRange(DateRangeFilter range) {
    state = state.copyWith(dateRange: range);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }
}

final reportsNotifierProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier();
});
