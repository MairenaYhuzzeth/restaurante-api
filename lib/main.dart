import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const RestaurantApp());

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menú de Restaurante',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MenuHomeScreen(),
    );
  }
}

class Platillo {
  final int id;
  final String nombre;
  final String categoria;
  final double precio;
  final String descripcion;

  Platillo({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.descripcion,
  });

  factory Platillo.fromJson(Map<String, dynamic> json) {
    return Platillo(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? 'Comidas',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] ?? '',
    );
  }
}

class MenuHomeScreen extends StatefulWidget {
  const MenuHomeScreen({super.key});

  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  bool _esAdministrador = false;
  List<Platillo> _platillos = [];
  bool _cargando = true;

  // URL base de tu API en Render
  final String baseUrl = 'https://restaurante-api-qf0s.onrender.com';

  @override
  void initState() {
    super.initState();
    _obtenerPlatillos();
  }

  // 1. OBTENER PLATILLOS (GET) -> Apuntando a /api/menu
  Future<void> _obtenerPlatillos() async {
    setState(() => _cargando = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/menu'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _platillos = body.map((item) => Platillo.fromJson(item)).toList();
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
        _mostrarError('Error al cargar el menú (${response.statusCode})');
      }
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error de conexión con el servidor: $e');
    }
  }

  // 2. AGREGAR PLATILLO (POST) -> Apuntando a /api/menu
  Future<void> _agregarPlatillo(
    String nombre,
    String categoria,
    double precio,
    String descripcion,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/menu'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "categoria": categoria,
          "precio": precio,
          "descripcion": descripcion,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _obtenerPlatillos(); // Recargar la lista desde la API
      } else {
        _mostrarError('No se pudo guardar el platillo');
      }
    } catch (e) {
      _mostrarError('Error al enviar datos: $e');
    }
  }

  // 3. ELIMINAR PLATILLO (DELETE) -> Apuntando a /api/menu/{id}
  Future<void> _eliminarPlatillo(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/menu/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _obtenerPlatillos(); // Recargar la lista
      } else {
        _mostrarError('No se pudo eliminar el platillo');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _agregarPlatilloModal() {
    final nombreController = TextEditingController();
    final categoriaController = TextEditingController(text: 'Comidas');
    final precioController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Platillo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (Comidas, Bebidas, Postres)',
                ),
              ),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = nombreController.text;
              final categoria = categoriaController.text;
              final precio = double.tryParse(precioController.text) ?? 0.0;
              final descripcion = descController.text;

              if (nombre.isNotEmpty && precio > 0) {
                _agregarPlatillo(nombre, categoria, precio, descripcion);
                Navigator.pop(context);
              } else {
                _mostrarError('Completa los campos correctamente');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = _platillos.map((p) => p.categoria).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esAdministrador ? 'Panel de Administrador' : 'Menú del Restaurante',
        ),
        actions: [
          Row(
            children: [
              Text(
                _esAdministrador ? 'Admin' : 'Cliente',
                style: const TextStyle(fontSize: 12),
              ),
              Switch(
                value: _esAdministrador,
                onChanged: (val) => setState(() => _esAdministrador = val),
              ),
            ],
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _platillos.isEmpty
          ? const Center(
              child: Text('No hay platillos disponibles en el servidor.'),
            )
          : RefreshIndicator(
              onRefresh: _obtenerPlatillos,
              child: ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  final itemsCat = _platillos
                      .where((p) => p.categoria == categoria)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      ...itemsCat.map(
                        (platillo) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              platillo.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(platillo.descripcion),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${platillo.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: _esAdministrador
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _eliminarPlatillo(platillo.id),
                                  )
                                : const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: _esAdministrador
          ? FloatingActionButton.extended(
              onPressed: _agregarPlatilloModal,
              label: const Text('Agregar Platillo'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}
