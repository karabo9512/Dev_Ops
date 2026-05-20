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
import 'package:tpg316c_assignment/viewmodels/application_viewmodel.dart';
import 'package:tpg316c_assignment/views/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Cohesive Dark Mode Palette
  final Color _backgroundColor =
      const Color(0xFF121212); // Deep AMOLED dark canvas
  final Color _cardColor =
      const Color(0xFF1E1E1E); // Elegant surface card container
  final Color _accentColor = const Color(0xFF3F51B5); // Smooth indigo accent
  final Color _textPrimary = Colors.white; // Solid white text for visibility
  final Color _textSecondary =
      Colors.grey[400]!; // Muted grey text for captions

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllApplications();
    });
  }

  Future<void> _loadAllApplications() async {
    await Provider.of<ApplicationViewModel>(context, listen: false)
        .fetchAllApplicationsForAdmin();
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _viewDocument(String? urlContext) async {
    if (urlContext == null || urlContext.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document uploaded by this student.')),
      );
      return;
    }
    final Uri url = Uri.parse(urlContext);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not launch document attachment link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Root screen background set to dark
      appBar: AppBar(
        title: const Text('Staff Admin Dashboard'),
        backgroundColor: _cardColor, // Dark top app bar layer
        foregroundColor: _textPrimary,
        elevation: 0,
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
            return Center(
                child: CircularProgressIndicator(color: _accentColor));
          }
          if (viewModel.applications.isEmpty) {
            return Center(
              child: Text(
                'No student applications found.',
                style: TextStyle(color: _textSecondary),
              ),
            );
          }

          return Column(
            children: [
              // Total Applications Banner Panel
              Container(
                padding: const EdgeInsets.all(16),
                color: _accentColor
                    .withOpacity(0.15), // Translucent indigo tint background
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _accentColor),
                    const SizedBox(width: 10),
                    Text(
                      'Total Applications: ${viewModel.applications.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.applications.length,
                  itemBuilder: (context, index) {
                    final app = viewModel.applications[index];

                    final String fallbackId = app.userId.length > 8
                        ? '${app.userId.substring(0, 8)}...'
                        : app.userId;

                    return Card(
                      key: ValueKey(app.id),
                      color: _cardColor, // Dark card theme assignment
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            _getStatusColor(app.status)
                                                .withOpacity(0.2),
                                        radius: 16,
                                        child: Icon(
                                          Icons.person,
                                          color: _getStatusColor(app.status),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (app.studentNumber != null &&
                                                      app.studentNumber!
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                  ? 'Student No: ${app.studentNumber}'
                                                  : 'Student No: Not Provided',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _textPrimary,
                                                  fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'User Reference ID: $fallbackId',
                                              style: TextStyle(
                                                  color: _textSecondary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Admin Delete Action Button
                                IconButton(
                                  icon: const Icon(Icons.delete_forever,
                                      color: Colors.redAccent),
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Deleting application entry...'),
                                          duration: Duration(seconds: 1)),
                                    );

                                    await viewModel.deleteApplication(app.id,
                                        isAdminContext: true);

                                    if (mounted) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Application purged successfully.')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            Divider(
                                color: Colors
                                    .grey[800]), // Custom deep dark divider

                            Text(
                              'Year of Study: ${app.yearOfStudy}',
                              style:
                                  TextStyle(fontSize: 14, color: _textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Academic Level: ${app.academicLevel}',
                              style:
                                  TextStyle(fontSize: 14, color: _textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Modules Selected: ${app.module1}${app.module2 != null ? ", ${app.module2}" : ""}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _textPrimary),
                            ),
                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Text(
                                  'Academic Proof: ',
                                  style: TextStyle(
                                      fontSize: 14, color: _textPrimary),
                                ),
                                app.documentUrl != null &&
                                        app.documentUrl!.isNotEmpty
                                    ? TextButton.icon(
                                        onPressed: () =>
                                            _viewDocument(app.documentUrl),
                                        icon: Icon(Icons.open_in_new,
                                            size: 16, color: Colors.blue[300]),
                                        label: Text(
                                          'View Document File',
                                          style: TextStyle(
                                              color: Colors.blue[300]),
                                        ),
                                      )
                                    : Text(
                                        'No attachment',
                                        style: TextStyle(
                                            color: _textSecondary,
                                            fontStyle: FontStyle.italic),
                                      ),
                              ],
                            ),

                            Row(
                              children: [
                                Text(
                                  'Current Review State: ',
                                  style: TextStyle(
                                      fontSize: 14, color: _textPrimary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(app.status)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      //FIXED: Safe across all SDK environments
                                      width: 1,
                                      color: _getStatusColor(app.status)
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    app.status,
                                    style: TextStyle(
                                      color: _getStatusColor(app.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Dynamic Approval Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: app.status == 'Rejected'
                                      ? null
                                      : () async {
                                          await viewModel
                                              .updateApplicationStatus(
                                                  app.id, 'Rejected');
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(
                                        color: Colors.redAccent),
                                  ),
                                  icon: const Icon(Icons.cancel_outlined,
                                      size: 18),
                                  label: const Text('Reject'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: app.status == 'Approved'
                                      ? null
                                      : () async {
                                          await viewModel
                                              .updateApplicationStatus(
                                                  app.id, 'Approved');
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.check_circle_outline,
                                      size: 18),
                                  label: const Text('Approve'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Vivid color adjustments optimal for readability over dark background items
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.greenAccent[400]!;
      case 'Rejected':
        return Colors.redAccent;
      case 'Pending':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }
}
