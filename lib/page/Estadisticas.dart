import 'package:flutter/material.dart';

class Estadisticas extends StatefulWidget {
  const Estadisticas({super.key});

  @override
  _EstadisticasState createState() => _EstadisticasState();
}

class _EstadisticasState extends State<Estadisticas> {
  final TextEditingController _precioController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalLitros = 0.0;
  double _totalPagar = 0.0;

  // Simular datos de litros recolectados
  final Map<DateTime, double> litrosComprados = {
    DateTime.utc(2024, 6, 1): 10.0,
    DateTime.utc(2024, 6, 2): 15.0,
    DateTime.utc(2024, 6, 15): 20.0,
    DateTime.utc(2024, 7, 1): 12.0,
    DateTime.utc(2024, 7, 5): 18.0,
    DateTime.utc(2024, 7, 15): 25.0,
    DateTime.utc(2024, 8, 1): 8.0,
    DateTime.utc(2024, 8, 10): 13.0,
    DateTime.utc(2024, 8, 20): 22.0,
  };

  void _calcularEstadisticas() {
    final precio = double.tryParse(_precioController.text) ?? 0.0;

    if (_startDate != null && _endDate != null) {
      _totalLitros = 0.0;
      _totalPagar = 0.0;

      litrosComprados.forEach((fecha, litros) {
        if (fecha.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            fecha.isBefore(_endDate!.add(const Duration(days: 1)))) {
          _totalLitros += litros;
        }
      });

      _totalPagar = _totalLitros * precio;

      setState(() {});
    } else {
      // Reset values if dates not selected
      _totalLitros = 0.0;
      _totalPagar = 0.0;

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fechas no seleccionadas.'),
          ),
        );
      });
    }
  }

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2024, 12),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadisticas")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("This is a login Page"),
              TextField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio por Litro',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: const Text('Seleccionar Rango de Fechas'),
              ),
              if (_startDate != null && _endDate != null)
                Text('Rango Seleccionado: ${_startDate!.toLocal()} - ${_endDate!.toLocal()}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calcularEstadisticas,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 20),
              Text('Total de Litros: $_totalLitros'),
              Text('Total a Pagar: $_totalPagar'),
            ],
          ),
        ),
      ),
    );
  }
}
