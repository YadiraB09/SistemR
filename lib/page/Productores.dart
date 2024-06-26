import 'package:flutter/material.dart';

class Productores extends StatefulWidget {
  const Productores({super.key});

  @override
  _ProductoresState createState() => _ProductoresState();
}

class _ProductoresState extends State<Productores> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _productores = [];
  Map<String, List<double>> _litrosDiarios = {};
  List<Map<String, dynamic>> _productoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    _productoresFiltrados = _productores;
  }

  void _registrarProductor() {
    final nombre = _nombreController.text;
    final cedula = _cedulaController.text;

    setState(() {
      _productores.add({'nombre': nombre, 'cedula': cedula});
      _litrosDiarios[cedula] = [for (var i = 0; i < 15; i++) (i + 1) * 2.0]; // Datos simulados
      _productoresFiltrados = _productores;
    });

    _nombreController.clear();
    _cedulaController.clear();
  }

  void _enviarNotificaciones() {
    final precioPorLitro = double.tryParse(_precioController.text) ?? 0.0;

    for (var productor in _productoresFiltrados) {
      final nombre = productor['nombre'];
      final cedula = productor['cedula'];
      final litros = _litrosDiarios[cedula]!;
      final totalLitros = litros.fold(0.0, (prev, element) => prev + element); // Inicializar como double
      final totalPagar = totalLitros * precioPorLitro;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notificación para $nombre:\nLitros recolectados: $totalLitros\nTotal a pagar: \$${totalPagar.toStringAsFixed(2)}',
          ),
        ),
      );
    }
  }

  void _searchProductor() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _productoresFiltrados = _productores.where((productor) {
        final nombre = productor['nombre'].toLowerCase();
        final cedula = productor['cedula'];
        return nombre.contains(query) || cedula.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PRODUCTORES"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Productor por Nombre o Cédula',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchProductor,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Productor',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula del Productor',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrarProductor,
              child: Text('Registrar Productor'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _precioController,
              decoration: InputDecoration(
                labelText: 'Precio por Litro',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _enviarNotificaciones,
              child: Text('Enviar Notificaciones'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _productoresFiltrados.length,
                itemBuilder: (context, index) {
                  final productor = _productoresFiltrados[index];
                  final nombre = productor['nombre'];
                  final cedula = productor['cedula'];

                  return ListTile(
                    title: Text('$nombre (Cédula: $cedula)'),
                    subtitle: Text('Productor registrado'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
