import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  String _selectedRole = 'Recolector';

  void _login() async {
    String cedula = _cedulaController.text;
    String password = _passwordController.text;

    final response = await supabase
        .from('usuarios')
        .select()
        .eq('Cedula', cedula)
        .eq('password', password)
        .execute();

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar a Supabase: ${response.error!.message}')),
      );
      return;
    }

    final data = response.data;
    if (data.isNotEmpty) {
      final userRole = data[0]['rol'];
      if (userRole == 'Productor') {
        Navigator.pushReplacementNamed(context, '/productores');
      } else if (userRole == 'Recolector') {
        Navigator.pushReplacementNamed(context, '/recolectores');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol no reconocido')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cédula o contraseña incorrecta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is a login Page"),
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
            DropdownButton<String>(
              value: _selectedRole,
              items: <String>['Recolector', 'Productor']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
