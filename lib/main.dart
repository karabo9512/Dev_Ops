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
import 'package:provider/provider.dart';

import 'package:tpg316c_assignment/services/supabase_service.dart';
import 'package:tpg316c_assignment/viewmodels/application_viewmodel.dart';
import 'package:tpg316c_assignment/views/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ajhlqklnvabfyvfpiskr.supabase.co',
    anonKey: 'sb_publishable_dGQSc4lYkOth0Q-yZ8ZsVA_24TEzKHj',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(
          create: (_) => SupabaseService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Assistant Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
