import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/order_line_item.dart';

class AppOrder {
  const AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.customerName,
    this.phone,
    this.address,
    this.riderName,
    this.riderPhone,
    this.createdAt,
  });

  final String id;
  final String userId;
  final List<OrderLineItem> items;
  final double total;
  final OrderTrackingStatus status;
  final String paymentMethod;
  final String paymentStatus;
  final String? customerName;
  final String? phone;
  final String? address;
  final String? riderName;
  final String? riderPhone;
  final DateTime? createdAt;

  factory AppOrder.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return AppOrder(
      id: id,
      userId: map['userId'] as String? ?? '',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderLineItem.fromMap)
          .toList(),
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: OrderTrackingStatus.fromFirestore(map['status'] as String?),
      paymentMethod: map['paymentMethod'] as String? ?? 'cod',
      paymentStatus: map['paymentStatus'] as String? ?? 'pending',
      customerName: map['customerName'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      riderName: map['riderName'] as String?,
      riderPhone: map['riderPhone'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  String get itemsSummary {
    if (items.isEmpty) return 'No items';
    final visible = items.take(3).map((item) => '${item.name} ×${item.quantity}');
    final text = visible.join(', ');
    if (items.length > 3) return '$text +${items.length - 3} more';
    return text;
  }
}
