// lib/features/orders/data/models/order_modification_models.dart

enum ItemReviewStatus { accepted, rejected }

enum ItemRejectionType { outOfStock, hasSubstitute }

enum CustomerResponseAction {
  keep,
  removeItem,
  acceptSubstitute,
  rejectSubstitute,
}

class SubOrderItemReviewRequest {
  final int subOrderItemId;
  final ItemReviewStatus status;
  final ItemRejectionType? rejectionType;
  final String? substituteName;

  SubOrderItemReviewRequest({
    required this.subOrderItemId,
    required this.status,
    this.rejectionType,
    this.substituteName,
  });

  Map<String, dynamic> toJson() {
    return {
      'suborderitem_id': subOrderItemId,
      'status': status.name,
      if (rejectionType != null)
        'rejection_type': rejectionType == ItemRejectionType.outOfStock
            ? 'out_of_stock'
            : 'has_substitute',
      if (substituteName != null) 'substitute_name': substituteName,
    };
  }
}

class RespondModificationRequest {
  final int subOrderItemId;
  final CustomerResponseAction response;

  RespondModificationRequest({
    required this.subOrderItemId,
    required this.response,
  });

  Map<String, dynamic> toJson() {
    String convertAction(CustomerResponseAction action) {
      switch (action) {
        case CustomerResponseAction.keep:
          return 'keep';
        case CustomerResponseAction.removeItem:
          return 'remove_item';
        case CustomerResponseAction.acceptSubstitute:
          return 'accept_substitute';
        case CustomerResponseAction.rejectSubstitute:
          return 'reject_substitute';
      }
    }

    return {
      'suborderitem_id': subOrderItemId,
      'customer_response': convertAction(response),
    };
  }
}

class SubOrderItemReview {
  final int id;
  final int subOrderItemId;
  final String status;
  final String? rejectionType;
  final String? substituteName;
  final String? customerResponse;

  SubOrderItemReview({
    required this.id,
    required this.subOrderItemId,
    required this.status,
    this.rejectionType,
    this.substituteName,
    this.customerResponse,
  });

  factory SubOrderItemReview.fromJson(Map<String, dynamic> json) {
    return SubOrderItemReview(
      id: json['id'],
      subOrderItemId: json['suborderitem_id'],
      status: json['status'],
      rejectionType: json['rejection_type'],
      substituteName: json['substitute_name'],
      customerResponse: json['customer_response'],
    );
  }
}
