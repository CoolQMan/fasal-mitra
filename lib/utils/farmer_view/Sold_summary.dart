import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SoldItemSummaryPage extends StatelessWidget {
  final String cropName;
  final String dateOfListing;
  final String dateSold;
  final double yourPrice;
  final double finalPrice;
  final double quantity;
  final String pathImage;
  final String buyerName;
  final String buyerContact;
  final String transactionId;
  final String paymentMethod;
  final String deliveryStatus;
  final String? deliveryDate;
  final String? deliveryAddress;
  final String? notes;

  // Colors
  static const Color primaryPurple = Color(0xFF673AB7);
  static const Color lightPurple = Color(0xFFEDE7F6);
  static const Color darkPurple = Color(0xFF512DA8);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);

  const SoldItemSummaryPage({
    Key? key,
    required this.cropName,
    required this.dateOfListing,
    required this.dateSold,
    required this.yourPrice,
    required this.finalPrice,
    required this.quantity,
    required this.pathImage,
    required this.buyerName,
    required this.buyerContact,
    required this.transactionId,
    required this.paymentMethod,
    required this.deliveryStatus,
    this.deliveryDate,
    this.deliveryAddress,
    this.notes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate profit/loss
    final double difference = finalPrice - yourPrice;
    final bool isProfit = difference >= 0;
    final double profitLossPercentage = (difference / yourPrice) * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Sale Summary",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sharing sale summary...")),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Preparing to print...")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top success banner
            Container(
              color: primaryPurple,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 30,
                top: 10,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: successGreen,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sale Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Transaction ID: $transactionId",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop details card
                  _buildCard(
                    title: "Item Details",
                    icon: Icons.grass,
                    content: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crop image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: dividerColor, width: 1),
                            image: DecorationImage(
                              image: AssetImage(pathImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Crop details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cropName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              _buildDetailRow(
                                "Quantity",
                                "${quantity.toStringAsFixed(1)} kg",
                              ),
                              _buildDetailRow(
                                "Listed on",
                                dateOfListing,
                              ),
                              _buildDetailRow(
                                "Sold on",
                                dateSold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Financial details card
                  _buildCard(
                    title: "Financial Details",
                    icon: Icons.attach_money,
                    content: Column(
                      children: [
                        // Price comparison row
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: lightPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPriceColumn(
                                "Your Price",
                                "₹${yourPrice.toStringAsFixed(2)}",
                                textMedium,
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: primaryPurple,
                              ),
                              _buildPriceColumn(
                                "Final Sale",
                                "₹${finalPrice.toStringAsFixed(2)}",
                                primaryPurple,
                                isBold: true,
                                isLarge: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Profit/Loss indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isProfit
                                ? successGreen.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isProfit
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: isProfit ? successGreen : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isProfit ? "Profit" : "Loss",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isProfit ? successGreen : Colors.red,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "₹${difference.abs().toStringAsFixed(2)} (${profitLossPercentage.abs().toStringAsFixed(1)}%)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isProfit ? successGreen : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Total amount
                        _buildDetailRow(
                          "Total Sale Amount",
                          "₹${(finalPrice * quantity).toStringAsFixed(2)}",
                          isBold: true,
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow("Payment Method", paymentMethod),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Buyer details
                  _buildCard(
                    title: "Buyer Information",
                    icon: Icons.person,
                    content: Column(
                      children: [
                        _buildDetailRow("Name", buyerName, isBold: true),
                        _buildDetailRow("Contact", buyerContact),
                        if (deliveryAddress != null)
                          _buildDetailRow("Address", deliveryAddress!),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Delivery status
                  _buildCard(
                    title: "Delivery Status",
                    icon: Icons.local_shipping,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getDeliveryStatusColor(deliveryStatus),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            deliveryStatus,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (deliveryDate != null)
                          _buildDetailRow(
                            "Delivery Date",
                            deliveryDate!,
                          ),
                      ],
                    ),
                  ),

                  // Notes section (if any)
                  if (notes != null && notes!.isNotEmpty) ...[
                    SizedBox(height: 20),
                    _buildCard(
                      title: "Notes",
                      icon: Icons.note,
                      content: Text(
                        notes!,
                        style: TextStyle(
                          fontSize: 16,
                          color: textMedium,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement contact buyer functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Contacting buyer...")),
                  );
                },
                icon: Icon(Icons.phone),
                label: Text("Contact Buyer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              children: [
                Icon(
                  icon,
                  color: primaryPurple,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Divider(color: dividerColor),
            SizedBox(height: 8),
            // Card content
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: textMedium,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(String label, String price, Color color,
      {bool isBold = false, bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getDeliveryStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return successGreen;
      case 'in transit':
        return accentAmber;
      case 'pending':
        return textMedium;
      case 'cancelled':
        return Colors.red;
      default:
        return primaryPurple;
    }
  }
}