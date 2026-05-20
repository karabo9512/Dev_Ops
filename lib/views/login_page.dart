// ====================================================================
// INSTITUTION: Central University of Technology, Free State
// MODULE CODE: TPG316C - TECHNICAL PROGRAMMING III
// ASSIGNMENT: GROUP_A
// GROUP MEMBERS:
// 1. T.M.T. Sepale   - 222026926
// 2. A.B. Jansen     - 223011463
// 3. I.M. Molefi     - 223048296
// 4. M. Mothei       - 223005118
// 5. K. Lelaka       - 223028926
// ====================================================================
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tpg316c_assignment/main.dart';
import 'package:tpg316c_assignment/views/home_page.dart';
import 'package:tpg316c_assignment/views/admin_dashboard_page.dart';
import 'package:tpg316c_assignment/views/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Cohesive Dark Mode Palette matching the Admin Dashboard
  final Color _backgroundColor =
      const Color(0xFF121212); // Deep AMOLED dark canvas
  final Color _cardColor =
      const Color(0xFF1E1E1E); // Elegant surface card container
  final Color _accentColor = const Color(0xFF3F51B5); // Smooth indigo accent
  final Color _textPrimary = Colors.white; // Solid white text
  final Color _textSecondary = Colors.grey[400]!; // Muted grey text

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // 1. Authenticate with Supabase
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        try {
          // 2. CHECK ROLE
          final profileData = await supabase
              .from('profiles')
              .select('is_admin')
              .eq('id', response.user!.id)
              .maybeSingle();

          final bool isAdmin = (profileData != null)
              ? (profileData['is_admin'] ?? false)
              : false;

          // 3. NAVIGATE based on the role found
          if (isAdmin) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const AdminDashboardPage()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } catch (e) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Connection error. Please try again.',
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Dark Background applied here
      appBar: AppBar(
        title: const Text('TPG316C Login'),
        backgroundColor: _cardColor,
        foregroundColor: _textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Card(
              color:
                  _cardColor, // Encapsulating login fields into a sleek card container
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //  DevOps Student Assistant App
                    Text(
                      'DevOps Student Assistant App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage your academic applications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: _textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: _textSecondary),
                        prefixIcon:
                            Icon(Icons.email_outlined, color: _textSecondary),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: BorderSide(color: _accentColor)
                            .toDecorationBorder(), // Safe fallback styling
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(color: _textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: _textSecondary),
                        prefixIcon:
                            Icon(Icons.lock_outline, color: _textSecondary),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _accentColor),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Login',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blueAccent[100],
                                ),
                                child: const Text('Create Student Account'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Quick helper extension to handle the safe focused border fallback smoothly without SDK conflicts
extension on BorderSide {
  InputBorder toDecorationBorder() => OutlineInputBorder(borderSide: this);
}
