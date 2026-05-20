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
import 'package:tpg316c_assignment/views/admin_application_detail_page.dart';
import 'package:tpg316c_assignment/views/login_page.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  @override
  void initState() {
    super.initState();
    _loadAllApplications();
  }

  Future<void> _loadAllApplications() async {
    await Provider.of<ApplicationViewModel>(context, listen: false)
        .fetchAllApplicationsForAdmin();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllApplications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Consumer<ApplicationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${viewModel.errorMessage}'));
          }
          if (viewModel.applications.isEmpty) {
            return const Center(child: Text('No applications found.'));
          }
          return ListView.builder(
            itemCount: viewModel.applications.length,
            itemBuilder: (context, index) {
              final application = viewModel.applications[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                      'Application for: ${application.module1} by ${application.userId}'),
                  subtitle: Text('Status: ${application.status}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdminApplicationDetailPage(
                            application: application),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
