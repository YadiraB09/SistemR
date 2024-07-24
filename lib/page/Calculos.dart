import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Calculos extends StatefulWidget {
  const Calculos({super.key});

  @override
  _CalculosState createState() => _CalculosState();
}

class _CalculosState extends State<Calculos> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  List<Map<String, dynamic>> _productores = [];
  List<Map<String, dynamic>> _producciones = [];
  List<Map<String, dynamic>> _produccionesDelProductor = [];
  bool _isLoading = false;
  Map<String, dynamic>? _selectedProductor;
  double _totalLitros = 0.0;
  double _costoTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final responseProductores =
        await Supabase.instance.client.from('Productores').select().execute();

    final responseProducciones =
        await Supabase.instance.client.from('Produccion').select().execute();

    if (responseProductores.error == null &&
        responseProducciones.error == null) {
      setState(() {
        _productores =
            List<Map<String, dynamic>>.from(responseProductores.data);
        _producciones =
            List<Map<String, dynamic>>.from(responseProducciones.data);
        _isLoading = false;
      });
    } else {
      _showErrorSnackBar(
          'Error al obtener datos: ${responseProductores.error?.message ?? 'Unknown error'}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchProductor() {
    final query = _searchController.text.toLowerCase().trim();
    final productor = _productores.firstWhere(
      (prod) =>
          prod['nombre'].toString().toLowerCase().trim() == query ||
          prod['cedula'].toString().toLowerCase().trim() == query,
      orElse: () => {},
    );

    if (productor.isNotEmpty) {
      setState(() {
        _selectedProductor = productor;
        _produccionesDelProductor = _producciones
            .where(
                (produccion) => produccion['productor_id'] == productor['id'])
            .toList();
        _totalLitros = _calculateTotalLitros(productor['id']);
      });
    } else {
      _showErrorSnackBar('Productor no encontrado');
    }
  }

  double _calculateTotalLitros(int productorId) {
    return _producciones
        .where((produccion) => produccion['productor_id'] == productorId)
        .fold(
            0.0,
            (total, produccion) =>
                total + (double.tryParse(produccion['litros']) ?? 0.0));
  }

  Future<void> _calcularTotalLitros(
      int productorId, double precioPorLitro) async {
    double totalLitros = _calculateTotalLitros(productorId);
    double costoTotal = totalLitros * precioPorLitro;

    if (_selectedProductor != null) {
      final costoData = {
        'productor_id': productorId,
        'litros_totales': totalLitros,
        'precio': precioPorLitro,
        'costo_total': costoTotal,
        'fecha': DateTime.now().toIso8601String(),
      };

      setState(() {
        _costoTotal = costoTotal;
      });

      final response = await Supabase.instance.client
          .from('Costos')
          .insert([costoData]).execute();

      if (response.error == null) {
        _showSuccessSnackBar('Costo calculado y guardado correctamente');
      } else {
        _showErrorSnackBar(
            'Error al calcular costo: ${response.error?.message ?? 'Unknown error'}');
      }
    } else {
      _showErrorSnackBar('Error: No se ha seleccionado ningún productor');
    }
  }

  Future<void> _enviarNotificacion() async {
    if (_selectedProductor == null) {
      _showErrorSnackBar('Seleccione un productor primero');
      return;
    }

    final productorId = _selectedProductor!['id'];
    final productorCedula = _selectedProductor!['cedula'];

    print(
        'Consultando credenciales para productor con cédula: $productorCedula');

    final responseUser = await Supabase.instance.client
        .from('Users')
        .select()
        .eq('Cedula', productorCedula)
        .eq('rol', 'Productores')
        .execute();

    if (responseUser.error != null) {
      _showErrorSnackBar(
          'Error al consultar credenciales: ${responseUser.error!.message}');
      print('Error al consultar credenciales: ${responseUser.error!.message}');
      return;
    }

    if (responseUser.data.isEmpty) {
      _showErrorSnackBar('El productor no posee credenciales de login.');
      print('El productor no posee credenciales de login.');
      return;
    }

    final userId = responseUser.data[0]['id'];
    print(
        'Credenciales encontradas. Enviando notificación al usuario con ID: $userId');

    final notificationData = {
      'user_id': userId,
      'productor_id': productorId,
      'message':
          'Litros Registrados: $_totalLitros, Precio por Litro: ${_precioController.text}, Costo Total: $_costoTotal',
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
    };

    final notificationResponse = await Supabase.instance.client
        .from('Notificaciones')
        .insert([notificationData]).execute();

    if (notificationResponse.error != null) {
      _showErrorSnackBar(
          'Error al enviar notificación: ${notificationResponse.error!.message}');
      print(
          'Error al enviar notificación: ${notificationResponse.error!.message}');
    } else {
      _showSuccessSnackBar('Notificación enviada al productor.');
      print('Notificación enviada al productor.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onCalcularButtonPressed() async {
    final precioPorLitro = double.tryParse(_precioController.text);
    if (precioPorLitro == null || precioPorLitro < 0) {
      _showErrorSnackBar('Ingrese un precio válido por litro (no negativo)');
    } else {
      await _calcularTotalLitros(_selectedProductor!['id'], precioPorLitro);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cálculos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/registrar');
            },
            child:
                const Text('Registrar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/estadisticas');
            },
            child: const Text('Estadísticas',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar Productor por Nombre o Cédula',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchProductor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedProductor != null) ...[
                      Text(
                          'Nombre del Productor: ${_selectedProductor!['nombre']}'),
                      Text('Cédula: ${_selectedProductor!['cedula']}'),
                      Text('Litros Registrados: $_totalLitros'),
                      const SizedBox(height: 10),
                      const Text('Detalles de Producciones:'),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _produccionesDelProductor.length,
                        itemBuilder: (context, index) {
                          final produccion = _produccionesDelProductor[index];
                          return ListTile(
                            title: Text('Fecha: ${produccion['fecha']}'),
                            subtitle: Text('Litros: ${produccion['litros']}'),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Calcular Costo Total'),
                              content: TextField(
                                controller: _precioController,
                                decoration: const InputDecoration(
                                  labelText: 'Precio por Litro',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: _onCalcularButtonPressed,
                                  child: const Text('Calcular'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                        ),
                        child: const Text('Calcular Costo Total'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _enviarNotificacion,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                        ),
                        child: const Text('Enviar Notificación'),
                      ),
                      const SizedBox(height: 10),
                      if (_costoTotal > 0) Text('Costo Total: $_costoTotal'),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
