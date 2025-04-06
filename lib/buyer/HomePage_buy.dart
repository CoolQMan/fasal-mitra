import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdg_solution/buyer/Cart.dart';
import 'package:gdg_solution/utils/login_page.dart'; // Import for Firebase Auth

class HomepageBuy extends StatefulWidget {
  final String username;
  final String uniqueID;

  HomepageBuy({Key? key, required this.username, required this.uniqueID})
    : super(key: key);

  @override
  State<HomepageBuy> createState() => _HomepageBuyState();
}

class _HomepageBuyState extends State<HomepageBuy> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Categories list
  final List<String> _categories = [
    'All Categories',
    'Grains',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Oilseeds',
    'Other',
  ];
  List<Map<String, dynamic>> buyerCart = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build the query based on search and category filters
  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('crops');

    // Filter by category if not "All Categories"
    if (_selectedCategory != 'All Categories') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    // Filter by isOffered status - only show crops that are not yet offered
    query = query.where('isOffered', isEqualTo: false);

    // Order by timestamp, newest first
    query = query.orderBy('timestamp', descending: true);

    return query;
  }

  // Method to show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Confirm Logout',
              style: TextStyle(color: Colors.teal.shade800),
            ),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _auth.signOut();
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false, // Remove all previous routes
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: $e'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Logout'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
          ),
    );
  }

  // Method to make an offer on a crop
  Future<void> _makeOffer(
    String cropId,
    double originalPrice,
    double availableQuantity,
    BuildContext context,
  ) async {
    TextEditingController offerController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    offerController.text = originalPrice.toString();
    quantityController.text = "1"; // Default quantity

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Make an Offer',
              style: TextStyle(color: Colors.teal.shade800),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Original price: ₹${originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Available quantity: ${availableQuantity.toStringAsFixed(2)} kg',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: offerController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Your Offer (₹)',
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.teal),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity Offered (kg)',
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    prefixIcon: Icon(Icons.scale, color: Colors.teal),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  double? offerAmount = double.tryParse(offerController.text);
                  if (offerAmount == null || offerAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid offer amount'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                    return;
                  }

                  double? offeredQuantity = double.tryParse(
                    quantityController.text,
                  );
                  if (offeredQuantity == null || offeredQuantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid quantity'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                    return;
                  }

                  if (offeredQuantity > availableQuantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Requested quantity exceeds available quantity',
                        ),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                    return;
                  }

                  try {
                    DocumentSnapshot cropDoc =
                        await _firestore.collection('crops').doc(cropId).get();
                    Map<String, dynamic> cropData =
                        cropDoc.data() as Map<String, dynamic>;

                    await _firestore.collection('cart').add({
                      'originalCropId': cropId,
                      'cropName': cropData['cropName'],
                      'offeredValue': offerAmount,
                      'offeredQuantity': offeredQuantity,
                      'buyerId': widget.uniqueID,
                      'buyerName': widget.username,
                      'farmerId': cropData['farmerId'],
                      'farmerName': cropData['Seller_name'],
                      'originalPrice': cropData['yoursValue'],
                      'timestamp': FieldValue.serverTimestamp(),
                      'imagePath': cropData['imagePath'],
                      'date': cropData['date'],
                      'category': cropData['category'],
                      'govt_value': cropData['govt_value'],
                      'status': 'pending',
                    });
                    double currentQuantity =
                        (cropData['quantity'] ?? 0).toDouble();
                    double updatedQuantity = currentQuantity - offeredQuantity;
                    // Update the crop listing with the reduced quantity
                    await _firestore.collection('crops').doc(cropId).update({
                      'quantity': updatedQuantity,
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Offer made successfully! Added to cart.',
                        ),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error making offer: $e'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit Offer'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Welcome ${widget.username}',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(buyerId: widget.uniqueID),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Category Selector
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return CategoryItem(
                  category: category,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          // Available Crops Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Available Crops',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Product List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No crops available'));
                }

                // Filter by search text if provided
                var filteredDocs = snapshot.data!.docs;
                if (_searchController.text.isNotEmpty) {
                  final searchTerm = _searchController.text.toLowerCase();
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final cropName =
                            (data['cropName'] as String? ?? '').toLowerCase();
                        final sellerName =
                            (data['Seller_name'] as String? ?? '')
                                .toLowerCase();
                        return cropName.contains(searchTerm) ||
                            sellerName.contains(searchTerm);
                      }).toList();
                }

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No crops match your search'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return CropCard(
                      cropId: doc.id,
                      cropName: data['cropName'] ?? 'Unknown Crop',
                      price: (data['yoursValue'] ?? 0).toDouble(),
                      quantity: (data['quantity'] ?? 0).toDouble(),
                      unit: 'kg',
                      imagePath:
                          data['imagePath'] ??
                          'lib/assets/crops/default_crop.png',
                      farmerName: data['Seller_name'] ?? 'Unknown Farmer',
                      date: data['date'] ?? 'Unknown Date',
                      govtPrice: (data['govt_value'] ?? 0).toDouble(),
                      onOfferTap:
                          () => _makeOffer(
                            doc.id,
                            (data['yoursValue'] ?? 0).toDouble(),
                            (data['quantity'] ?? 0).toDouble(),
                            context,
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Add LoginPage class import at the top of your file
// import 'package:gdg_solution/path_to_your_login_page.dart';

// class LoginPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // This is a placeholder for your actual LoginPage
//     // Replace with your actual LoginPage implementation
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Center(
//         child: Text('Login Page'),
//       ),
//     );
//   }
// }

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchBar({Key? key, required this.controller, this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search for crops...',
          hintStyle: TextStyle(color: Colors.teal.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.teal),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 15.0, bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class CropCard extends StatelessWidget {
  final String cropId;
  final String cropName;
  final double price;
  final double quantity;
  final String unit;
  final String imagePath;
  final String farmerName;
  final String date;
  final double govtPrice;
  final VoidCallback onOfferTap;

  const CropCard({
    Key? key,
    required this.cropId,
    required this.cropName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imagePath,
    required this.farmerName,
    required this.date,
    required this.govtPrice,
    required this.onOfferTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      imagePath.startsWith('http')
                          ? Image.network(
                            imagePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
                              );
                            },
                          )
                          : Image.asset(
                            imagePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                ),
                const SizedBox(width: 16),

                // Crop Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by $farmerName',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Listed on: $date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.eco, color: Colors.green, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Quantity: $quantity $unit',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farmer\'s Price:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${price.toStringAsFixed(2)}/$unit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Govt. Price:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${govtPrice.toStringAsFixed(2)}/$unit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onOfferTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 36),
                  ),
                  icon: const Icon(Icons.handshake, size: 16),
                  label: const Text('Offer Price'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
