import 'package:flutter/material.dart' ;
import 'package:myapp/routes/app_routes.dart';
import 'package:myapp/supabase_config.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'News App',
      routerConfig: routes,
    );
  }
}