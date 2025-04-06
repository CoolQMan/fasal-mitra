import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gdg_solution/utils/farmer_view/Detail_Page_read_only.dart';
import 'package:gdg_solution/utils/farmer_view/Sold_summary.dart';
import 'package:gdg_solution/utils/farmer_view/edit_page.dart';

class ListingListTiles extends StatelessWidget {
  final bool isOffered;
  final String cropName;
  final String dateOfListing;
  final String? dateSold;
  final double yourPrice;
  final double governmentPrice;
  final double? offeredPrice;
  final double? offeredQuantity;
  final String pathImage;
  final double quantity;
  final Function onDelete;
  final String documentId;
  final bool isSold; // New parameter for sold status
  final String? buyerName; // New parameter for buyer name
  final String? buyerID;

  // Enhanced colors for more striking contrast
  static const Color primaryTeal = Color(0xFF009688);
  static const Color lightTeal = Color(0xFFA7FFEB); // Brighter teal
  static const Color darkTeal = Color(0xFF00796B);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFDCEDC8); // Softer green
  static const Color darkGreen = Color(0xFF2E7D32); // Deeper green
  static const Color offeredBadgeColor = Color(0xFF00897B); // Vibrant teal
  static const Color soldBadgeColor = Color(
    0xFF673AB7,
  ); // Purple for sold items
  static const Color soldBackgroundColor = Color(0xFFEDE7F6); // Light purple bg
  static const Color offeredBackgroundColor = Color(
    0xFFE0F2F1,
  ); // Light teal bg
  static const Color unofferedBackgroundColor = Color(
    0xFFF1F8E9,
  ); // Light green bg
  static const Color offeredPriceColor = Color(
    0xFF00BFA5,
  ); // Bright teal for offered price
  static const Color yourPriceColor = Color(
    0xFF43A047,
  ); // Bright green for your price
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);
  static const Color cardShadow = Color(0xFFDDDDDD);
  static const Color deleteRed = Color(0xFFFF5252); // Bright Red Accent
  static const Color deleteRedUnoff = Color(0xFFE53935); // Material Red 600

  ListingListTiles({
    Key? key,
    required this.isOffered,
    required this.cropName,
    required this.dateOfListing,
    this.dateSold,
    required this.yourPrice,
    required this.governmentPrice,
    this.offeredPrice,
    this.offeredQuantity,
    required this.quantity,
    required this.pathImage,
    required this.onDelete,
    required this.documentId,
    this.isSold = false, // Default to false
    this.buyerName, // Optional
    this.buyerID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the background color based on sold status first, then offered status
    Color backgroundColor =
        isSold
            ? soldBackgroundColor
            : isOffered
            ? offeredBackgroundColor
            : unofferedBackgroundColor;

    Color borderColor =
        isSold
            ? soldBadgeColor.withOpacity(0.5)
            : isOffered
            ? lightTeal
            : lightGreen;

    return GestureDetector(
      onTap: () {
        print('is sold ====> $isSold');
        if (isOffered &&
            (offeredQuantity != null && offeredQuantity! > 0) &&
            !isSold) {
          print("isOffered====>$isOffered");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ListingDetailPage(
                    isOffered: isOffered,
                    cropName: cropName,
                    dateOfListing: dateOfListing,
                    yourPrice: yourPrice,
                    governmentPrice: governmentPrice,
                    offeredPrice: offeredPrice,
                    offeredQuantity: offeredQuantity,
                    quantity: quantity,
                    pathImage: pathImage,
                    documentId: documentId,
                  ),
            ),
          );
        }
        if (isSold) {
          print("buyer ID ====> $buyerID");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SoldItemSummaryPage(
                    cropName: cropName,
                    dateOfListing: dateOfListing,
                    dateSold: dateSold!,
                    yourPrice: yourPrice,
                    finalPrice: offeredPrice!,
                    quantity: offeredQuantity!,
                    pathImage: "lib/assets/crops/default_crop.png",
                    buyerName: buyerName!,
                    buyerContact:
                        '+91 ${buyerID?.substring(1)}' ?? "+91 99999 99999",
                    transactionId: "TXN20250403123",
                    paymentMethod: "Bank Transfer",
                    deliveryStatus: "Delivered",
                    deliveryDate: "April 5, 2025",
                    deliveryAddress: "123 Market Street, Bangalore, Karnataka",
                    notes:
                        "Buyer requested premium packaging for longer shelf life.",
                  ),
            ),
          );
        } else if (!isSold && !isOffered) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EditListingPage(
                    cropName: cropName,
                    dateOfListing: dateOfListing,
                    yourPrice: yourPrice,
                    governmentPrice: governmentPrice,
                    quantity: quantity,
                    pathImage: pathImage,
                    documentId: documentId,
                  ),
            ),
          );
        }
      },
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              label: "Delete",
              onPressed: (context) {
                onDelete();
              },
              icon: Icons.delete,
              backgroundColor: isOffered ? deleteRed : deleteRedUnoff,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: borderColor, width: 1.5),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  // Crop Image with distinct border
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSold
                                ? soldBadgeColor
                                : isOffered
                                ? offeredBadgeColor
                                : accentGreen,
                        width: 2.5,
                      ),
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(pathImage),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 14),
                  // Crop Info with improved layout for quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crop name - standalone to avoid overflow
                        Text(
                          cropName,
                          style: TextStyle(
                            color: textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Quantity row with flexible layout
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 6,
                              ),
                              margin: EdgeInsets.only(top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                color:
                                    isSold
                                        ? soldBadgeColor.withOpacity(0.2)
                                        : isOffered
                                        ? lightTeal.withOpacity(0.4)
                                        : lightGreen.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${quantity.toStringAsFixed(1)} kg",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isSold
                                          ? soldBadgeColor
                                          : isOffered
                                          ? darkTeal
                                          : darkGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Date row
                        Text(
                          dateOfListing,
                          style: TextStyle(
                            color: textMedium,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        // Status badges
                        Row(
                          children: [
                            if (isSold)
                              Container(
                                margin: EdgeInsets.only(top: 6, right: 8),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: soldBadgeColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "SOLD",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (isOffered && !isSold)
                              Container(
                                margin: EdgeInsets.only(top: 6),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: offeredBadgeColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "OFFERED",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Buyer name (if sold)
                        if (isSold &&
                            buyerName != null &&
                            buyerName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: soldBadgeColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Sold to: $buyerName",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: soldBadgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Price Display Area
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSold
                                ? soldBadgeColor.withOpacity(0.5)
                                : isOffered
                                ? lightTeal
                                : lightGreen,
                        width: 1,
                      ),
                    ),
                    child:
                        isSold
                            ? Row(
                              children: [
                                _buildPriceColumn(
                                  title: "Final Price",
                                  price:
                                      "₹${(offeredPrice ?? yourPrice).toStringAsFixed(2)}",
                                  titleColor: soldBadgeColor,
                                  priceColor: soldBadgeColor,
                                  isBold: true,
                                ),
                              ],
                            )
                            : isOffered
                            ? Row(
                              children: [
                                _buildPriceColumn(
                                  title: "Your Price",
                                  price: "₹${yourPrice.toStringAsFixed(2)}",
                                  titleColor: darkGreen,
                                  priceColor: yourPriceColor,
                                ),
                                SizedBox(width: 12),
                                _buildPriceColumn(
                                  title: "Offered",
                                  price:
                                      "₹${offeredPrice?.toStringAsFixed(2) ?? '0.00'}",
                                  titleColor: darkTeal,
                                  priceColor: offeredPriceColor,
                                  isBold: true,
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                _buildPriceColumn(
                                  title: "Your Price",
                                  price: "₹${yourPrice.toStringAsFixed(2)}",
                                  titleColor: darkGreen,
                                  priceColor: yourPriceColor,
                                  isBold: true,
                                ),
                                SizedBox(width: 12),
                                _buildPriceColumn(
                                  title: "Govt. Price",
                                  price:
                                      "₹${governmentPrice.toStringAsFixed(2)}",
                                  titleColor: textMedium,
                                  priceColor: textMedium,
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            ),

            // Checkmark overlay for sold items
            if (isSold)
              Positioned(
                top: 8,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: soldBadgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceColumn({
    required String title,
    required String price,
    required Color titleColor,
    required Color priceColor,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: titleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 3),
        Text(
          price,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            color: priceColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
