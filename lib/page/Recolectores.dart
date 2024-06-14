import 'package:flutter/material.dart';

class Recolectores extends StatefulWidget {
  const Recolectores({Key? key}) : super(key: key);

  @override
  _RecolectoresState createState() => _RecolectoresState();
}

class _RecolectoresState extends State<Recolectores> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _productores = [];
  Map<String, List<double>> _litrosDiarios = {};

  void _registrarProductor() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;

      setState(() {
        _productores.add({'nombre': nombre});
        _litrosDiarios[nombre] = [];
      });

      _nombreController.clear();
    }
  }

  void _actualizarProductor(String viejoNombre, String nuevoNombre) {
    setState(() {
      final productorIndex = _productores.indexWhere((p) => p['nombre'] == viejoNombre);
      if (productorIndex != -1) {
        _productores[productorIndex]['nombre'] = nuevoNombre;
        _litrosDiarios[nuevoNombre] = _litrosDiarios.remove(viejoNombre)!;
      }
    });
  }

  void _borrarProductor(String nombre) {
    setState(() {
      _productores.removeWhere((productor) => productor['nombre'] == nombre);
      _litrosDiarios.remove(nombre);
    });
  }

  void _registrarLitros(String nombre) {
    if (_litrosController.text.isNotEmpty) {
      final litros = double.parse(_litrosController.text);

      setState(() {
        _litrosDiarios[nombre]!.add(litros);
      });

      _litrosController.clear();
    }
  }

  void _actualizarLitros(String nombre, int index, double nuevosLitros) {
    setState(() {
      _litrosDiarios[nombre]![index] = nuevosLitros;
    });
  }

  void _borrarLitros(String nombre, int index) {
    setState(() {
      _litrosDiarios[nombre]!.removeAt(index);
    });
  }

  void _searchRecolector() {
    // Implementa la lógica de búsqueda de recolectores aquí.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recolectores"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Recolector',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchRecolector,
                ),
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre del Productor'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre del productor';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registrarProductor,
                    child: Text('Registrar Productor'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _productores.length,
                itemBuilder: (context, index) {
                  final productor = _productores[index];
                  final nombre = productor['nombre'];
                  final litros = _litrosDiarios[nombre] ?? [];

                  return ListTile(
                    title: Text(nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < litros.length; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Litros: ${litros[i]}'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          final _editLitrosController = TextEditingController(text: litros[i].toString());
                                          return AlertDialog(
                                            title: Text('Editar Litros para $nombre'),
                                            content: TextField(
                                              controller: _editLitrosController,
                                              decoration: InputDecoration(labelText: 'Cantidad de Litros'),
                                              keyboardType: TextInputType.number,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  final nuevosLitros = double.parse(_editLitrosController.text);
                                                  _actualizarLitros(nombre, i, nuevosLitros);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Actualizar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _borrarLitros(nombre, i);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final _editNombreController = TextEditingController(text: nombre);
                                return AlertDialog(
                                  title: Text('Editar Nombre del Productor'),
                                  content: TextField(
                                    controller: _editNombreController,
                                    decoration: InputDecoration(labelText: 'Nombre del Productor'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final nuevoNombre = _editNombreController.text;
                                        _actualizarProductor(nombre, nuevoNombre);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Actualizar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _borrarProductor(nombre);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Registrar Litros para $nombre'),
                                  content: TextField(
                                    controller: _litrosController,
                                    decoration: InputDecoration(labelText: 'Cantidad de Litros'),
                                    keyboardType: TextInputType.number,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _registrarLitros(nombre);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Registrar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
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
