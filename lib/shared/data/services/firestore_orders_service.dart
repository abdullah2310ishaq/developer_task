import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/constants/firestore_paths.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/enums/payment_types.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/core/models/cart_item.dart';

class InsufficientStockException implements Exception {
  InsufficientStockException(this.productName, {this.available = 0});

  final String productName;
  final int available;

  @override
  String toString() => available > 0
      ? 'Only $available of $productName left in stock'
      : '$productName is out of stock';
}

class FirestoreOrdersService {
  FirestoreOrdersService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestorePaths.orders);

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirestorePaths.products);

  Stream<List<AppOrder>> watchAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AppOrder.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<AppOrder>> watchActiveOrders() {
    return watchAllOrders().map(
      (list) => list.where((order) => order.status is! OrderDelivered).toList(),
    );
  }

  Stream<List<AppOrder>> watchUserOrders(String userId) {
    return _orders.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => AppOrder.fromMap(doc.id, doc.data()))
          .toList();
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
      return list;
    });
  }

  Stream<AppOrder?> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppOrder.fromMap(doc.id, doc.data()!);
    });
  }

  Future<AppOrder?> fetchOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppOrder.fromMap(doc.id, doc.data()!);
  }

  Future<void> validateCartStock(List<CartItem> items) async {
    for (final item in items) {
      final snap = await _products.doc(item.productId).get();
      if (!snap.exists || snap.data() == null) {
        throw InsufficientStockException(item.name);
      }
      final data = snap.data()!;
      final isActive = data['isActive'] as bool? ?? true;
      final stock = (data['stock'] as num?)?.toInt() ?? 0;
      if (!isActive || stock < item.quantity) {
        throw InsufficientStockException(item.name, available: stock);
      }
    }
  }

  Future<String> createOrder({
    required String userId,
    required String customerName,
    required String phone,
    required String address,
    required List<CartItem> items,
    required double total,
    required PaymentMethod paymentMethod,
    required PaymentRecordStatus paymentStatus,
  }) {
    return _firestore.runTransaction((transaction) async {
      final productRefs = <DocumentReference<Map<String, dynamic>>>[];
      final productSnaps = <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final item in items) {
        final ref = _products.doc(item.productId);
        productRefs.add(ref);
        productSnaps.add(await transaction.get(ref));
      }

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final snap = productSnaps[i];
        if (!snap.exists || snap.data() == null) {
          throw InsufficientStockException(item.name);
        }
        final data = snap.data()!;
        final isActive = data['isActive'] as bool? ?? true;
        final stock = (data['stock'] as num?)?.toInt() ?? 0;
        if (!isActive || stock < item.quantity) {
          throw InsufficientStockException(item.name, available: stock);
        }
      }

      for (var i = 0; i < items.length; i++) {
        transaction.update(productRefs[i], {
          'stock': FieldValue.increment(-items[i].quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final orderRef = _orders.doc();
      transaction.set(orderRef, {
        'userId': userId,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'items': items
            .map(
              (item) => {
                'productId': item.productId,
                'name': item.name,
                'price': item.price,
                'qty': item.quantity,
              },
            )
            .toList(),
        'total': total,
        'currency': 'PKR',
        'status': const OrderPending().firestoreValue,
        'paymentMethod': paymentMethod.firestoreValue,
        'paymentStatus': paymentStatus.firestoreValue,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return orderRef.id;
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderTrackingStatus status) {
    return _orders.doc(orderId).update({
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> dispatchOrder({
    required String orderId,
    required String riderName,
    required String riderPhone,
  }) {
    return _orders.doc(orderId).update({
      'status': const OrderOutForDelivery().firestoreValue,
      'riderName': riderName.trim(),
      'riderPhone': riderPhone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmDelivered(String orderId) {
    return updateOrderStatus(orderId, const OrderDelivered());
  }
}
