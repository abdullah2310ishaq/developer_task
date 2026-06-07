sealed class PaymentMethod {
  const PaymentMethod();

  String get firestoreValue {
    switch (this) {
      case PaymentStripe():
        return 'stripe';
      case PaymentCashOnDelivery():
        return 'cod';
    }
  }

  String get label {
    switch (this) {
      case PaymentStripe():
        return 'Card (Stripe)';
      case PaymentCashOnDelivery():
        return 'Cash on delivery';
    }
  }

  static PaymentMethod fromFirestore(String? raw) {
    switch (raw) {
      case 'stripe':
        return const PaymentStripe();
      default:
        return const PaymentCashOnDelivery();
    }
  }
}

class PaymentStripe extends PaymentMethod {
  const PaymentStripe();
}

class PaymentCashOnDelivery extends PaymentMethod {
  const PaymentCashOnDelivery();
}

sealed class PaymentRecordStatus {
  const PaymentRecordStatus();

  String get firestoreValue {
    switch (this) {
      case PaymentPaid():
        return 'paid';
      case PaymentPending():
        return 'pending';
      case PaymentFailed():
        return 'failed';
    }
  }

 static PaymentRecordStatus fromFirestore(String? raw) {
    switch (raw) {
      case 'paid':
        return const PaymentPaid();
      case 'failed':
        return const PaymentFailed();
      default:
        return const PaymentPending();
    }
  }
}

class PaymentPaid extends PaymentRecordStatus {
  const PaymentPaid();
}

class PaymentPending extends PaymentRecordStatus {
  const PaymentPending();
}

class PaymentFailed extends PaymentRecordStatus {
  const PaymentFailed();
}


sealed class PaymentCheckoutState {
  const PaymentCheckoutState();
}

// intial state first
class PaymentCheckoutIdle extends PaymentCheckoutState {
  const PaymentCheckoutIdle();
}

//processing one 
class PaymentCheckoutProcessing extends PaymentCheckoutState {
  final PaymentMethod method;
  const PaymentCheckoutProcessing({required this.method});
}

// event ok
class PaymentCheckoutSucceeded extends PaymentCheckoutState {
  final PaymentMethod method;
  const PaymentCheckoutSucceeded({required this.method});
}


class PaymentCheckoutFailed extends PaymentCheckoutState {
  final String message;
  final PaymentMethod? method;
  const PaymentCheckoutFailed({required this.message, this.method});
}
