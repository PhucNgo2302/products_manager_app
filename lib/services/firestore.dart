import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference products =
  FirebaseFirestore.instance.collection('products');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Thêm sản phẩm
  Future<void> addProduct(String userId, String name, String category, double price, String? imageUrl) {
    return products.add({
      'userId': userId,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  // Lấy danh sách sản phẩm của người dùng hiện tại
  Stream<QuerySnapshot> getUserProductsStream(String userID) {
    return products
        .where('userId', isEqualTo: userID) // Lọc theo userId
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(String docID, String name, String category, double price, String? imageUrl) {
    return products.doc(docID).update({
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String docID) {
    return products.doc(docID).delete();
  }
}
