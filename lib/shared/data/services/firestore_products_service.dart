import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:developer_task/core/constants/firestore_paths.dart';
import 'package:developer_task/core/models/product.dart';

class FirestoreProductsService {
  FirestoreProductsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(FirestorePaths.products);

  Stream<List<Product>> watchAllProducts() {
    return _products.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> createProduct(Product product) async {
    final doc = await _products.add({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateProduct(Product product) {
    return _products.doc(product.id).update({
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String productId) {
    return _products.doc(productId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
