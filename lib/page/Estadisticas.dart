import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Estadisticas extends StatefulWidget {
  const Estadisticas({Key? key}) : super(key: key);

  @override
  _EstadisticasState createState() => _EstadisticasState();
}

class _EstadisticasState extends State<Estadisticas> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _reportData = [];

  void _fetchReportData() async {
    if (_startDate != null && _endDate != null) {
      final response = await Supabase.instance.client
          .from('Costos')
          .select('productor_id, litros_totales, costo_total, precio, fecha')
          .gte('fecha', _startDate)
          .lte('fecha', _endDate)
          .execute();

      if (response.error == null) {
        final data = response.data as List<dynamic>;

        // Obtener los IDs de los productores
        List<int> productorIds =
            data.map((item) => item['productor_id'] as int).toList();

        // Consultar los nombres de los productores
        final productoresResponse = await Supabase.instance.client
            .from('Productores')
            .select('id, nombre, cedula')
            .in_('id', productorIds)
            .execute();

        if (productoresResponse.error == null) {
          final productoresData = productoresResponse.data as List<dynamic>;
          final productoresMap = Map.fromIterable(
            productoresData,
            key: (item) => item['id'],
            value: (item) =>
                {'nombre': item['nombre'], 'cedula': item['cedula']},
          );

          // Combinar datos
          for (var item in data) {
            final productorInfo = productoresMap[item['productor_id']];
            if (productorInfo != null) {
              _reportData.add({
                'nombre': productorInfo['nombre'],
                'cedula': productorInfo['cedula'],
                'litros_totales': item['litros_totales'],
                'costo_total': item['costo_total'],
                'precio': item['precio'],
                'fecha': DateTime.parse(item['fecha'])
                    .toLocal()
                    .toString()
                    .split(' ')[0],
              });
            }
          }
        } else {
          _showErrorSnackBar(
              'Error al obtener los productores: ${productoresResponse.error!.message}');
        }

        setState(() {});
      } else {
        _showErrorSnackBar(
            'Error al obtener los costos: ${response.error!.message}');
      }
    } else {
      _showErrorSnackBar('Fechas no seleccionadas.');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Estadísticas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: const Text('Seleccionar Rango de Fechas',
                    style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
              ),
              if (_startDate != null && _endDate != null)
                Text(
                    'Rango Seleccionado: ${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchReportData,
                child: const Text('Generar Reporte',
                    style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _reportData.length,
                  itemBuilder: (context, index) {
                    final item = _reportData[index];
                    return ListTile(
                      title: Text(
                          'Nombre: ${item['nombre']}, Cédula: ${item['cedula']}'),
                      subtitle:
                          Text('Litros Totales: ${item['litros_totales']}, '
                              'Costo Total: ${item['costo_total']}, '
                              'Precio por Litro: ${item['precio']}, '
                              'Fecha: ${item['fecha']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
