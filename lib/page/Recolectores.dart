import 'package:flutter/material.dart';



class Recolectores extends StatefulWidget {
  const Recolectores({Key? key}) : super(key: key);

  @override
  _RecolectoresState createState() => _RecolectoresState();
}

class _RecolectoresState extends State<Recolectores> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> _productores = [];
  Map<String, List<double>> _litrosDiarios = {};
  List<Map<String, String>> _productoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    _productoresFiltrados = _productores;
  }

  void _registrarProductor() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final cedula = _cedulaController.text;

      setState(() {
        _productores.add({'nombre': nombre, 'cedula': cedula});
        _litrosDiarios[cedula] = [];
        _productoresFiltrados = _productores;
      });

      _nombreController.clear();
      _cedulaController.clear();
    }
  }

  void _actualizarProductor(String viejoCedula, String nuevoNombre, String nuevoCedula) {
    setState(() {
      final productorIndex = _productores.indexWhere((p) => p['cedula'] == viejoCedula);
      if (productorIndex != -1) {
        _productores[productorIndex] = {'nombre': nuevoNombre, 'cedula': nuevoCedula};
        _litrosDiarios[nuevoCedula] = _litrosDiarios.remove(viejoCedula)!;
        _productoresFiltrados = _productores;
      }
    });
  }

  void _borrarProductor(String cedula) {
    setState(() {
      _productores.removeWhere((productor) => productor['cedula'] == cedula);
      _litrosDiarios.remove(cedula);
      _productoresFiltrados = _productores;
    });
  }

  void _registrarLitros(String cedula) {
    if (_litrosController.text.isNotEmpty) {
      final litros = double.parse(_litrosController.text);

      setState(() {
        _litrosDiarios[cedula]!.add(litros);
      });

      _litrosController.clear();
    }
  }

  void _actualizarLitros(String cedula, int index, double nuevosLitros) {
    setState(() {
      _litrosDiarios[cedula]![index] = nuevosLitros;
    });
  }

  void _borrarLitros(String cedula, int index) {
    setState(() {
      _litrosDiarios[cedula]!.removeAt(index);
    });
  }

  void _searchRecolector() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _productoresFiltrados = _productores.where((productor) {
        final nombre = productor['nombre']!.toLowerCase();
        final cedula = productor['cedula']!;
        return nombre.contains(query) || cedula.contains(query);
      }).toList();
    });
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
                labelText: 'Buscar Recolector por Nombre o Cédula',
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
                  TextFormField(
                    controller: _cedulaController,
                    decoration: InputDecoration(labelText: 'Cédula del Productor'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la cédula del productor';
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
                itemCount: _productoresFiltrados.length,
                itemBuilder: (context, index) {
                  final productor = _productoresFiltrados[index];
                  final nombre = productor['nombre']!;
                  final cedula = productor['cedula']!;
                  final litros = _litrosDiarios[cedula] ?? [];

                  return ListTile(
                    title: Text(nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cédula: $cedula'),
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
                                                  _actualizarLitros(cedula, i, nuevosLitros);
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
                                      _borrarLitros(cedula, i);
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
                                final _editCedulaController = TextEditingController(text: cedula);
                                return AlertDialog(
                                  title: Text('Editar Productor'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: _editNombreController,
                                        decoration: InputDecoration(labelText: 'Nombre del Productor'),
                                      ),
                                      TextField(
                                        controller: _editCedulaController,
                                        decoration: InputDecoration(labelText: 'Cédula del Productor'),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
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
                                        final nuevoCedula = _editCedulaController.text;
                                        _actualizarProductor(cedula, nuevoNombre, nuevoCedula);
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
                            _borrarProductor(cedula);
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
                                        _registrarLitros(cedula);
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
