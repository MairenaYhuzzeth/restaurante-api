import 'package:flutter/material.dart';

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
  final String id;
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
}

class MenuHomeScreen extends StatefulWidget {
  const MenuHomeScreen({super.key});

  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  bool _esAdministrador = false; // Alternar entre Cliente y Admin

  // Simulación de datos que vendrán de tu API en C#
  final List<Platillo> _platillos = [
    Platillo(id: '1', nombre: 'Hamburguesa Especial', categoria: 'Comidas', precio: 12.50, descripcion: 'Doble carne, queso cheddar y tocino crujiente.'),
    Platillo(id: '2', nombre: 'Pizza Margarita', categoria: 'Comidas', precio: 15.00, descripcion: 'Salsa de tomate artesanal, mozzarella fresca y albahaca.'),
    Platillo(id: '3', nombre: 'Limonada con Hierbabuena', categoria: 'Bebidas', precio: 3.50, descripcion: 'Refrescante limonada natural con toque de menta.'),
    Platillo(id: '4', nombre: 'Jugo de Maracuyá', categoria: 'Bebidas', precio: 4.00, descripcion: 'Jugo tropical recién exprimido.'),
    Platillo(id: '5', nombre: 'Cheesecake de Frutos Rojos', categoria: 'Postres', precio: 6.00, descripcion: 'Suave pastel de queso con mermelada casera.'),
  ];

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
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: categoriaController, decoration: const InputDecoration(labelText: 'Categoría (Comidas, Bebidas, Postres)')),
              TextField(controller: precioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _platillos.add(Platillo(
                  id: DateTime.now().toString(),
                  nombre: nombreController.text,
                  categoria: categoriaController.text,
                  precio: double.tryParse(precioController.text) ?? 0.0,
                  descripcion: descController.text,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarPlatillo(String id) {
    setState(() {
      _platillos.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Agrupar platillos por categoría
    final categorias = _platillos.map((p) => p.categoria).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_esAdministrador ? 'Panel de Administrador' : 'Menú del Restaurante'),
        actions: [
          Row(
            children: [
              Text(_esAdministrador ? 'Admin' : 'Cliente', style: const TextStyle(fontSize: 12)),
              Switch(
                value: _esAdministrador,
                onChanged: (val) => setState(() => _esAdministrador = val),
              ),
            ],
          )
        ],
      ),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final itemsCat = _platillos.where((p) => p.categoria == categoria).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Text(
                  categoria,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ),
              ...itemsCat.map((platillo) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(platillo.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(platillo.descripcion),
                          const SizedBox(height: 6),
                          Text('\$${platillo.precio.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: _esAdministrador
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarPlatillo(platillo.id),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  )),
              const SizedBox(height: 10),
            ],
          );
        },
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