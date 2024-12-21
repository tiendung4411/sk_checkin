import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_services.dart';
import 'dashboard_screen.dart'; // Import UserService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserService _userService = UserService(); // Instance of UserService
  final TextEditingController _phoneController = TextEditingController(text:'0988483738');
  final TextEditingController _passwordController = TextEditingController(text:'abc');
  bool _isPasswordVisible = false;
  bool _isLoading = false;


  Future<void> _login() async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    try {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final response = await _userService.loginUser({
        'phoneNumber': phone,
        'password': password,
      });

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      // Check the message field in the response
      if (response['message'] == 'Login successful') {
        final userData = response['data'];
        final String role = userData['role'] ?? '';

        // Validate role
        if (role == 'admin' || role == 'ghc') {
          // Save login information to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userData['_id'] ?? '');
          await prefs.setString('role', role);
          await prefs.setString('phoneNumber', userData['phoneNumber'] ?? '');
          await prefs.setString('username', userData['username'] ?? '');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công! Chào mừng bạn.')),
          );

          // Navigate to DashboardScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chỉ quản trị viên và chủ gian hàng được phép đăng nhập.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: ${response['message']}')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi hệ thống: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logo = SizedBox(
      height: 320,
      child: Image.asset('assets/logo.png'),
    );

    final headerText = Text(
      'SK CHECKIN',
      style: theme.textTheme.headlineLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 44,
      ),
    );

    final phoneNumberField = TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Nhập số điện thoại của bạn',
        labelText: 'Số điện thoại',
        labelStyle: theme.textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.phone),
      ),
    );

    final passwordField = TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Nhập mật khẩu của bạn',
        labelText: 'Mật khẩu',
        labelStyle: theme.textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );

    final loginButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _login,
      child: _isLoading
          ? const CircularProgressIndicator(
        color: Colors.white,
      )
          : Text(
        'Đăng nhập',
        style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white),
      ),
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo,
              const SizedBox(height: 20),
              headerText,
              const SizedBox(height: 20),
              phoneNumberField,
              const SizedBox(height: 20),
              passwordField,
              const SizedBox(height: 30),
              loginButton,
            ],
          ),
        ),
      ),
    );
  }
}