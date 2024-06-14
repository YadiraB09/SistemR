import 'package:flutter/material.dart';

class Productores extends StatefulWidget {
  const Productores({super.key});

  @override
  _ProductoresState createState() => _ProductoresState();
}

class _ProductoresState extends State<Productores> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  List<Map<String, dynamic>> _productores = [];
  Map<String, List<double>> _litrosDiarios = {};

  void _registrarProductor() {
    final nombre = _nombreController.text;

    setState(() {
      _productores.add({'nombre': nombre});
      _litrosDiarios[nombre] = [for (var i = 0; i < 15; i++) (i + 1) * 2.0]; // Datos simulados
    });

    _nombreController.clear();
  }

  void _enviarNotificaciones() {
    final precioPorLitro = double.tryParse(_precioController.text) ?? 0.0;

    for (var productor in _productores) {
      final nombre = productor['nombre'];
      final litros = _litrosDiarios[nombre]!;
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
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del Productor',
              ),
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
                itemCount: _productores.length,
                itemBuilder: (context, index) {
                  final productor = _productores[index];
                  final nombre = productor['nombre'];

                  return ListTile(
                    title: Text(nombre),
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
