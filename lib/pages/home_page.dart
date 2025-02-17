import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:products_manager_app/services/firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/imgur_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();


  String? imageUrl;
  bool isUploading = false;

  Future<void> pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => isUploading = true);
      File imageFile = File(pickedFile.path);
      String? uploadedImageUrl = await ImgurService().uploadImage(imageFile);
      if (uploadedImageUrl != null) {
        setState(() {
          imageUrl = uploadedImageUrl;
          isUploading = false;
        });
      } else {
        setState(() => isUploading = false);
      }
    }
  }

  void openProductDialog(String? docID, String? existingName, String? existingCategory, String? existingPrice, String? existingImageUrl) {
    nameController.text = existingName ?? '';
    categoryController.text = existingCategory ?? '';
    priceController.text = existingPrice ?? '';
    imageUrl = existingImageUrl ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(docID == null ? "Thêm sản phẩm" : "Cập nhật sản phẩm"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Tên sản phẩm"),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: "Loại sản phẩm"),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Giá sản phẩm"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => isUploading = true);
                      await pickAndUploadImage();
                      setDialogState(() => isUploading = false);
                    },
                    child: const Text("Chọn ảnh"),
                  ),
                  const SizedBox(height: 10),
                  isUploading
                      ? const CircularProgressIndicator()
                      : (imageUrl != ''
                      ? Image.network(imageUrl!, height: 100)
                      : const Icon(Icons.image, size: 100)),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty && priceController.text.isNotEmpty) {
                    double? price = double.tryParse(priceController.text);
                    if (price != null) {
                      if (docID == null) {
                        firestoreService.addProduct(userId,nameController.text, categoryController.text, price, imageUrl);
                      } else {
                        firestoreService.updateProduct(docID, nameController.text, categoryController.text, price, imageUrl);
                      }
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(docID == null ? "Thêm" : "Cập nhật"),
              ),
            ],
          );
        },
      ),
    );
  }

  void confirmDeleteProduct(String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              firestoreService.deleteProduct(docID);
              Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  //Hàm đăng xuất
  void logout() async {
    await _auth.signOut(); // Đăng xuất khỏi Firebase
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // Chuyển về trang đăng nhập
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Quản lý sản phẩm"),
          actions: [
            IconButton(
              onPressed: logout, // Gọi hàm đăng xuất
              icon: const Icon(Icons.logout),
              tooltip: "Đăng xuất",
            ),
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openProductDialog(null, null, null, null, null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getUserProductsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            List<DocumentSnapshot> productList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = productList[index];
                String docID = document.id;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                String name = data['name'];
                String category = data['category'];
                String price = data['price'].toString();
                String? imageUrl = data['imageUrl'];

                return ListTile(
                  leading: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50);
                    },
                  )
                      : const Icon(Icons.image, size: 50),
                  title: Text(name),
                  subtitle: Text("Loại: $category - Giá: $price"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Update sản phẩm
                      IconButton(
                        onPressed: () => openProductDialog(docID, name, category, price, imageUrl),
                        icon: const Icon(Icons.edit),
                      ),
                      //Xóa sản phẩm
                      IconButton(
                        onPressed: () => confirmDeleteProduct(docID),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {

            return const Center(child: Text("Chưa có sản phẩm nào."));
          }
        },
      ),
    );
  }
}
