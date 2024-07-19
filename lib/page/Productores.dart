import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Productores extends StatefulWidget {
  const Productores({Key? key}) : super(key: key);

  @override
  _ProductoresState createState() => _ProductoresState();
}

class _ProductoresState extends State<Productores> {
  List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotificaciones();
    _subscribeToRealtime();
  }

  Future<void> _fetchNotificaciones() async {
    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    print('Current user: ${user?.id}');  // Debug: Verifica el usuario actual

    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('Notificaciones')
            .select()
            .eq('user_id', user.id)
            .execute();

        print('Response status: ${response.status}');  // Debug: Verifica el estado de la respuesta
        print('Response data: ${response.data}');      // Debug: Verifica los datos de la respuesta
        print('Response error: ${response.error}');    // Debug: Verifica si hay errores en la respuesta

        if (response.error == null) {
          final data = response.data as List<dynamic>;
          setState(() {
            _notificaciones = data.map((item) => item as Map<String, dynamic>).toList();
            _isLoading = false;
          });
          if (data.isEmpty) {
            print('No se encontraron notificaciones para el usuario con ID: ${user.id}');
          } else {
            print('Notificaciones obtenidas: ${data.length}');
          }
        } else {
          _showErrorSnackBar('Error al obtener notificaciones: ${response.error!.message}');
          setState(() {
            _isLoading = false;
          });
          print('Error al obtener notificaciones: ${response.error!.message}');
        }
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
    print('Subscribing to realtime updates for user: ${user?.id}');  // Debug: Verifica el usuario antes de suscribirse

    if (user != null) {
      final subscription = Supabase.instance.client
          .from('Notificaciones:user_id=eq.${user.id}')
          .on(SupabaseEventTypes.insert, (payload) {
        final newRecord = payload.newRecord;
        print('Realtime payload: $payload');  // Debug: Verifica el payload en tiempo real

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleRefresh() async {
    await _fetchNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    print('_isLoading: $_isLoading');
    print('_notificaciones: _notificaciones');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                itemCount: _notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = _notificaciones[index];
                  return ListTile(
                    title: Text(notificacion['message']),
                    subtitle: Text(notificacion['created_at']),
                    trailing: notificacion['is_read'] ? null : Icon(Icons.circle, color: Colors.red),
                  );
                },
              ),
            ),
    );
  }
}
