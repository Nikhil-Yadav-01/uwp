import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/inventory/domain/models/inventory_transaction.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';

enum PaymentMethod {
  cash,
  creditCard,
  upiQr,
  storeAccount,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Card (Chip / Contactless)';
      case PaymentMethod.upiQr:
        return 'UPI / Instant QR';
      case PaymentMethod.storeAccount:
        return 'B2B Account Credit';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.creditCard:
        return Icons.credit_card_outlined;
      case PaymentMethod.upiQr:
        return Icons.qr_code_2_outlined;
      case PaymentMethod.storeAccount:
        return Icons.account_balance_outlined;
    }
  }
}

class PosCartItem {
  final String productId;
  final String productName;
  final String sku;
  final double unitPrice;
  final int quantity;
  final double discountPercent;
  final String uom;

  const PosCartItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unitPrice,
    required this.quantity,
    this.discountPercent = 0.0,
    required this.uom,
  });

  double get lineTotal => (unitPrice * quantity) * (1 - (discountPercent / 100));

  PosCartItem copyWith({
    String? productId,
    String? productName,
    String? sku,
    double? unitPrice,
    int? quantity,
    double? discountPercent,
    String? uom,
  }) {
    return PosCartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
      uom: uom ?? this.uom,
    );
  }
}

class PosSaleReceipt {
  final String receiptNumber;
  final List<PosCartItem> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final DateTime timestamp;
  final String cashierName;

  const PosSaleReceipt({
    required this.receiptNumber,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.timestamp,
    required this.cashierName,
  });
}

class PosCartState {
  final List<PosCartItem> items;
  final double discountPercent;
  final double taxRate; // 5% by default
  final bool isProcessing;
  final PosSaleReceipt? lastReceipt;

  const PosCartState({
    this.items = const [],
    this.discountPercent = 0.0,
    this.taxRate = 0.05,
    this.isProcessing = false,
    this.lastReceipt,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get cartDiscountAmount => subtotal * (discountPercent / 100);
  double get taxableAmount => subtotal - cartDiscountAmount;
  double get taxAmount => taxableAmount * taxRate;
  double get grandTotal => taxableAmount + taxAmount;
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  PosCartState copyWith({
    List<PosCartItem>? items,
    double? discountPercent,
    double? taxRate,
    bool? isProcessing,
    PosSaleReceipt? lastReceipt,
    bool clearReceipt = false,
  }) {
    return PosCartState(
      items: items ?? this.items,
      discountPercent: discountPercent ?? this.discountPercent,
      taxRate: taxRate ?? this.taxRate,
      isProcessing: isProcessing ?? this.isProcessing,
      lastReceipt: clearReceipt ? null : (lastReceipt ?? this.lastReceipt),
    );
  }
}

class PosCartNotifier extends StateNotifier<PosCartState> {
  final Ref _ref;

  PosCartNotifier(this._ref) : super(const PosCartState());

  void addItem(Map<String, dynamic> product) {
    final id = product['id'] as String? ?? 'PROD-${Random().nextInt(9999)}';
    final name = product['name'] as String? ?? 'Product';
    final sku = product['sku'] as String? ?? 'SKU-${Random().nextInt(999)}';
    final price = (product['unitPrice'] as num?)?.toDouble() ?? 10.0;
    final uom = product['uom'] as String? ?? 'unit';

    final existingIndex = state.items.indexWhere((i) => i.productId == id);
    if (existingIndex != -1) {
      final updatedList = List<PosCartItem>.from(state.items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          PosCartItem(
            productId: id,
            productName: name,
            sku: sku,
            unitPrice: price,
            quantity: 1,
            uom: uom,
          ),
        ],
      );
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    final updatedList = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedList);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void clearCart() {
    state = state.copyWith(items: [], discountPercent: 0.0);
  }

  Future<PosSaleReceipt> checkout(PaymentMethod method, {String cashierName = 'Store Lead (Counter #01)'}) async {
    state = state.copyWith(isProcessing: true);

    await Future.delayed(const Duration(milliseconds: 600));

    final receipt = PosSaleReceipt(
      receiptNumber: 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(state.items),
      subtotal: state.subtotal,
      taxAmount: state.taxAmount,
      totalAmount: state.grandTotal,
      paymentMethod: method,
      timestamp: DateTime.now(),
      cashierName: cashierName,
    );

    // Record Stock Ledger deduction for sold items
    final ledgerRepo = _ref.read(inventoryLedgerRepositoryProvider);
    for (final item in state.items) {
      ledgerRepo.recordTransaction(
        InventoryTransaction(
          transactionId: 'TX-${Random().nextInt(90000) + 10000}',
          productId: item.productId,
          productName: item.productName,
          sku: item.sku,
          warehouseId: 'WH01',
          warehouseName: 'Central Distribution Hub #01',
          locationId: 'BIN-COUNTER-01',
          transactionType: InventoryTransactionType.sale,
          quantity: item.quantity.toDouble(),
          uom: item.uom,
          balanceAfter: 50.0,
          referenceType: 'POS',
          referenceId: receipt.receiptNumber,
          notes: 'POS Counter Sale to walk-in customer (${method.displayName})',
          createdBy: cashierName,
          createdAt: DateTime.now(),
        ),
      );
    }

    _ref.read(inventoryLedgerProvider.notifier).refresh();

    state = PosCartState(lastReceipt: receipt);
    return receipt;
  }
}

final posCartProvider = StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  return PosCartNotifier(ref);
});
