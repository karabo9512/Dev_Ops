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
import 'package:tpg316c_assignment/models/application.dart';
import 'package:tpg316c_assignment/viewmodels/application_viewmodel.dart';

class ApplicationDetailPage extends StatefulWidget {
  final Application application;

  const ApplicationDetailPage({super.key, required this.application});

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late String _studentNumber; // Track student number state
  late String _yearOfStudy;
  late String _academicLevel;
  late String _module1;
  String? _module2;
  late String _status;

  bool _isEditing = false;
  bool _isAdmin = false; //  Track if current user is Admin
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Safely pull from model (with fallback if model hasn't fully updated yet)
    _studentNumber = widget.application.studentNumber ?? 'N/A';
    _yearOfStudy = widget.application.yearOfStudy;
    _academicLevel = widget.application.academicLevel;
    _module1 = widget.application.module1;
    _module2 = widget.application.module2;
    _status = widget.application.status;
    _isEditing = widget.application.status == 'Pending';
    _checkRole();
  }

  // Logic to check if user is Admin
  Future<void> _checkRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isAdmin = data?['is_admin'] ?? false;
        });
      }
    }
  }

  //  Logic for Admin to update status
  Future<void> _handleAdminDecision(String newStatus) async {
    setState(() => _isProcessing = true);
    await Provider.of<ApplicationViewModel>(context, listen: false)
        .updateApplicationStatus(widget.application.id, newStatus);

    if (mounted) {
      context.showSnackBar('Application $newStatus successfully!');
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateApplication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await Provider.of<ApplicationViewModel>(context, listen: false)
          .updateApplication(
        widget.application.id,
        studentNumber:
            _studentNumber, // Added the missing required parameter safely
        yearOfStudy: _yearOfStudy,
        academicLevel: _academicLevel,
        module1: _module1,
        module2: _module2,
        status: _status,
      );
      if (mounted) {
        context.showSnackBar('Application updated successfully!');
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _deleteApplication() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this application?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmDelete == true) {
      await Provider.of<ApplicationViewModel>(context, listen: false)
          .deleteApplication(widget.application.id);
      if (mounted) {
        context.showSnackBar('Application deleted successfully!');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (_isEditing && !_isAdmin) // Students edit, Admins decide
            IconButton(
                icon: const Icon(Icons.save), onPressed: _updateApplication),
          if (widget.application.status == 'Pending' && !_isAdmin)
            IconButton(
                icon: const Icon(Icons.delete), onPressed: _deleteApplication),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- STUDENT NUMBER FIELD ---
              TextFormField(
                initialValue: _studentNumber,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                  filled: true,
                ),
                enabled: false, // Keep non-editable on structural detail pages
              ),
              const SizedBox(height: 16),

              // --- YEAR OF STUDY FIELD ---
              TextFormField(
                initialValue: _yearOfStudy,
                decoration: const InputDecoration(
                    labelText: 'Year of Study', border: OutlineInputBorder()),
                enabled: _isEditing && !_isAdmin,
                onSaved: (value) => _yearOfStudy = value!,
              ),
              const SizedBox(height: 16),

              // --- ACADEMIC LEVEL FIELD ---
              TextFormField(
                initialValue: _academicLevel,
                decoration: const InputDecoration(
                    labelText: 'Academic Level', border: OutlineInputBorder()),
                enabled: _isEditing && !_isAdmin,
                onSaved: (value) => _academicLevel = value!,
              ),
              const SizedBox(height: 16),

              // --- MODULE 1 FIELD ---
              TextFormField(
                initialValue: _module1,
                decoration: const InputDecoration(
                    labelText: 'Module 1', border: OutlineInputBorder()),
                enabled: _isEditing && !_isAdmin,
                onSaved: (value) => _module1 = value!,
              ),
              const SizedBox(height: 16),

              // --- STATUS DISPLAY FIELD ---
              TextFormField(
                initialValue: _status,
                decoration:
                    const InputDecoration(labelText: 'Status', filled: true),
                enabled: false,
              ),
              const SizedBox(height: 24),

              // ADMIN DECISION SECTION
              if (_isAdmin) ...[
                const Divider(thickness: 2),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Admin Decision',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          onPressed: () => _handleAdminDecision('Approved'),
                          child: const Text('APPROVE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white),
                          onPressed: () => _handleAdminDecision('Rejected'),
                          child: const Text('REJECT'),
                        ),
                      ),
                    ],
                  ),
              ],

              const SizedBox(height: 20),
              Center(
                  child: Text(
                      'Created At: ${widget.application.createdAt.toLocal().toShortDateString()}')),
            ],
          ),
        ),
      ),
    );
  }
}

extension on DateTime {
  String toShortDateString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
