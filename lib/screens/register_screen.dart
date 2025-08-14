import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '', confirmPassword = '';
  bool loading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    final primaryColor = Color(0xFFBB86FC);
    final errorColor = Color(0xFFCF6679);
    final textColor = Colors.white70;

    return Scaffold(
      backgroundColor: Color(0xFF0a0a0a),
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Join Cinec and explore!',
                style: TextStyle(fontSize: 16, color: textColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Name
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Name', Icons.person, textColor, primaryColor, errorColor),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
                onChanged: (v) => name = v,
              ),
              SizedBox(height: 20),
              // Email
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email', Icons.email, textColor, primaryColor, errorColor),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
                onChanged: (v) => email = v,
              ),
              SizedBox(height: 20),
              // Password
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Password',
                  Icons.lock,
                  textColor,
                  primaryColor,
                  errorColor,
                  obscure: _obscurePassword,
                  toggle: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                obscureText: _obscurePassword,
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                onChanged: (v) => password = v,
              ),
              SizedBox(height: 20),
              // Confirm Password
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Confirm Password',
                  Icons.lock,
                  textColor,
                  primaryColor,
                  errorColor,
                  obscure: _obscureConfirmPassword,
                  toggle: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                obscureText: _obscureConfirmPassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter confirm password';
                  if (v != password) return 'Passwords do not match';
                  return null;
                },
                onChanged: (v) => confirmPassword = v,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        'Register',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => loading = true);
                  try {
                    final user = await auth.registerWithEmail(name, email, password);
                    if (user != null) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: errorColor,
                      ),
                    );
                  } finally {
                    setState(() => loading = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    Color textColor,
    Color primaryColor,
    Color errorColor, {
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor),
      prefixIcon: Icon(icon, color: textColor),
      suffixIcon: toggle != null
          ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: textColor),
              onPressed: toggle,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white12,
    );
  }
}
