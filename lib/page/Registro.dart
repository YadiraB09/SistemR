import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registrar extends StatefulWidget {
  const Registrar({Key? key}) : super(key: key);

  @override
  _RegistrarState createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _litrosEditarController = TextEditingController();

  List<Map<String, dynamic>> _productores = [];
  List<Map<String, dynamic>> _productoresFiltrados = [];
  List<Map<String, dynamic>> _producciones = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final responseProductores =
        await Supabase.instance.client.from('Productores').select().execute();

    final responseProducciones =
        await Supabase.instance.client.from('Produccion').select().execute();

    if (responseProductores.error == null &&
        responseProducciones.error == null) {
      final dataProductores = responseProductores.data as List<dynamic>;
      final dataProducciones = responseProducciones.data as List<dynamic>;

      setState(() {
        _productores = dataProductores
            .map((item) => item as Map<String, dynamic>)
            .toList();
        _productoresFiltrados = _productores;
        _producciones = dataProducciones
            .map((item) => item as Map<String, dynamic>)
            .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al obtener datos: ${responseProductores.error!.message}')),
      );
    }
  }

  Future<void> _registrarProductor() async {
    final nombre = _nombreController.text;
    final cedula = _cedulaController.text;

    if (nombre.isEmpty || cedula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese todos los campos')),
      );
      return;
    }

    final productorData = {
      'nombre': nombre,
      'cedula': cedula,
    };

    final response = await Supabase.instance.client
        .from('Productores')
        .insert(productorData)
        .execute();

    if (response.error == null) {
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Productor registrado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al registrar productor: ${response.error!.message}')),
      );
    }

    _nombreController.clear();
    _cedulaController.clear();
  }

  Future<void> _registrarLitros(int productorId) async {
    final litros = double.tryParse(_litrosController.text) ?? 0.0;

    if (litros <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese litros válidos')),
      );
      return;
    }

    final produccionData = {
      'productor_id': productorId,
      'litros': litros,
      'fecha': DateTime.now().toIso8601String(),
    };

    final response = await Supabase.instance.client
        .from('Produccion')
        .insert(produccionData)
        .execute();

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Litros registrados exitosamente')),
      );
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al registrar litros: ${response.error!.message}')),
      );
    }

    _litrosController.clear();
  }

  Future<void> _editarLitros(int produccionId) async {
    final nuevoLitro = double.tryParse(_litrosEditarController.text) ?? 0.0;

    if (nuevoLitro <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese litros válidos')),
      );
      return;
    }

    final response = await Supabase.instance.client
        .from('Produccion')
        .update({'litros': nuevoLitro})
        .eq('id', produccionId)
        .execute();

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Litros actualizados correctamente')),
      );
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al actualizar litros: ${response.error!.message}')),
      );
    }

    _litrosEditarController.clear();
  }

  Future<void> _eliminarLitros(int produccionId) async {
    final response = await Supabase.instance.client
        .from('Produccion')
        .delete()
        .eq('id', produccionId)
        .execute();

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Litro eliminado correctamente')),
      );
      _fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al eliminar litro: ${response.error!.message}')),
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
        title: Text(
          "Registrar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/calculos');
            },
            child: Text('Cálculos', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/estadisticas');
            },
            child: Text('Estadísticas', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              ElevatedButton(
                onPressed: _registrarProductor,
                child: Text('Registrar Productor'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 20),
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
              ListView.builder(
                shrinkWrap: true, // Permite que ListView se ajuste al contenido
                physics:
                    NeverScrollableScrollPhysics(), // Desactiva el desplazamiento
                itemCount: _productoresFiltrados.length,
                itemBuilder: (context, index) {
                  final productor = _productoresFiltrados[index];
                  final nombre = productor['nombre'];
                  final cedula = productor['cedula'];
                  final id = productor['id'];

                  final produccionesProductor = _producciones
                      .where((prod) => prod['productor_id'] == id)
                      .toList();

                  return Card(
                    child: ListTile(
                      title: Text(nombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cédula: $cedula'),
                          SizedBox(height: 5),
                          Text('Litros Registrados:'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: produccionesProductor
                                .map((prod) => ListTile(
                                      title: Text(
                                          '${prod['litros']} litros - ${DateTime.parse(prod['fecha']).toLocal().toString().split(' ')[0]}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              _litrosEditarController.text =
                                                  prod['litros'].toString();
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Editar Litros'),
                                                  content: TextField(
                                                    controller:
                                                        _litrosEditarController,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Nuevo valor de litros',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Cancelar'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _editarLitros(
                                                            prod['id']);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Guardar'),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .black),
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Eliminar Litro'),
                                                  content: Text(
                                                      '¿Estás seguro de que deseas eliminar este registro de litros?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Cancelar'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _eliminarLitros(
                                                            prod['id']);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Eliminar'),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .black),
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _litrosController,
                            decoration: InputDecoration(
                              labelText: 'Litros Comprados',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              _registrarLitros(id);
                            },
                            child: Text('Registrar Litros'),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
