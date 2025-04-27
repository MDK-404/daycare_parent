import 'package:daycare_parent/view_models/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final error = await authVM.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null)
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Login Failed"),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    else {
      // Show welcome popup
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Login Successful"),
              content: const Text("Welcome to the Daycare App!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueGrey,
                child: Text("Logo", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text("Welcome Back!", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 25),

              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: _obscurePassword,

                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot password flow
                  },
                  child: const Text("Forgot password?"),
                ),
              ),
              const SizedBox(height: 20),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Sign In"),
                  ),

              const SizedBox(height: 10),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
