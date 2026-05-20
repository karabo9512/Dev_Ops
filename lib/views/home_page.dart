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
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tpg316c_assignment/main.dart';
import 'package:tpg316c_assignment/viewmodels/application_viewmodel.dart';
import 'package:tpg316c_assignment/views/application_form_page.dart';
import 'package:tpg316c_assignment/views/application_detail_page.dart';
import 'package:tpg316c_assignment/views/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cohesive DevOps Dark Theme Palette Variables
  final Color _backgroundColor = const Color(0xFF121212);
  final Color _cardColor = const Color(0xFF1E1E1E);
  final Color _accentColor = const Color(0xFF3F51B5);
  final Color _textPrimary = Colors.white;
  final Color _textSecondary = Colors.grey[400]!;

  @override
  void initState() {
    super.initState();
    //  Wait for the frame to finish before loading data
    // This prevents the "markNeedsBuild() called during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  Future<void> _loadApplications() async {
    await Provider.of<ApplicationViewModel>(context, listen: false)
        .fetchApplications();
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
  }

  // Pure styling helper method to return readable status color values in dark mode
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.greenAccent[400]!;
      case 'rejected':
        return Colors.redAccent[200]!;
      case 'pending':
      default:
        return Colors.amber[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Dark mode canvas
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: _cardColor,
        foregroundColor: _textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: _textPrimary,
            onPressed: _loadApplications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: _textPrimary,
            onPressed: _signOut,
          ),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: _accentColor));
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (viewModel.applications.isEmpty) {
            return Center(
              child: Text(
                'No applications submitted yet.',
                style: TextStyle(color: _textSecondary, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            itemCount: viewModel.applications.length,
            itemBuilder: (context, index) {
              final application = viewModel.applications[index];
              return Card(
                color: _cardColor, // Dark background for item cards
                margin:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    application.module1,
                    style: TextStyle(
                        color: _textPrimary, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level: ${application.academicLevel}',
                          style: TextStyle(color: _textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${application.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(application.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: _textSecondary),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ApplicationDetailPage(application: application),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const ApplicationFormPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Application',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
