
sealed class OrderTrackingStatus {
  const OrderTrackingStatus();

 
  String get firestoreValue {
    switch (this) {
      case OrderPending():
        return 'pending';
      case OrderPreparing():
        return 'preparing';
      case OrderOutForDelivery():
        return 'out_for_delivery';
      case OrderDelivered():
        return 'delivered';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderPending():
        return 0;
      case OrderPreparing():
        return 1;
      case OrderOutForDelivery():
        return 2;
      case OrderDelivered():
        return 3;
    }
  }

  String get label {
    switch (this) {
      case OrderPending():
        return 'Order placed';
      case OrderPreparing():
        return 'Preparing';
      case OrderOutForDelivery():
        return 'Out for delivery';
      case OrderDelivered():
        return 'Delivered';
    }
  }

  static OrderTrackingStatus fromFirestore(String? raw) {
    switch (raw) {
      case 'preparing':
        return const OrderPreparing();
      case 'out_for_delivery':
        return const OrderOutForDelivery();
      case 'delivered':
        return const OrderDelivered();
      default:
        return const OrderPending();
    }
  }

  static const List<OrderTrackingStatus> timeline = [
    OrderPending(),
    OrderPreparing(),
    OrderOutForDelivery(),
    OrderDelivered(),
  ];

  bool isAtOrPast(OrderTrackingStatus other) {
    if (stepIndex >= other.stepIndex) {
      return true;
    } else {
      return false;
    }
  }
}

class OrderPending extends OrderTrackingStatus {
  const OrderPending();
}

class OrderPreparing extends OrderTrackingStatus {
  const OrderPreparing();
}

class OrderOutForDelivery extends OrderTrackingStatus {
  const OrderOutForDelivery();
}

class OrderDelivered extends OrderTrackingStatus {
  const OrderDelivered();
}
