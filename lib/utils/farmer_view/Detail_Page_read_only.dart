import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firestore

class ListingDetailPage extends StatefulWidget {
  final bool isOffered;
  final String cropName;
  final String dateOfListing;
  final double yourPrice;
  final double governmentPrice;
  final double? offeredPrice;
  final double? offeredQuantity;
  final String pathImage;
  final double quantity;
  final String documentId; // Add document ID to identify the specific listing

  const ListingDetailPage({
    Key? key,
    required this.isOffered,
    required this.cropName,
    required this.dateOfListing,
    required this.yourPrice,
    required this.governmentPrice,
    required this.offeredPrice,
    required this.offeredQuantity,
    required this.quantity,
    required this.pathImage,
    required this.documentId, // Required for updating the document
  }) : super(key: key);

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  double? marketPrice;
  bool isLoading = true;
  bool isProcessing =
      false; // Add state to track when an offer is being processed

  @override
  void initState() {
    super.initState();
    fetchMarketPrice();
  }

  Future<void> fetchMarketPrice() async {
    // Simulating API call to fetch market price
    try {
      // In a real app, replace this URL with your actual API endpoint
      final response = await http.get(
        Uri.parse(
          'https://api.example.com/market-prices/${widget.cropName.toLowerCase()}',
        ),
      );

      // Simulate delay for demonstration
      await Future.delayed(Duration(seconds: 1));

      if (response.statusCode == 200) {
        // Parse the response
        // final data = jsonDecode(response.body);
        // marketPrice = data['price'];

        // For demonstration, using a random price based on government price
        marketPrice =
            widget.governmentPrice *
            (0.9 + (0.2 * (DateTime.now().millisecond / 1000)));
      } else {
        // If server returns an error
        marketPrice = null;
      }
    } catch (e) {
      // If there's a network error, use a fallback price
      marketPrice = widget.governmentPrice * 1.05;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to handle accepting an offer
  Future<void> acceptOffer() async {
    setState(() {
      isProcessing = true; // Show loading state
    });

    try {
      // Reference to the Firestore collection and document
      final DocumentReference docRef = FirebaseFirestore.instance
          .collection('crops')
          .doc(widget.documentId);

      // Update the purchaseStatus field to "sold"
      await docRef.update({
        'purchaseStatus': 'sold',
        'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Store timestamp as string
        'dateSold': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Date when offer was accepted
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to a confirmation screen
      Navigator.pop(context, true); // Pass true to indicate successful update
    } catch (e) {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept offer: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset processing state
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // Function to handle declining an offer
  Future<void> declineOffer() async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Reference to the Firestore document
      final DocumentReference docRef = FirebaseFirestore.instance
          .collection('crops')
          .doc(widget.documentId);

      // Update the document - set isOffered to false and clear offer-related fields
      await docRef.update({
        'isOffered': false,
        'offeredQuantity': null,
        'offeredValue': null,
        'purchaseStatus': null,
        'purchaseDate': null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer declined'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context, false); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline offer: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Listing Details'),
        backgroundColor: colors.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image section
            Container(
              width: double.infinity,
              height: size.height * 0.3,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.3),
              ),
              child: Image.asset(widget.pathImage, fit: BoxFit.contain),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.cropName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Offer Received",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Quantity and listing date
                  _buildInfoRow(
                    context,
                    Icons.scale,
                    "Quantity",
                    "${widget.quantity} kg",
                  ),

                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    "Listed on",
                    widget.dateOfListing,
                  ),

                  Divider(height: 32),

                  // Price information
                  Text(
                    "Price Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Your price
                  _buildPriceCard(
                    context,
                    "Your Price",
                    "₹${widget.yourPrice}",
                    Colors.green,
                    "per kg",
                  ),

                  SizedBox(height: 12),

                  // Government price
                  _buildPriceCard(
                    context,
                    "Government Price",
                    "₹${widget.governmentPrice}",
                    Colors.blue,
                    "per kg",
                  ),

                  // Market price (fetched from internet)
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Market Price",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  marketPrice != null
                                      ? "₹${marketPrice!.toStringAsFixed(2)}"
                                      : "Not available",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                Text(
                                  "per kg",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),

                  // Offered price if available
                  SizedBox(height: 12),
                  _buildPriceCard(
                    context,
                    "Offered Price",
                    "₹${widget.offeredPrice}",
                    Colors.orange,
                    "per kg",
                  ),

                  SizedBox(height: 12),
                  _buildPriceCard(
                    context,
                    "Offered Quantity",
                    "${widget.offeredQuantity} kg",
                    Colors.purpleAccent,
                    "",
                  ),

                  SizedBox(height: 24),

                  // Total value
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.primaryContainer),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Value",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "₹${(widget.yourPrice * widget.quantity).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Offered Total: ₹${(widget.offeredPrice! * widget.offeredQuantity!).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Action buttons for offered listings
                  isProcessing
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  acceptOffer, // Connect to the accept offer function
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "Accept Offer",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  declineOffer, // Connect to the decline offer function
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "Decline Offer",
                                style: TextStyle(color: Colors.red),
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
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 12),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    BuildContext context,
    String title,
    String price,
    Color priceColor,
    String unit,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: priceColor,
                ),
              ),
              if (unit.isNotEmpty)
                Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
