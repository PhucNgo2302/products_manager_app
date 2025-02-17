import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  void register() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() => errorMessage = "Mật khẩu xác nhận không khớp.");
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
            backgroundColor: Colors.green,
          ),
        );

        // Quay lại trang đăng nhập
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => errorMessage = "Đăng ký thất bại, vui lòng thử lại.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: SingleChildScrollView(  // 🔥 Thêm để tránh lỗi tràn màn hình
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Khoảng cách phía trên
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: "Xác nhận mật khẩu"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: register,
                child: const Text("Đăng ký"),
              ),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Đã có tài khoản? Đăng nhập"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
