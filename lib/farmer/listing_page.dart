import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdg_solution/utils/crop_data_class.dart';
import 'package:gdg_solution/utils/farmer_view/Add_Listing.dart';
import 'package:gdg_solution/utils/listing_list_tiles.dart';

class ListingPage extends StatefulWidget {
  final String username;
  final String UniqueId;

  ListingPage({super.key, required this.username, required this.UniqueId});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Container(
          margin: EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Listings",
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.username, style: TextStyle(fontSize: 16)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.person, size: 28),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 8, right: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('crops').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No listings found'));
            }

            final crops =
                snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return CropData(
                    id: doc.id,
                    isOffered: data['isOffered'] ?? false,
                    govt_value: data['govt_value'] ?? 0,
                    quantity: data['quantity'] ?? 0,
                    imagePath: data['imagePath'] ?? '',
                    cropName: data['cropName'] ?? '',
                    date: data['date'] ?? '',
                    yoursValue: data['yoursValue'] ?? 0,
                    offeredValue: (data['offeredValue'] ?? 0).toDouble(),
                    offeredQuantity: (data['offeredQuantity'] ?? 0).toDouble(),
                    status: data['purchaseStatus'] ?? 'Not Sold',
                    SellerID: data['sellerId'] ?? widget.UniqueId,
                    Seller_name: data['Seller_name'] ?? widget.username,
                    BuyerID: data['buyerId'] ?? '',
                    Buyer_name: data['buyerName'] ?? '',
                    dateSold: data['dateSold'] ?? '',
                  );
                }).toList();

            return ListView.builder(
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final curr_crop = crops[index];
                return ListingListTiles(
                  isOffered: curr_crop.isOffered,
                  cropName: curr_crop.cropName,
                  governmentPrice: curr_crop.govt_value,
                  dateOfListing: curr_crop.date,
                  yourPrice: curr_crop.yoursValue,
                  quantity: curr_crop.quantity,
                  pathImage: curr_crop.imagePath,
                  offeredPrice: curr_crop.offeredValue,
                  offeredQuantity: curr_crop.offeredQuantity,
                  buyerName: curr_crop.Buyer_name,
                  isSold: (curr_crop.status == 'sold'),
                  buyerID: curr_crop.BuyerID,

                  dateSold: curr_crop.dateSold,

                  onDelete: () async {
                    await _firestore
                        .collection('crops')
                        .doc(curr_crop.id)
                        .delete();
                  },
                  documentId: curr_crop.id!, // Using null assertion operator
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddListingPage(
                      farmerId: widget.UniqueId,
                      username: widget.username,
                    ),
              ),
            );
            // The StreamBuilder will automatically update the list when a new document is added
          },
          backgroundColor: Colors.green.shade400,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(Icons.add, size: 40),
        ),
      ),
    );
  }
}
