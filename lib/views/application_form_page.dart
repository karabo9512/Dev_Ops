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
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'
    show kIsWeb; //  Distinguishes between Web and Mobile runtimes
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tpg316c_assignment/main.dart';
import 'package:tpg316c_assignment/services/supabase_service.dart';
import 'package:tpg316c_assignment/viewmodels/application_viewmodel.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({super.key});

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Field State Variables
  String _studentNumber = '';
  String _yearOfStudy = '1st Year';
  String _academicLevel = 'Diploma';
  String _module1 = '';
  String? _module2;

  // Platform-agnostic file references
  File? _selectedFile; // Native Platforms (Android/iOS/Linux)
  Uint8List? _fileBytes; // Web Sandboxed Browsers
  String? _fileName;

  String _fileStatusText = "No file selected";
  bool _isUploading = false;

  final List<String> _yearsOfStudy = ['1st Year', '2nd Year', '3rd Year'];
  final List<String> _academicLevels = ['Diploma', 'Degree'];

  // Cohesive DevOps Dark Theme Palette Variables
  final Color _backgroundColor = const Color(0xFF121212);
  final Color _cardColor = const Color(0xFF1E1E1E);
  final Color _accentColor = const Color(0xFF3F51B5);
  final Color _textPrimary = Colors.white;
  final Color _textSecondary = Colors.grey[400]!;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
        withData:
            true, // 👈 CRITICAL: Instructs browser to pipeline underlying stream bytes
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _fileName = result.files.single.name;
          _fileStatusText = "File Selected: $_fileName";

          if (kIsWeb) {
            _fileBytes =
                result.files.single.bytes; // Safely read file binary content
            _selectedFile = null;
          } else {
            _selectedFile = File(
                result.files.single.path!); // Cache platform directory path
          }
        });
      }
    } catch (e) {
      if (mounted) context.showSnackBar("Error picking file: $e");
    }
  }

  Future<void> _handleSubmission() async {
    // 1. Text Field Validations
    if (!_formKey.currentState!.validate()) return;

    // 2. Binary Payload Validation Check
    bool isFileLoaded = kIsWeb ? (_fileBytes != null) : (_selectedFile != null);
    if (!isFileLoaded) {
      context.showSnackBar('Please attach your academic record first.');
      return;
    }

    // Capture dependencies BEFORE async gaps to maintain context safety
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);
    final viewModel = Provider.of<ApplicationViewModel>(context, listen: false);

    _formKey.currentState!.save();
    setState(() => _isUploading = true);

    try {
      // 3. Dispatch file reference or byte block to bucket partition
      final fileUrl = await supabaseService.uploadFile(
        file: _selectedFile,
        bytes: _fileBytes,
        bucketName: 'application_documents',
        path: 'uploads/${DateTime.now().millisecondsSinceEpoch}_$_fileName',
      );

      // 4. Record state metadata transaction into transactional database engine
      await viewModel.submitApplication(
        studentNumber: _studentNumber, // 👈 New parameter passed safely
        yearOfStudy: _yearOfStudy,
        academicLevel: _academicLevel,
        module1: _module1,
        module2: _module2,
        documentUrl: fileUrl,
      );

      if (mounted) {
        _formKey.currentState!.reset();
        context.showSnackBar('Application submitted successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Submission failure: ${e.toString()}');
    } finally {
      if (mounted) {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  // Helper method to keep InputDecoration syntax clean and dark-theme compliant
  InputDecoration _buildInputDecoration(
      {required String labelText, required IconData prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: _textSecondary),
      prefixIcon: Icon(prefixIcon, color: _textSecondary),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _accentColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFileSelected = kIsWeb ? _fileBytes != null : _selectedFile != null;

    return Scaffold(
      backgroundColor: _backgroundColor, // Set scaffold base canvas to dark
      appBar: AppBar(
        title: const Text('Submit Application'),
        backgroundColor: _cardColor,
        foregroundColor: _textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- STUDENT NUMBER FIELD ---
              TextFormField(
                style: TextStyle(color: _textPrimary),
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                    labelText: 'Student Number', prefixIcon: Icons.badge),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter your student number';
                  }
                  if (v.length < 7) {
                    return 'Enter a valid student number';
                  }
                  return null;
                },
                onSaved: (v) => _studentNumber = v!,
              ),
              const SizedBox(height: 16),

              // --- YEAR OF STUDY DROPDOWN ---
              DropdownButtonFormField<String>(
                dropdownColor:
                    _cardColor, // Prevents white box dropdown clipping
                style: TextStyle(color: _textPrimary, fontSize: 16),
                value: _yearOfStudy,
                decoration: _buildInputDecoration(
                    labelText: 'Year of Study',
                    prefixIcon: Icons.calendar_today),
                items: _yearsOfStudy
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y, style: TextStyle(color: _textPrimary)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _yearOfStudy = val!),
              ),
              const SizedBox(height: 16),

              // --- ACADEMIC LEVEL DROPDOWN ---
              DropdownButtonFormField<String>(
                dropdownColor: _cardColor,
                style: TextStyle(color: _textPrimary, fontSize: 16),
                value: _academicLevel,
                decoration: _buildInputDecoration(
                    labelText: 'Academic Level', prefixIcon: Icons.school),
                items: _academicLevels
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l, style: TextStyle(color: _textPrimary)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _academicLevel = val!),
              ),
              const SizedBox(height: 16),

              // --- MODULE 1 FIELD ---
              TextFormField(
                style: TextStyle(color: _textPrimary),
                decoration: _buildInputDecoration(
                    labelText: 'Module 1', prefixIcon: Icons.book),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter Module 1' : null,
                onSaved: (v) => _module1 = v!,
              ),
              const SizedBox(height: 16),

              // --- MODULE 2 FIELD (OPTIONAL) ---
              TextFormField(
                style: TextStyle(color: _textPrimary),
                decoration: _buildInputDecoration(
                    labelText: 'Module 2 (Optional)',
                    prefixIcon: Icons.menu_book),
                onSaved: (v) => _module2 = v,
              ),
              const SizedBox(height: 24),

              // --- UI ATTACHMENT FEEDBACK BLOCK ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFileSelected
                      ? Colors.green.withOpacity(0.08)
                      : _cardColor,
                  border: Border.all(
                    color: isFileSelected ? Colors.green : Colors.grey[800]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Academic Proof (PDF/JPG/PNG)",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: _textPrimary),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isFileSelected ? Icons.check_circle : Icons.upload_file,
                        color: isFileSelected
                            ? Colors.green
                            : Colors.blueAccent[100],
                      ),
                      title: Text(
                        _fileStatusText,
                        style: TextStyle(
                          color: isFileSelected ? Colors.green : _textSecondary,
                          fontWeight: isFileSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: _isUploading ? null : _pickFile,
                        style: TextButton.styleFrom(
                          foregroundColor: isFileSelected
                              ? Colors.orangeAccent[100]
                              : Colors.blueAccent[100],
                        ),
                        child: Text(!isFileSelected ? "BROWSE" : "CHANGE"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- ACTION SUBMIT BUTTON ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isUploading ? null : _handleSubmission,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
