import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isCodeSent = false;
  String _verificationId = '';

  // =====================================================
  // 🔸 GỬI OTP
  Future<void> _sendPhoneOTP() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) return _showMsg("Vui lòng nhập số điện thoại!");

    // Nếu người dùng không nhập dấu +
    if (!phone.startsWith('+')) {
      phone = '+1$phone';
    }

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToHome();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showMsg("Lỗi xác thực: ${e.message}");
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
            _isLoading = false;
          });
          _showMsg("Đã gửi OTP đến $phone");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showMsg("Lỗi gửi OTP: $e");
      setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // 🔸 XÁC NHẬN OTP
  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return _showMsg("Vui lòng nhập OTP");

    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      _navigateToHome();
    } catch (e) {
      _showMsg("OTP không hợp lệ hoặc lỗi đăng nhập: $e");
      setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // 🔸 ĐĂNG NHẬP GOOGLE
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // đảm bảo chọn tài khoản mỗi lần
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _showMsg("Đăng nhập Google bị hủy");
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        _showMsg("Không lấy được thông tin người dùng");
        setState(() => _isLoading = false);
        return;
      }

      // 🔹 Phân quyền Admin
      if (user.email == 'duongtanhuy2004@gmail.com') {
        _showMsg("Xin chào Admin ${user.displayName ?? ''}");
        _navigateToAdmin();
      } else {
        _showMsg("Chào mừng ${user.displayName ?? ''}");
        _navigateToHome();
      }
    } catch (e) {
      _showMsg("Lỗi Google Sign-In: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // =====================================================
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToAdmin() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/admin');
  }

  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng nhập"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            Image.asset('assets/logo.png', width: 180, height: 180),
            const SizedBox(height: 20),

            // PHONE INPUT
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Số điện thoại",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),

            if (_isCodeSent)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Nhập OTP",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
            const SizedBox(height: 20),

            // NÚT GỬI/XÁC NHẬN OTP
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_isCodeSent ? _verifyOTP : _sendPhoneOTP),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isCodeSent ? "Xác nhận OTP" : "Gửi OTP",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1.2),
            const SizedBox(height: 30),

            // GOOGLE LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                label: const Text(
                  "Đăng nhập bằng Google",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
