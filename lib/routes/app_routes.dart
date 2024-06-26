import 'package:go_router/go_router.dart';
import 'package:myapp/page/Calculos.dart';
import 'package:myapp/page/Estadisticas.dart';
import 'package:myapp/page/Productores.dart';
import 'package:myapp/page/Recolectores.dart';
import 'package:myapp/page/home.dart';
import 'package:myapp/page/login.dart';

class AppRoutes {
  static String home = '/';
  static String login = '/login';
  static String estadisticas = '/estadisticas';
  static String productores = '/productores';
  static String recolectores = '/recolectores';
  static String calculos = '/calculos';
}

final routes = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: AppRoutes.estadisticas,
      builder: (context, state) => const Estadisticas(),
    ),
    GoRoute(
      path: AppRoutes.productores,
      builder: (context, state) => const Productores(),
    ),
    GoRoute(
      path: AppRoutes.recolectores,
      builder: (context, state) => const Recolectores(),
    ),
    GoRoute(
      path: AppRoutes.calculos,
      builder: (context, state) => const Calculos(),
    ),
  ],
);
