import 'package:flutter/material.dart';
import 'api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppState.instance.loadProductsFromApi();

  runApp(const RestauranteApp());
}

/* ============================================================
   APLICACIÓN
   ============================================================ */

class RestauranteApp extends StatelessWidget {
  const RestauranteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabor & Mesa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD94F30),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD94F30), width: 1.5),
          ),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

/* ============================================================
   MODELOS
   ============================================================ */

enum UserRole { cliente, administrador }

enum OrderStatus { pendiente, preparando, listo, entregado, cancelado }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class Category {
  final String id;
  String name;
  IconData icon;

  Category({required this.id, required this.name, required this.icon});
}

class Product {
  final String id;
  String name;
  String description;
  double price;
  String categoryId;
  String image;
  bool available;
  bool popular;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.image,
    this.available = true,
    this.popular = false,
  });
}

class CartItem {
  final Product product;
  int quantity;
  String notes;

  CartItem({required this.product, this.quantity = 1, this.notes = ''});

  double get subtotal => product.price * quantity;
}

class Order {
  final String id;
  final String customerName;
  final List<CartItem> items;
  final DateTime date;
  OrderStatus status;
  final String address;
  final String phone;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.date,
    required this.status,
    required this.address,
    required this.phone,
  });

  double get subtotal => items.fold(0, (total, item) => total + item.subtotal);

  double get delivery => subtotal >= 30 ? 0 : 2.50;

  double get total => subtotal + delivery;
}

/* ============================================================
   ESTADO GLOBAL
   ============================================================ */

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();

  AppState._();

  AppUser? currentUser;

  final List<Category> categories = [
    Category(id: 'cat1', name: 'Hamburguesas', icon: Icons.lunch_dining),
    Category(id: 'cat2', name: 'Pizza', icon: Icons.local_pizza),
    Category(id: 'cat3', name: 'Pollo', icon: Icons.set_meal),
    Category(id: 'cat4', name: 'Ensaladas', icon: Icons.eco),
    Category(id: 'cat5', name: 'Bebidas', icon: Icons.local_drink),
    Category(id: 'cat6', name: 'Postres', icon: Icons.cake),
  ];

  final List<Product> products = [
    Product(
      id: 'p1',
      name: 'Hamburguesa Clásica',
      description:
          'Carne de res, queso cheddar, lechuga, tomate y salsa especial.',
      price: 7.99,
      categoryId: 'cat1',
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      popular: true,
    ),
    Product(
      id: 'p2',
      name: 'Hamburguesa BBQ',
      description: 'Carne de res, queso, tocino crujiente y salsa BBQ.',
      price: 9.99,
      categoryId: 'cat1',
      image: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b',
      popular: true,
    ),
    Product(
      id: 'p3',
      name: 'Pizza Pepperoni',
      description: 'Salsa de tomate, mozzarella y abundante pepperoni.',
      price: 12.99,
      categoryId: 'cat2',
      image: 'https://images.unsplash.com/photo-1628840042765-356cda07504e',
      popular: true,
    ),
    Product(
      id: 'p4',
      name: 'Pizza Vegetariana',
      description:
          'Mozzarella, champiñones, tomate, cebolla, chile dulce y aceitunas.',
      price: 13.50,
      categoryId: 'cat2',
      image: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002',
    ),
    Product(
      id: 'p5',
      name: 'Pollo Crispy',
      description: 'Pechuga de pollo empanizada con papas fritas.',
      price: 8.99,
      categoryId: 'cat3',
      image: 'https://images.unsplash.com/photo-1562967916-eb82221dfb92',
      popular: true,
    ),
    Product(
      id: 'p6',
      name: 'Ensalada César',
      description: 'Lechuga fresca, pollo, parmesano y aderezo César.',
      price: 6.99,
      categoryId: 'cat4',
      image: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9',
    ),
    Product(
      id: 'p7',
      name: 'Gaseosa',
      description: 'Bebida gaseosa fría de 500 ml.',
      price: 1.50,
      categoryId: 'cat5',
      image: 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e',
    ),
    Product(
      id: 'p8',
      name: 'Limonada Natural',
      description: 'Limonada natural preparada al momento.',
      price: 2.25,
      categoryId: 'cat5',
      image: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd',
    ),
    Product(
      id: 'p9',
      name: 'Cheesecake',
      description: 'Cheesecake cremoso con salsa de frutos rojos.',
      price: 4.99,
      categoryId: 'cat6',
      image: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187',
    ),
  ];

  final List<CartItem> cart = [];
  final List<Order> orders = [];

  String selectedCategory = 'all';
  String search = '';

  /* ==========================================================
     API
     ========================================================== */

  Future<void> loadProductsFromApi() async {
    try {
      final data = await ApiService.getProducts();

      final apiProducts = data.map<Product>((item) {
        return Product(
          id: item['id'].toString(),
          name: item['name'].toString(),
          description: item['description'].toString(),
          price: (item['price'] as num).toDouble(),
          categoryId: item['categoryId'].toString(),
          image: item['image'].toString(),
          available: item['available'] == true,
          popular: item['popular'] == true,
        );
      }).toList();

      if (apiProducts.isNotEmpty) {
        products
          ..clear()
          ..addAll(apiProducts);
      }

      notifyListeners();

      debugPrint('Productos cargados desde la API: ${products.length}');
    } catch (e) {
      debugPrint('Error cargando productos desde la API: $e');
    }
  }

  /* ==========================================================
     AUTENTICACIÓN
     ========================================================== */

  void login(String email, UserRole role) {
    currentUser = AppUser(
      id: role == UserRole.administrador ? 'admin1' : 'user1',
      name: role == UserRole.administrador ? 'Administrador' : 'Cliente',
      email: email,
      role: role,
    );

    notifyListeners();
  }

  void logout() {
    currentUser = null;
    cart.clear();
    notifyListeners();
  }

  /* ==========================================================
     PRODUCTOS
     ========================================================== */

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          selectedCategory == 'all' || product.categoryId == selectedCategory;

      final query = search.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch && product.available;
    }).toList();
  }

  List<Product> get popularProducts {
    return products.where((p) => p.popular && p.available).toList();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  /* ==========================================================
     CARRITO
     ========================================================== */

  void addToCart(Product product) {
    final existing = cart.where((item) => item.product.id == product.id);

    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      cart.add(CartItem(product: product));
    }

    notifyListeners();
  }

  void removeFromCart(Product product) {
    cart.removeWhere((item) => item.product.id == product.id);

    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      cart.remove(item);
    }

    notifyListeners();
  }

  void updateNotes(CartItem item, String notes) {
    item.notes = notes;
    notifyListeners();
  }

  double get cartSubtotal =>
      cart.fold(0, (total, item) => total + item.subtotal);

  double get deliveryCost => cartSubtotal >= 30 || cart.isEmpty ? 0 : 2.50;

  double get cartTotal => cartSubtotal + deliveryCost;

  int get cartCount => cart.fold(0, (total, item) => total + item.quantity);

  /* ==========================================================
     PEDIDOS
     ========================================================== */

  void createOrder({required String address, required String phone}) {
    if (cart.isEmpty) return;

    final copiedItems = cart
        .map(
          (item) => CartItem(
            product: item.product,
            quantity: item.quantity,
            notes: item.notes,
          ),
        )
        .toList();

    orders.insert(
      0,
      Order(
        id: '#${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        customerName: currentUser?.name ?? 'Cliente',
        items: copiedItems,
        date: DateTime.now(),
        status: OrderStatus.pendiente,
        address: address,
        phone: phone,
      ),
    );

    cart.clear();

    notifyListeners();
  }

  void updateOrderStatus(Order order, OrderStatus status) {
    order.status = status;
    notifyListeners();
  }

  /* ==========================================================
     ADMINISTRACIÓN
     ========================================================== */

  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    notifyListeners();
  }

  void deleteProduct(Product product) {
    products.remove(product);
    notifyListeners();
  }

  void addCategory(Category category) {
    categories.add(category);
    notifyListeners();
  }

  void deleteCategory(Category category) {
    categories.remove(category);
    notifyListeners();
  }
}

/* ============================================================
   AUTH PAGE
   ============================================================ */

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login(UserRole role) {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese su correo electrónico')),
      );
      return;
    }

    AppState.instance.login(email, role);

    if (role == UserRole.administrador) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 72,
                      color: Color(0xFFD94F30),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Sabor & Mesa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Restaurante', textAlign: TextAlign.center),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        login(UserRole.cliente);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text('Iniciar sesión'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        login(UserRole.administrador);
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Ingresar como administrador'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   CLIENT SHELL
   ============================================================ */

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int selectedIndex = 0;

  final pages = const [
    ClientHomePage(),
    ClientMenuPage(),
    ClientOrdersPage(),
    ClientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sabor & Mesa'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  if (state.cartCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: CircleAvatar(
                        radius: 9,
                        child: Text(
                          '${state.cartCount}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: pages[selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu),
                label: 'Menú',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Pedidos',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ============================================================
   CLIENT HOME
   ============================================================ */

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${state.currentUser?.name ?? 'Cliente'} 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text('¿Qué te gustar铆a comer hoy?'),
              const SizedBox(height: 20),
              TextField(
                onChanged: state.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryButton(
                      name: 'Todos',
                      icon: Icons.apps,
                      selected: state.selectedCategory == 'all',
                      onTap: () => state.setCategory('all'),
                    ),
                    ...state.categories.map(
                      (category) => _CategoryButton(
                        name: category.name,
                        icon: category.icon,
                        selected: state.selectedCategory == category.id,
                        onTap: () => state.setCategory(category.id),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Productos populares',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ProductGrid(products: state.popularProducts),
            ],
          ),
        );
      },
    );
  }
}

/* ============================================================
   CATEGORY BUTTON
   ============================================================ */

class _CategoryButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.name,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 95,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD94F30) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFFD94F30) : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFFD94F30),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   MENÚ CLIENTE
   ============================================================ */

class ClientMenuPage extends StatelessWidget {
  const ClientMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuestro menú',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: state.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar comida...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: state.selectedCategory == 'all',
                    onSelected: (_) {
                      state.setCategory('all');
                    },
                  ),
                  ...state.categories.map(
                    (category) => ChoiceChip(
                      label: Text(category.name),
                      selected: state.selectedCategory == category.id,
                      onSelected: (_) {
                        state.setCategory(category.id);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ProductGrid(products: state.filteredProducts),
            ],
          ),
        );
      },
    );
  }
}

/* ============================================================
   PRODUCT GRID
   ============================================================ */

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.fastfood,
        message: 'No se encontraron productos.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns = 1;

        if (width >= 1000) {
          columns = 4;
        } else if (width >= 700) {
          columns = 3;
        } else if (width >= 450) {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}

/* ============================================================
   PRODUCT CARD
   ============================================================ */

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFD94F30),
                      ),
                    ),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: () {
                        state.addToCart(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} agregado al carrito',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   CARRITO
   ============================================================ */

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mi carrito')),
          body: state.cart.isEmpty
              ? const EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  message: 'Tu carrito está vacío.',
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.cart.length,
                        itemBuilder: (context, index) {
                          final item = state.cart[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item.product.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '\$${item.product.price.toStringAsFixed(2)}',
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                state.decreaseQuantity(item);
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                            ),
                                            Text('${item.quantity}'),
                                            IconButton(
                                              onPressed: () {
                                                state.increaseQuantity(item);
                                              },
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(blurRadius: 8, color: Colors.black12),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            title: 'Subtotal',
                            value: '\$${state.cartSubtotal.toStringAsFixed(2)}',
                          ),
                          _SummaryRow(
                            title: 'Envío',
                            value: state.deliveryCost == 0
                                ? 'Gratis'
                                : '\$${state.deliveryCost.toStringAsFixed(2)}',
                          ),
                          const Divider(),
                          _SummaryRow(
                            title: 'Total',
                            value: '\$${state.cartTotal.toStringAsFixed(2)}',
                            bold: true,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                _showCheckout(context);
                              },
                              icon: const Icon(Icons.shopping_bag),
                              label: const Text('Realizar pedido'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showCheckout(BuildContext context) {
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (addressController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }

                AppState.instance.createOrder(
                  address: addressController.text.trim(),
                  phone: phoneController.text.trim(),
                );

                Navigator.pop(dialogContext);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pedido creado correctamente')),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}

/* ============================================================
   RESUMEN
   ============================================================ */

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   PEDIDOS CLIENTE
   ============================================================ */

class ClientOrdersPage extends StatelessWidget {
  const ClientOrdersPage({super.key});

  String statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.preparando:
        return 'Preparando';
      case OrderStatus.listo:
        return 'Listo';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        if (state.orders.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long,
            message: 'Todavía no tienes pedidos.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.orders.length,
          itemBuilder: (context, index) {
            final order = state.orders[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  'Pedido ${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(statusText(order.status)),
                children: [
                  ...order.items.map(
                    (item) => ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                        '${item.quantity} x \$${item.product.price.toStringAsFixed(2)}',
                      ),
                      trailing: Text('\$${item.subtotal.toStringAsFixed(2)}'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/* ============================================================
   PERFIL CLIENTE
   ============================================================ */

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final user = state.currentUser;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),
        const SizedBox(height: 15),
        Text(
          user?.name ?? 'Cliente',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(user?.email ?? '', textAlign: TextAlign.center),
        const SizedBox(height: 30),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Nombre'),
            subtitle: Text(user?.name ?? ''),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Correo'),
            subtitle: Text(user?.email ?? ''),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            state.logout();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthPage()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}

/* ============================================================
   ADMIN SHELL
   ============================================================ */

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int selectedIndex = 0;

  final pages = const [
    AdminDashboardPage(),
    AdminProductsPage(),
    AdminCategoriesPage(),
    AdminOrdersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administrativo'),
        actions: [
          IconButton(
            onPressed: () {
              AppState.instance.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   ADMIN DASHBOARD
   ============================================================ */

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final totalSales = state.orders.fold<double>(
          0,
          (sum, order) => sum + order.total,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
                children: [
                  StatCard(
                    title: 'Productos',
                    value: '${state.products.length}',
                    icon: Icons.inventory_2,
                  ),
                  StatCard(
                    title: 'Pedidos',
                    value: '${state.orders.length}',
                    icon: Icons.receipt_long,
                  ),
                  StatCard(
                    title: 'Ventas',
                    value: '\$${totalSales.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Productos populares',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...state.popularProducts.map(
                (product) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(product.image),
                    ),
                    title: Text(product.name),
                    trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ============================================================
   ADMIN PRODUCTOS
   ============================================================ */

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ProductFormDialog(),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.image),
                  ),
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Eliminar producto'),
                            content: Text('¿Desea eliminar ${product.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  state.deleteProduct(product);
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* ============================================================
   PRODUCT FORM
   ============================================================ */

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final priceController = TextEditingController();

  final imageController = TextEditingController();

  String categoryId = 'cat1';

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AlertDialog(
      title: const Text('Nuevo producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'URL de imagen'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: categoryId,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: state.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    categoryId = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();

            final description = descriptionController.text.trim();

            final price = double.tryParse(
              priceController.text.trim().replaceAll(',', '.'),
            );

            if (name.isEmpty || description.isEmpty || price == null) {
              return;
            }

            state.addProduct(
              Product(
                id: 'p${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                description: description,
                price: price,
                categoryId: categoryId,
                image: imageController.text.trim().isEmpty
                    ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c'
                    : imageController.text.trim(),
              ),
            );

            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/* ============================================================
   ADMIN CATEGORÍAS
   ============================================================ */

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CategoryDialog(),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(category.icon)),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      state.deleteCategory(category);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* ============================================================
   CATEGORY DIALOG
   ============================================================ */

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Nombre'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Escribe el nombre de la categoría.'),
                ),
              );
              return;
            }

            final state = AppState.instance;
            final alreadyExists = state.categories.any(
              (category) => category.name.toLowerCase() == name.toLowerCase(),
            );

            if (alreadyExists) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Esa categoría ya existe.')),
              );
              return;
            }

            state.addCategory(
              Category(
                id: 'cat${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                icon: Icons.restaurant_menu,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  String statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.preparando:
        return 'Preparando';
      case OrderStatus.listo:
        return 'Listo';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        if (state.orders.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long,
            message: 'No hay pedidos registrados.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.orders.length,
          itemBuilder: (context, index) {
            final order = state.orders[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  'Pedido ${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${order.customerName} • ${statusText(order.status)}',
                ),
                children: [
                  ...order.items.map(
                    (item) => ListTile(
                      title: Text(item.product.name),
                      subtitle: Text('${item.quantity} unidades'),
                      trailing: Text('\$${item.subtotal.toStringAsFixed(2)}'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<OrderStatus>(
                          value: order.status,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                          ),
                          items: OrderStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(statusText(status)),
                                ),
                              )
                              .toList(),
                          onChanged: (status) {
                            if (status != null) {
                              state.updateOrderStatus(order, status);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/* ============================================================
   STAT CARD
   ============================================================ */

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   EMPTY STATE
   ============================================================ */

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.grey),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
