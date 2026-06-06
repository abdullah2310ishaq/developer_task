// Sealed class jo baqi sab classes ko handle karegi
sealed class OrderTrackingStatus {
  const OrderTrackingStatus();

  // 1. Database value ke liye switch statement
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

  // 2. Stepper UI ke liye index number ka switch
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

  // 3. Screen par dikhane ke liye text label ka switch
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

  // 4. Firestore ke text ko class object mein badalne ka function
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

  // 5. Saare status ki ek timeline list
  static const List<OrderTrackingStatus> timeline = [
    OrderPending(),
    OrderPreparing(),
    OrderOutForDelivery(),
    OrderDelivered(),
  ];

  // 6. Check karne ka function ke status aage nikal gaya ya nahi
  bool isAtOrPast(OrderTrackingStatus other) {
    if (stepIndex >= other.stepIndex) {
      return true;
    } else {
      return false;
    }
  }
}

// Choti aur simple sub-classes bina kisi extra boiler plate ke
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
