import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  void login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Sau khi đăng nhập thành công, chuyển hướng đến HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() => errorMessage = "Đăng nhập thất bại, vui lòng thử lại.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: login,
              child: const Text("Đăng nhập"),
            ),
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () {
                // Chuyển sang trang đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ).then((_) {
                  // Khi quay lại, đặt lại state
                  setState(() {
                    emailController.clear();
                    passwordController.clear();
                    errorMessage = '';
                  });
                });
              },
              child: const Text("Chưa có tài khoản? Đăng ký"),
            ),
          ],
        ),
      ),
    );
  }
}
