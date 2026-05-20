class Application {
  final String id;
  final String userId;
  final String yearOfStudy;
  final String academicLevel;
  final String module1;
  final String? module2;
  final String status;
  final DateTime createdAt;
  final String? documentUrl;

  // Relational field from joined 'profiles' table
  final String? studentEmail;

  // Direct column field from the 'applications' table
  final String? studentNumber;

  Application({
    required this.id,
    required this.userId,
    required this.yearOfStudy,
    required this.academicLevel,
    required this.module1,
    this.module2,
    required this.status,
    required this.createdAt,
    this.documentUrl,
    this.studentEmail,
    this.studentNumber,
  });

  //  copyWith to support both email and student number
  Application copyWith({
    String? id,
    String? userId,
    String? yearOfStudy,
    String? academicLevel,
    String? module1,
    String? module2,
    String? status,
    DateTime? createdAt,
    String? documentUrl,
    String? studentEmail,
    String? studentNumber,
  }) {
    return Application(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      academicLevel: academicLevel ?? this.academicLevel,
      module1: module1 ?? this.module1,
      module2: module2 ?? this.module2,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      documentUrl: documentUrl ?? this.documentUrl,
      studentEmail: studentEmail ?? this.studentEmail,
      studentNumber: studentNumber ?? this.studentNumber,
    );
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    // Handle the nested relational 'profiles' data map from Supabase for the email
    final profile = json['profiles'];

    return Application(
      id: json["id"].toString(),
      userId: json["user_id"] ?? '',
      yearOfStudy: json["year_of_study"] ?? '',
      academicLevel: json["academic_level"] ?? '',
      module1: json["module_1"] ?? '',
      module2: json["module_2"],
      status: json["status"] ?? 'Pending',
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
      documentUrl: json["document_url"],

      // Read email from the nested profile map relation
      studentEmail: profile != null ? profile['email'] : null,

      //  Reads directly from the root json payload because 'student_number' belongs to the applications table
      studentNumber: json['student_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "year_of_study": yearOfStudy,
      "academic_level": academicLevel,
      "module_1": module1,
      "module_2": module2,
      "status": status,
      "created_at": createdAt.toIso8601String(),
      "document_url": documentUrl,
      // Added tracking serialization back up to the database table
      "student_number": studentNumber,
    };
  }
}
