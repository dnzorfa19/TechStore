import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/product.dart';

void main() {
  runApp(const TechStoreApp());
}

const Color backgroundColor = Color(0xFF0D0D12);
const Color cardColor = Color(0xFF191922);
const Color purpleColor = Color(0xFF8B5CF6);

Future<List<Product>> loadProducts() async {
  final jsonString = await rootBundle.loadString('lib/data/products.json');

  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList.map((item) {
    return Product.fromJson(Map<String, dynamic>.from(item as Map));
  }).toList();
}

class TechStoreApp extends StatelessWidget {
  const TechStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechStore',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: purpleColor,
          surface: cardColor,
        ),
        useMaterial3: true,
      ),
      home: const CatalogPage(),
    );
  }
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String selectedCategory = 'Tümü';
  String searchText = '';
  final Map<int, int> cart = {};
  List<Product> products = [];
  bool isLoading = true;
  String? loadError;

  final List<String> categories = ['Tümü', 'Bilgisayar', 'Telefon', 'Aksesuar'];
  Future<void> fetchProducts() async {
    try {
      final loadedProducts = await loadProducts();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = 'Ürünler yüklenemedi: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          selectedCategory == 'Tümü' || product.category == selectedCategory;

      final matchesSearch = product.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} ₺';
  }

  void addToCart(Product product) {
    setState(() {
      cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi.'),
        backgroundColor: purpleColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void increaseQuantity(Product product) {
    setState(() {
      cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void decreaseQuantity(Product product) {
    setState(() {
      final quantity = cart[product.id];

      if (quantity == null) return;

      if (quantity <= 1) {
        cart.remove(product.id);
      } else {
        cart[product.id] = quantity - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: purpleColor, size: 30),
            SizedBox(width: 8),
            Text('TechStore', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(
                          cartIds: cart,
                          allProducts: products,
                          formatPrice: formatPrice,
                          onIncrease: increaseQuantity,
                          onDecrease: decreaseQuantity,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 3,
                    top: 2,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: purpleColor,
                      child: Text(
                        '${cart.values.fold<int>(0, (sum, quantity) => sum + quantity)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teknolojiyi keşfet.',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'İhtiyacın olan teknoloji burada.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 22),

                    TextField(
                      onChanged: (value) {
                        setState(() => searchText = value);
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ürün ara...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: purpleColor,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: purpleColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kategoriler',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Container(
                          width: 5,
                          height: 22,
                          decoration: BoxDecoration(
                            color: purpleColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final selected = selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              selectedColor: purpleColor,
                              backgroundColor: cardColor,
                              side: BorderSide(
                                color: selected
                                    ? purpleColor
                                    : Colors.white.withValues(alpha: 0.08),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Öne Çıkan Ürünler',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${visibleProducts.length} ürün',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (visibleProducts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Ürün bulunamadı.')),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = visibleProducts[index];

                    return ProductCard(
                      product: product,
                      price: formatPrice(product.price),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              product: product,
                              price: formatPrice(product.price),
                              onAdd: () => addToCart(product),
                            ),
                          ),
                        );
                      },
                      onAdd: () => addToCart(product),
                    );
                  }, childCount: visibleProducts.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.price,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün görseli
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: product.iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          product.icon,
                          size: 58,
                          color: product.iconColor,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Kategori
              Text(
                product.category.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: purpleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 6),

              // Ürün adı
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // Fiyat ve sepete ekleme
              Row(
                children: [
                  Expanded(
                    child: Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: purpleColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          color: purpleColor,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final String price;
  final VoidCallback onAdd;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detayı')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      product.imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          product.icon,
                          size: 130,
                          color: product.iconColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.category.toUpperCase(),
              style: const TextStyle(color: purpleColor),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              price,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: purpleColor,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  onAdd();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Sepete Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purpleColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<int, int> cartIds;
  final List<Product> allProducts;
  final String Function(double) formatPrice;
  final void Function(Product) onIncrease;
  final void Function(Product) onDecrease;

  const CartPage({
    super.key,
    required this.cartIds,
    required this.allProducts,
    required this.formatPrice,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartProducts = widget.allProducts
        .where((product) => widget.cartIds.containsKey(product.id))
        .toList();

    final total = cartProducts.fold<double>(
      0,
      (sum, product) => sum + product.price * (widget.cartIds[product.id] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: cartProducts.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 72,
                    color: purpleColor,
                  ),
                  SizedBox(height: 16),
                  Text('Sepetin şu an boş.', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...cartProducts.map(
                  (product) => Card(
                    color: cardColor,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          product.imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              product.icon,
                              color: product.iconColor,
                              size: 32,
                            );
                          },
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${widget.cartIds[product.id]} adet • '
                        '${widget.formatPrice(product.price)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              widget.onDecrease(product);
                              setState(() {});
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            color: purpleColor,
                          ),
                          Text(
                            '${widget.cartIds[product.id] ?? 0}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              widget.onIncrease(product);
                              setState(() {});
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: purpleColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Toplam: ${widget.formatPrice(total)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: purpleColor,
                  ),
                ),
              ],
            ),
    );
  }
}
