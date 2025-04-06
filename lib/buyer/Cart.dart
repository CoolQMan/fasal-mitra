import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String? buyerId;
  const CartScreen({Key? key, this.buyerId}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<double> _totalNotifier = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _totalNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('cart')
                      .where('buyerId', isEqualTo: widget.buyerId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading cart: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyCart();
                } else {
                  _calculateTotal(snapshot.data!.docs);
                  return _buildCartList(snapshot.data!.docs);
                }
              },
            ),
          ),
          CartSummary(
            totalNotifier: _totalNotifier,
            onCheckout: _processCheckout,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Browse crops and make offers to add items',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<DocumentSnapshot> docs) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doc = docs[index];
        var data = doc.data() as Map<String, dynamic>;
        return CartItemCard(
          cropId: doc.id,
          cropName: data['cropName'] ?? 'Unknown Crop',
          quantity:
              (data['offeredQuantity'] ?? 0)
                  .toDouble(), // Make sure this is correct
          price: (data['offeredValue'] ?? 0).toDouble(),
          imagePath: data['imagePath'] ?? 'lib/assets/crops/default_crop.png',
          farmerName: data['farmerName'] ?? 'Unknown Farmer',
          onRemove: () => _removeFromCart(doc.id),
        );
      },
    );
  }

  double _calculateTotal(List docs) {
    double total = 0.0;
    for (var doc in docs) {
      var data = doc.data() as Map;
      double price = (data['offeredValue'] ?? 0).toDouble();
      double quantity =
          (data['offeredQuantity'] ?? 0)
              .toDouble(); // Make sure this is correct
      total += price * quantity;

      print('The price is ----->$price');
      print('The quantity  is ----->$quantity');
    }

    // Schedule the update after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _totalNotifier.value = total;
    });
    return total;
  }

  Future<void> _removeFromCart(String cartItemId) async {
    try {
      // Get the cart item to retrieve the original crop ID and quantity
      DocumentSnapshot cartItem =
          await _firestore.collection('cart').doc(cartItemId).get();
      Map<String, dynamic> cartData = cartItem.data() as Map<String, dynamic>;
      String originalCropId = cartData['originalCropId'];

      // Ensure offeredQuantity is properly parsed to double
      double offeredQuantity = 0.0;
      if (cartData['offeredQuantity'] != null) {
        offeredQuantity =
            cartData['offeredQuantity'] is String
                ? double.tryParse(cartData['offeredQuantity']) ?? 0.0
                : (cartData['offeredQuantity'] ?? 0).toDouble();
      }

      // Delete from cart first
      await _firestore.collection('cart').doc(cartItemId).delete();

      // Update the original crop listing if needed
      DocumentSnapshot cropDoc =
          await _firestore.collection('crops').doc(originalCropId).get();
      if (cropDoc.exists) {
        Map<String, dynamic> cropData = cropDoc.data() as Map<String, dynamic>;
        String purchaseStatus = cropData['purchaseStatus'] ?? '';

        // Only update quantity if the crop is not sold
        if (purchaseStatus != 'sold') {
          // Ensure current quantity is properly parsed to double
          double currentQuantity = 0.0;
          if (cropData['quantity'] != null) {
            currentQuantity =
                cropData['quantity'] is String
                    ? double.tryParse(cropData['quantity']) ?? 0.0
                    : (cropData['quantity'] ?? 0).toDouble();
          }

          double updatedQuantity = currentQuantity + offeredQuantity;

          // If this buyer owns this offer, reset the offer status
          if (cropData['buyerId'] == widget.buyerId) {
            await _firestore.collection('crops').doc(originalCropId).update({
              'quantity': updatedQuantity,
              'isOffered': false,
              'offeredValue': 0,
              'buyerId': null,
              'buyerName': null,
              'status': null,
            });
          } else {
            // Just update the quantity if the buyer doesn't own the offer status
            await _firestore.collection('crops').doc(originalCropId).update({
              'quantity': updatedQuantity,
            });
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processCheckout() async {
    bool? proceed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Purchase'),
            content: Text('Are you sure you want to complete this purchase?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text('Confirm'),
              ),
            ],
          ),
    );

    if (proceed != true) return;

    try {
      // Get all cart items for this user
      QuerySnapshot cartItems =
          await _firestore
              .collection('cart')
              .where('buyerId', isEqualTo: widget.buyerId)
              .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in cartItems.docs) {
        Map<String, dynamic> cartData = doc.data() as Map<String, dynamic>;
        String originalCropId = cartData['originalCropId'];

        // Create purchase record
        DocumentReference purchaseRef =
            _firestore.collection('purchases').doc();
        batch.set(purchaseRef, {
          'cropId': originalCropId,
          'cropName': cartData['cropName'],
          'buyerId': widget.buyerId,
          'buyerName': cartData['buyerName'],
          'sellerId': cartData['farmerId'],
          'sellerName': cartData['farmerName'],
          'offeredValue': cartData['offeredValue'],
          'offeredQuantity': cartData['offeredQuantity'],
          'purchaseDate': FieldValue.serverTimestamp(),
          'status': 'completed',
          'imagePath': cartData['imagePath'],
        });

        // Update original crop document if it still exists
        DocumentSnapshot cropDoc =
            await _firestore.collection('crops').doc(originalCropId).get();
        if (cropDoc.exists) {
          batch.update(_firestore.collection('crops').doc(originalCropId), {
            'purchaseStatus': 'wating for farmer',
            'purchaseDate': FieldValue.serverTimestamp(),
            'isOffered': true, // Set isOffered to true only after confirmation
            'offeredValue': cartData['offeredValue'],
            'offeredQuantity': cartData['offeredQuantity'],
            'buyerId': widget.buyerId,
            'buyerName': cartData['buyerName'],
          });
        }
        batch.delete(doc.reference);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing purchase: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class CartItemCard extends StatelessWidget {
  final String cropId;
  final String cropName;
  final double quantity;
  final double price;
  final String imagePath;
  final String farmerName;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.cropId,
    required this.cropName,
    required this.quantity,
    required this.price,
    required this.imagePath,
    required this.farmerName,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  imagePath.startsWith('http')
                      ? Image.network(
                        imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 30),
                          );
                        },
                      )
                      : Image.asset(
                        imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 30),
                          );
                        },
                      ),
            ),
            SizedBox(width: 16),
            // Crop Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'by $farmerName',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Quantity: ${quantity.toStringAsFixed(2)} kg',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Price: ₹${price.toStringAsFixed(2)}/kg',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total: ₹${(price * quantity).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final ValueNotifier<double> totalNotifier;
  final VoidCallback onCheckout;

  const CartSummary({
    Key? key,
    required this.totalNotifier,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: totalNotifier,
      builder: (context, totalAmount, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: totalAmount > 0 ? onCheckout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
