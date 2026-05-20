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
import 'package:tpg316c_assignment/models/application.dart';
import 'package:tpg316c_assignment/services/supabase_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Application> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Application> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _supabaseService.getApplications();
      _applications =
          response.map((json) => Application.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Failed to fetch applications: $error';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitApplication({
    required String studentNumber,
    required String yearOfStudy,
    required String academicLevel,
    required String module1,
    String? module2,
    String? documentUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _supabaseService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final Map<String, dynamic> applicationData = {
        'user_id': userId,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'academic_level': academicLevel,
        'module_1': module1,
        'module_2': module2,
        'document_url': documentUrl,
        'status': 'Pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.submitApplication(applicationData);

      try {
        await fetchApplications();
      } catch (_) {}
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } catch (error) {
      _errorMessage = 'Failed to submit application: $error';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateApplication(
    String id, {
    required String studentNumber,
    required String yearOfStudy,
    required String academicLevel,
    required String module1,
    String? module2,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final applicationData = {
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'academic_level': academicLevel,
        'module_1': module1,
        'module_2': module2,
        'status': status,
      };
      await _supabaseService.updateApplication(id, applicationData);
      await fetchApplications();
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Failed to update application: $error';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Deletes an application and selectively refreshes either the admin global list or student list
  Future<void> deleteApplication(String id,
      {bool isAdminContext = false}) async {
    _errorMessage = null;

    //  If admin context, update local list instantly without a full-screen loading flash
    if (isAdminContext) {
      _applications.removeWhere((app) => app.id == id);
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _supabaseService.deleteApplication(id);

      // Synced validation backup fetch
      if (isAdminContext) {
        final response = await _supabaseService.getAllApplicationsForAdmin();
        _applications =
            response.map((json) => Application.fromJson(json)).toList();
      } else {
        await fetchApplications();
      }
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Failed to delete application: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Admin Specific Functions (Optimized State Routing)
  // ==========================================

  Future<void> fetchAllApplicationsForAdmin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _supabaseService.getAllApplicationsForAdmin();
      _applications =
          response.map((json) => Application.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Failed to fetch all applications: $error';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    _errorMessage = null;

    // Utilizes your model's clean copyWith method to retain nested student profile data flawlessly!
    final index = _applications.indexWhere((app) => app.id == id);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(status: status);
      notifyListeners();
    }

    try {
      // 1. Write status change to Supabase
      await _supabaseService.updateApplicationStatus(id, status);

      // 2. Fetch the updated dataset quietly to keep data accurate
      final response = await _supabaseService.getAllApplicationsForAdmin();
      _applications =
          response.map((json) => Application.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Failed to update application status: $error';
    } finally {
      _isLoading = false;
      notifyListeners(); // Final structural synchronized UI sync
    }
  }
}
