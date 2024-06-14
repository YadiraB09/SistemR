//*import 'package:app_sistem_r_news/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:myapp/routes/app_routes.dart';

void main() => runApp(const MyApp());

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
