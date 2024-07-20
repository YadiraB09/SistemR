import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  void _login(BuildContext context) async {
    String cedula = _cedulaController.text;
    String password = _passwordController.text;

    if (cedula.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cédula y contraseña son requeridas')),
      );
      return;
    }

    final response = await supabase
        .from('Users')
        .select()
        .eq('Cedula', cedula)
        .eq('Password', password)
        .single()
        .execute();

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error al conectar a Supabase: ${response.error!.message}'),
        ),
      );
      return;
    }

    final data = response.data;

    if (data != null) {
      final userRol = data['rol'];
      final userId = data['id'];
      print(data);
      switch (userRol) {
        case "Recolectores":
          // mostrar recolectores
          context.pushReplacement(AppRoutes.recolectores);
          break;
        case "Productores":
          // mostrar recolectores
          context.pushReplacement(Uri(
              path: AppRoutes.productores,
              queryParameters: {"user_id": userId}).toString());
          break;
        default:
          // mostrar notificacion de error
          print("data default: $data");
          break;
      }

      // if (userRole == 'Recolectores') {
      //   context.pushReplacement(AppRoutes.recolectores);
      // } else if (userRole == 'Productores') {
      //   // Autenticamos al usuario en Supabase
      //   final authResponse = await supabase.auth.signIn(
      //     email: cedula, // O el email correspondiente si tienes uno
      //     password: password,
      //   );

      //   if (authResponse.error != null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Error al autenticar: ${authResponse.error!.message}'),
      //       ),
      //     );
      //   } else {
      //     context.pushReplacement(AppRoutes.productores);
      //   }
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Rol no reconocido')),
      //   );
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cédula o contraseña incorrecta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ACOPIO ROSITA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.vsun.es/pics/2024/01/18/dibujos-de-vaca-para-colorear-5.jpg',
                height: 150,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () async {
                  String cedula = _cedulaController.text;
                  String password = _passwordController.text;

                  if (cedula.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cédula y contraseña son requeridas')),
                    );
                    return;
                  }

                  final response = await supabase
                      .from('Users')
                      .select()
                      .eq('Cedula', cedula)
                      .eq('Password', password)
                      .single()
                      .execute();

                  if (response.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error al conectar a Supabase: ${response.error!.message}'),
                      ),
                    );
                    return;
                  }

                  final data = response.data;

                  if (data != null) {
                    final userRol = data['rol'];
                    final userId = data['id'];
                    print(data);
                    switch (userRol) {
                      case "Recolectores":
                        // mostrar recolectores
                        context.pushReplacement(AppRoutes.recolectores);
                        break;
                      case "Productores":
                        // mostrar recolectores
                        context.pushReplacement(
                          Uri(
                            path: AppRoutes.productores,
                            queryParameters: {"user_id": userId.toString()},
                          ).toString(),
                        );
                        return;
                      default:
                        // mostrar notificacion de error
                        print("data default: $data");
                        break;
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cédula o contraseña incorrecta')),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
