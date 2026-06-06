sealed class PaymentMethod {
  const PaymentMethod();

  // Database value ke liye simple switch
  String get firestoreValue {
    switch (this) {
      case PaymentStripe():
        return 'stripe';
      case PaymentCashOnDelivery():
        return 'cod';
    }
  }

  // Screen par dikhane ke liye label text
  String get label {
    switch (this) {
      case PaymentStripe():
        return 'Card (Stripe)';
      case PaymentCashOnDelivery():
        return 'Cash on delivery';
    }
  }

  // Firestore text se object banane ka function
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

  // Database status value ke liye switch
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

  // Firestore text se status object banane ka function
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

// ==========================================
// 3. PAYMENT CHECKOUT STATE (Runtime State)
// ==========================================
sealed class PaymentCheckoutState {
  const PaymentCheckoutState();
}

// Shuru ki state jab kuch nahi ho raha
class PaymentCheckoutIdle extends PaymentCheckoutState {
  const PaymentCheckoutIdle();
}

// Jab payment process ho rahi ho (Method pass karna lazmi hai)
class PaymentCheckoutProcessing extends PaymentCheckoutState {
  final PaymentMethod method;
  const PaymentCheckoutProcessing({required this.method});
}

// Jab payment successful ho jaye
class PaymentCheckoutSucceeded extends PaymentCheckoutState {
  final PaymentMethod method;
  const PaymentCheckoutSucceeded({required this.method});
}

// Jab payment fail ho jaye (Error message ke sath)
class PaymentCheckoutFailed extends PaymentCheckoutState {
  final String message;
  final PaymentMethod? method;
  const PaymentCheckoutFailed({required this.message, this.method});
}
