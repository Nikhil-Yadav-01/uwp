import '../../../../core/network/result.dart';
import '../models/purchase_order.dart';
import '../models/qc_inspection.dart';
import '../models/putaway_task.dart';

abstract class IInboundRepository {
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    InboundStatus? status,
    String? archetypeId,
  });

  Future<Result<PurchaseOrder>> getPurchaseOrderById(String id);

  Future<Result<PurchaseOrder>> createPurchaseOrder(PurchaseOrder po);

  Future<Result<PurchaseOrder>> updatePurchaseOrderStatus(
    String poId,
    InboundStatus newStatus,
  );

  Future<Result<PurchaseOrder>> receiveGoods({
    required String poId,
    required List<PurchaseOrderItem> receivedItems,
    String? receivingDockId,
  });

  Future<Result<QcInspectionReport>> submitQcInspection(QcInspectionReport report);

  Future<Result<List<QcInspectionReport>>> getQcReports({String? poId});

  Future<Result<List<PutawayTask>>> getPutawayTasks({
    String? poId,
    PutawayStatus? status,
  });

  Future<Result<PutawayTask>> confirmPutaway({
    required String taskId,
    required String confirmedLocation,
    String? operatorName,
  });
}
