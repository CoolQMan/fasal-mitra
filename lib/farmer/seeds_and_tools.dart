import 'package:flutter/material.dart';

class SeedsAndTools extends StatefulWidget {
  const SeedsAndTools({Key? key}) : super(key: key);

  @override
  State<SeedsAndTools> createState() => _SeedsAndToolsState();
}

class _SeedsAndToolsState extends State<SeedsAndTools>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  List<Product> _allProducts = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  void _loadProducts() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _allProducts = [
        // Seeds
        Product(
          id: '1',
          name: 'Tomato Seeds',
          price: 120,
          imageUrl: 'lib/assets/marketplace/tomato_seeds.png',
          category: 'Seeds',
          rating: 4.5,
          description:
              'High-yield hybrid tomato seeds suitable for various climates.',
          seller: 'GreenThumb Nursery',
          inStock: true,
        ),
        Product(
          id: '2',
          name: 'Wheat Seeds',
          price: 350,
          imageUrl: 'lib/assets/marketplace/wheat_seeds.png',
          category: 'Seeds',
          rating: 4.8,
          description:
              'Premium quality wheat seeds with high germination rate.',
          seller: 'AgriSeeds Co.',
          inStock: true,
        ),
        Product(
          id: '3',
          name: 'Rice Seeds',
          price: 400,
          imageUrl: 'lib/assets/marketplace/rice_seeds.png',
          category: 'Seeds',
          rating: 4.7,
          description:
              'Drought-resistant rice variety with excellent yield potential.',
          seller: 'FarmTech Solutions',
          inStock: true,
        ),
        Product(
          id: '4',
          name: 'Chili Seeds',
          price: 90,
          imageUrl: 'lib/assets/marketplace/chili_seeds.png',
          category: 'Seeds',
          rating: 4.2,
          description:
              'Spicy chili variety perfect for commercial cultivation.',
          seller: 'Spice Garden',
          inStock: false,
        ),

        // Tools
        Product(
          id: '5',
          name: 'Garden Trowel',
          price: 250,
          imageUrl: 'lib/assets/marketplace/trowel.png',
          category: 'Tools',
          rating: 4.3,
          description:
              'Ergonomic hand trowel with comfortable grip for planting and weeding.',
          seller: 'ToolMaster',
          inStock: true,
        ),
        Product(
          id: '6',
          name: 'Pruning Shears',
          price: 450,
          imageUrl: 'lib/assets/marketplace/pruning_shears.png',
          category: 'Tools',
          rating: 4.6,
          description:
              'Sharp stainless steel pruning shears for precise cutting.',
          seller: 'GardenPro',
          inStock: true,
        ),
        Product(
          id: '7',
          name: 'Watering Can',
          price: 320,
          imageUrl: 'lib/assets/marketplace/watering_can.png',
          category: 'Tools',
          rating: 4.1,
          description:
              '5-liter capacity watering can with rose sprinkler head.',
          seller: 'GreenLife',
          inStock: true,
        ),
        Product(
          id: '8',
          name: 'Garden Hoe',
          price: 580,
          imageUrl: 'lib/assets/marketplace/hoe.png',
          category: 'Tools',
          rating: 4.4,
          description:
              'Durable garden hoe with wooden handle for soil preparation.',
          seller: 'FarmTools Inc.',
          inStock: true,
        ),
      ];

      _filteredProducts = List.from(_allProducts);
      _isLoading = false;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == 'All') {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts =
            _allProducts.where((product) {
              bool matchesQuery =
                  query.isEmpty ||
                  product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.description.toLowerCase().contains(
                    query.toLowerCase(),
                  );

              bool matchesCategory =
                  _selectedCategory == 'All' ||
                  product.category == _selectedCategory;

              return matchesQuery && matchesCategory;
            }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterProducts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Farmer Marketplace',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.grey),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ), // Added border
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search seeds, tools...',
                      hintStyle: TextStyle(color: Colors.grey.shade900),
                      prefixIcon: Icon(Icons.search, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: _filterProducts,
                  ),
                ),
              ),

              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildCategoryChip('All'),
                    SizedBox(width: 8),
                    _buildCategoryChip('Seeds'),
                    SizedBox(width: 8),
                    _buildCategoryChip('Tools'),
                    SizedBox(width: 8),
                    _buildCategoryChip('Fertilizers'),
                    SizedBox(width: 8),
                    _buildCategoryChip('Pesticides'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try a different search term or category',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(_filteredProducts[index]);
                },
              ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _filterByCategory(category);
        }
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: colorScheme.tertiary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      product.category == 'Seeds' ? Icons.spa : Icons.handyman,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  if (!product.inStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Product price
                    Text(
                      '₹${product.price}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          product.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    Spacer(),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            product.inStock
                                ? () {
                                  // Add to cart functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.name} added to cart',
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final String description;
  final String seller;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.description,
    required this.seller,
    required this.inStock,
  });
}

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(
                  product.category == 'Seeds' ? Icons.spa : Icons.handyman,
                  size: 120,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and availability
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              product.inStock
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          product.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            color:
                                product.inStock
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Price
                  Text(
                    '₹${product.price}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Rating and seller
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.store, size: 16, color: Colors.grey.shade700),
                      SizedBox(width: 4),
                      Text(
                        'Sold by: ${product.seller}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  SizedBox(height: 24),

                  // Specifications
                  Text(
                    'Specifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildSpecRow('Category', product.category),
                  _buildSpecRow(
                    'Packaging',
                    product.category == 'Seeds' ? '100g packet' : 'Single unit',
                  ),
                  _buildSpecRow('Origin', 'India'),
                  _buildSpecRow(
                    'Warranty',
                    product.category == 'Tools'
                        ? '1 year manufacturer warranty'
                        : 'Not applicable',
                  ),

                  SizedBox(height: 24),

                  // Add to cart section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Quantity:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      // Decrease quantity
                                    },
                                  ),
                                  Text('1'),
                                  IconButton(
                                    icon: Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      // Increase quantity
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    product.inStock
                                        ? () {
                                          // Add to cart functionality
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product.name} added to cart',
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                        : null,
                                icon: Icon(Icons.shopping_cart),
                                label: Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                // Add to wishlist
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to wishlist'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: Icon(Icons.favorite_border),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
