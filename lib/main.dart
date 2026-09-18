import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyCartPage(),
    );
  }
}

// --- MODEL DATA ---
class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  int quantity;
  int likes;        // ✅ Jumlah like
  bool isLiked;     // ✅ Status like (untuk ubah icon)
  bool isSelected;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.likes = 10,      // Default like awal
    this.isLiked = false, // Default belum di-like
    this.isSelected = false,
  });
}

// --- HALAMAN UTAMA ---
class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  // ✅ Data Produk Baru (Sepatu, Jam, Tas)
  final List<Product> products = [
    Product(
      name: 'Sepatu Sneakers',
      description: 'Nike Air Max',
      price: 1250000,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80',
      likes: 25,
    ),
    Product(
      name: 'Jam Tangan',
      description: 'Casio G-Shock',
      price: 850000,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80',
      likes: 15,
    ),
    Product(
      name: 'Tas Ransel',
      description: 'Eiger Classic',
      price: 420000,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80',
      likes: 30,
    ),
  ];

  String? longPressMessage;
  Timer? _messageTimer;

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  // --- LOGIKA INTERAKSI ---

  // 1. Tap: Highlight border
  void _handleTap(int index) {
    setState(() {
      products[index].isSelected = !products[index].isSelected;
    });
  }

  // ✅ 2. Double Tap: Toggle Like (+1 / -1) - TIDAK terkait quantity
  void _handleDoubleTap(int index) {
    setState(() {
      if (products[index].isLiked) {
        // Jika sudah like, maka unlike (kurangi 1)
        products[index].isLiked = false;
        products[index].likes--;
      } else {
        // Jika belum like, maka like (tambah 1)
        products[index].isLiked = true;
        products[index].likes++;
      }
    });
  }

  // 3. Long Press: Info produk
  void _handleLongPress(int index) {
    setState(() {
      longPressMessage = 'Produk dipilih! ${products[index].name}';
    });

    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          longPressMessage = null;
        });
      }
    });
  }

  // ✅ 4. Increment Quantity: HANYA menambah quantity, tidak menambah like
  void _incrementQuantity(int index) {
    setState(() {
      products[index].quantity++;
    });
  }

  // ✅ 5. Decrement Quantity: HANYA mengurangi quantity, tidak mengurangi like
  void _decrementQuantity(int index) {
    if (products[index].quantity > 1) {
      setState(() {
        products[index].quantity--;
      });
    }
  }

  // --- PERHITUNGAN TOTAL ---
  double get _totalPrice => products.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get _totalItems => products.fold(0, (sum, item) => sum + item.quantity);

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search, color: Colors.white),
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Breakpoint untuk Tablet/Desktop
            final isTablet = constraints.maxWidth > 600;

            return Column(
              children: [
                // 1. HEADER SECTION
                const _HeaderSection(),

                // 2. NOTIFIKASI LONG PRESS
                if (longPressMessage != null)
                  _NotificationBanner(message: longPressMessage!),

                // 3. DAFTAR PRODUK (Responsif)
                Expanded(
                  child: isTablet
                      ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _ProductCard(
                        product: products[index],
                        onTap: () => _handleTap(index),
                        onDoubleTap: () => _handleDoubleTap(index),
                        onLongPress: () => _handleLongPress(index),
                        onIncrement: () => _incrementQuantity(index),
                        onDecrement: () => _decrementQuantity(index),
                      );
                    },
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ProductCard(
                          product: products[index],
                          onTap: () => _handleTap(index),
                          onDoubleTap: () => _handleDoubleTap(index),
                          onLongPress: () => _handleLongPress(index),
                          onIncrement: () => _incrementQuantity(index),
                          onDecrement: () => _decrementQuantity(index),
                        ),
                      );
                    },
                  ),
                ),

                // 4. FOOTER CHECKOUT
                _CheckoutFooter(
                  totalItems: _totalItems,
                  totalPrice: _formatCurrency(_totalPrice),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGET KOMPONEN REUSABLE ---

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.blue.shade50,
      child: const Text(
        'Belanja lebih mudah setiap hari',
        style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  final String message;

  const _NotificationBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onIncrement,
    required this.onDecrement,
  });

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: product.isSelected ? Colors.blue : Colors.grey.shade200,
            width: product.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Baris Like & Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ Like Section (Icon berubah warna & jumlah like independen)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              // Jika isLiked true -> icon full merah, else outline
                              product.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: product.isLiked ? Colors.red : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.likes}', // ✅ Hanya menampilkan jumlah like
                              style: TextStyle(
                                color: product.isLiked ? Colors.red : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: product.isLiked ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Counter Section (Tidak mempengaruhi like)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CounterButton(icon: Icons.remove, onTap: onDecrement),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${product.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          _CounterButton(icon: Icons.add, onTap: onIncrement),
                        ],
                      ),
                    ],
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

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  final int totalItems;
  final String totalPrice;

  const _CheckoutFooter({
    required this.totalItems,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total ($totalItems produk)',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  totalPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}