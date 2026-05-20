import 'dart:io';
import 'dart:typed_data'; // Resolves Undefined class 'Uint8List'
import 'package:flutter/foundation.dart'
    show kIsWeb; // FIX: Resolves Undefined name 'kIsWeb'
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Getter for the SupabaseClient instance
  SupabaseClient get supabaseClient => _supabaseClient;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-in.');
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final AuthResponse response =
          await _supabaseClient.auth.signUp(email: email, password: password);
      if (response.user == null) {
        // If email confirmation is enabled, user might be null here.
        // Supabase sends a confirmation email, and user will be available after confirmation.
        throw Exception(
            'Sign up successful! Please check your email for a confirmation link.');
      }
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-up.');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-out.');
    }
  }

  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  // --- Password Reset Functionality ---
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        // Ensure this redirectTo URL is configured in your Supabase project's Auth settings
        // under 'Redirect URLs' and 'Email Templates' for password reset.
        redirectTo: 'io.supabase.studentapp://reset-password/',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to send password reset email.');
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update password.');
    }
  }

  // --- File Storage Functionality ---
  // Uploads a file to a specified bucket and path, returns the public URL
  Future<String> uploadFile({
    File? file,
    Uint8List? bytes,
    required String bucketName,
    required String path,
  }) async {
    if (kIsWeb && bytes != null) {
      // Web Upload using clean binary stream data
      await _supabaseClient.storage.from(bucketName).uploadBinary(path, bytes);
    } else if (file != null) {
      // Mobile Upload using direct device storage reference path
      await _supabaseClient.storage.from(bucketName).upload(path, file);
    } else {
      throw Exception("No file data provided");
    }

    return _supabaseClient.storage.from(bucketName).getPublicUrl(path);
  }

  // Example for fetching applications (replace with actual table and columns)
  Future<List<Map<String, dynamic>>> getApplications() async {
    try {
      final response = await _supabaseClient
          .from('applications')
          .select('*')
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .order('created_at', ascending: false);
      return response;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while fetching applications.');
    }
  }

  // Example for submitting an application
  Future<void> submitApplication(Map<String, dynamic> applicationData) async {
    try {
      await _supabaseClient.from('applications').insert(applicationData);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while submitting application.');
    }
  }

  // Example for updating an application
  Future<void> updateApplication(
      String id, Map<String, dynamic> applicationData) async {
    try {
      await _supabaseClient
          .from('applications')
          .update(applicationData)
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while updating application.');
    }
  }

  // Example for deleting an application
  Future<void> deleteApplication(String id) async {
    try {
      await _supabaseClient.from('applications').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while deleting application.');
    }
  }

  // Admin functions (requires RLS policies for admin access)
  Future<List<Map<String, dynamic>>> getAllApplicationsForAdmin() async {
    try {
      // Now requests both 'email' and 'student_number' text columns from public.profiles
      final response = await _supabaseClient
          .from('applications')
          .select('*, profiles(email, student_number)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while fetching all applications for admin.');
    }
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    try {
      await _supabaseClient
          .from('applications')
          .update({'status': status}).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'An unexpected error occurred while updating application status.');
    }
  }
}
