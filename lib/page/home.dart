//*import 'package:app_solucion_parcial_news/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_routes.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Home"),
            TextButton(
                onPressed: () {
                  context.push(AppRoutes.login);
                },
                child: const Text("login")),
            TextButton(
                onPressed: () {
                  context.push(AppRoutes.estadisticas);
                },
                child: const Text("Estadistica ")),
            TextButton(
                onPressed: () {
                  context.push(AppRoutes.productores);
                },
                child: const Text("Productores")),
            TextButton(
                onPressed: () {
                  context.push(AppRoutes.recolectores);
                },
                child: const Text("Recolectores")),
                 TextButton(
                onPressed: () {
                  context.push(AppRoutes.calculos);
                },
                child: const Text("Calculos")),
          ],
        ),
      ),
    );
  }
}
