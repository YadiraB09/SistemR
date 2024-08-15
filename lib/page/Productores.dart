// ignore: file_names
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_routes.dart'; // Asegúrate de importar las rutas

class Productores extends StatefulWidget {
  final int? userId;
  const Productores({super.key, this.userId});

  @override
  ProductoresState createState() => ProductoresState();
}

class ProductoresState extends State<Productores> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotificaciones(widget.userId);
    _subscribeToRealtime();
  }

  Future<void> _fetchNotificaciones(int? id) async {
    setState(() {
      _isLoading = true;
    });
    print("Id in fetchNotificaciones: $id");
    final notificationsByUser = await supabase
        .from('Notificaciones')
        .select()
        .eq('user_id', id)
        .execute();

    print(
        'Current user: ${notificationsByUser.data}'); // Debug: Verifica el usuario actual

    if (notificationsByUser.data != null) {
      try {
        setState(() {
          _notificaciones = notificationsByUser.data;
          _isLoading = false;
        });
      } catch (e) {
        _showErrorSnackBar('Error desconocido: $e');
        setState(() {
          _isLoading = false;
        });
        print('Error desconocido: $e');
      }
    } else {
      _showErrorSnackBar('No se encontró usuario autenticado.');
      setState(() {
        _isLoading = false;
      });
      print('No se encontró usuario autenticado.');
    }
  }

  void _subscribeToRealtime() {
    final user = Supabase.instance.client.auth.currentUser;
    print(
        'Subscribing to realtime updates for user: ${user?.id}'); // Debug: Verifica el usuario antes de suscribirse

    if (user != null) {
      final subscription = Supabase.instance.client
          .from('Notificaciones:user_id=eq.${user.id}')
          .on(SupabaseEventTypes.insert, (payload) {
        final newRecord = payload.newRecord;
        print(
            'Realtime payload: $payload'); // Debug: Verifica el payload en tiempo real

        if (newRecord != null) {
          setState(() {
            _notificaciones.add(newRecord as Map<String, dynamic>);
          });
          print('Nueva notificación en tiempo real: $newRecord');
        } else {
          print('Nuevo registro en tiempo real es nulo.');
        }
      }).subscribe();

      Supabase.instance.client.getSubscriptions().add(subscription);
    }
  }

  void _showErrorSnackBar(String message) {
    print("Error prod page: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleRefresh() async {
    await _fetchNotificaciones(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    print('_isLoading: $_isLoading');
    print('_notificaciones: $_notificaciones');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navegar a la página de login
              context.go(AppRoutes
                  .login); // Asegúrate de que AppRoutes.login esté configurada correctamente
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                itemCount: _notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = _notificaciones[index];
                  return ListTile(
                    title: Text(notificacion['message']),
                    subtitle: Text(notificacion['created_at']),
                    trailing: notificacion['is_read']
                        ? null
                        : const Icon(Icons.circle,
                            color: Color.fromARGB(255, 22, 124, 47)),
                  );
                },
              ),
            ),
    );
  }
}
