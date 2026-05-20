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
import 'package:tpg316c_assignment/main.dart';
import 'package:tpg316c_assignment/models/application.dart';
import 'package:tpg316c_assignment/viewmodels/application_viewmodel.dart';

class AdminApplicationDetailPage extends StatefulWidget {
  final Application application;

  const AdminApplicationDetailPage({super.key, required this.application});

  @override
  State<AdminApplicationDetailPage> createState() =>
      _AdminApplicationDetailPageState();
}

class _AdminApplicationDetailPageState
    extends State<AdminApplicationDetailPage> {
  late String _status;

  final List<String> _statuses = ['Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _status = widget.application.status;
  }

  Future<void> _updateApplicationStatus() async {
    await Provider.of<ApplicationViewModel>(context, listen: false)
        .updateApplicationStatus(
      widget.application.id,
      _status,
    );
    if (mounted) {
      context.showSnackBar('Application status updated successfully!');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateApplicationStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Applicant ID: ${widget.application.userId}'),
            const SizedBox(height: 16),
            Text('Year of Study: ${widget.application.yearOfStudy}'),
            const SizedBox(height: 16),
            Text('Academic Level: ${widget.application.academicLevel}'),
            const SizedBox(height: 16),
            Text('Module 1: ${widget.application.module1}'),
            const SizedBox(height: 16),
            Text('Module 2: ${widget.application.module2 ?? 'N/A'}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
                'Created At: ${widget.application.createdAt.toLocal().toShortDateString()}'),
          ],
        ),
      ),
    );
  }
}

extension on DateTime {
  String toShortDateString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
