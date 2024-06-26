import 'package:flutter/material.dart';

class Calculos extends StatefulWidget {
  const Calculos({Key? key}) : super(key: key);

  @override
  _CalculosState createState() => _CalculosState();
}

class _CalculosState extends State<Calculos> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  double _totalLitros = 0.0;
  double _totalPagar = 0.0;

  void _calcularEstadisticas() {
    final nombre = _nombreController.text;
    final cedula = _cedulaController.text;
    final precio = double.tryParse(_precioController.text) ?? 0.0;

    // Simular datos de litros recolectados con nombre y cédula
    final Map<String, Map<String, List<double>>> litrosDiarios = {
      'Productor1': {
        '1111111111': [10.0, 15.0, 20.0],
      },
      'Productor2': {
        '2222222222': [12.0, 18.0, 25.0],
      },
      'Productor3': {
        '3333333333': [8.0, 13.0, 22.0],
      },
    };

    bool productorEncontrado = false;

    litrosDiarios.forEach((prodNombre, data) {
      if (prodNombre == nombre || data.containsKey(cedula)) {
        _totalLitros = data.values.fold(0.0, (prev, element) => prev + element.fold(0.0, (subPrev, subElement) => subPrev + subElement));
        _totalPagar = _totalLitros * precio;
        productorEncontrado = true;
      }
    });

    if (!productorEncontrado) {
      _totalLitros = 0.0;
      _totalPagar = 0.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Productor no encontrado.'),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cálculos Acopio Rosita"),
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
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula del Productor',
              ),
              keyboardType: TextInputType.number,
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
              onPressed: _calcularEstadisticas,
              child: Text('Calcular'),
            ),
            SizedBox(height: 20),
            Text('Total de Litros: $_totalLitros'),
            Text('Total a Pagar: $_totalPagar'),
          ],
        ),
      ),
    );
  }
}
