class CropData {
  final bool isOffered;
  final String imagePath; // Path to the image
  final String cropName; // Crop name (e.g., "Grain")
  final String date; // Date (e.g., "21st Jan 2025")
  final String? dateSold;
  final double yoursValue; // Value for "Yours"
  final double offeredValue; // Value for "Offered"
  final double offeredQuantity;
  final double govt_value; // Value for "Government"
  final double quantity;
  final String? Seller_name;
  final String? Buyer_name;
  final String? BuyerID;
  final String? SellerID;

  final String? Desciption_crop;
  final String? id; // For Firestore document ID

  final String? status;

  CropData({
    required this.imagePath,
    required this.cropName,
    required this.date,
    this.dateSold,
    required this.yoursValue,
    required this.offeredValue,
    required this.offeredQuantity,
    required this.govt_value,
    this.Seller_name,
    required this.isOffered,
    this.Desciption_crop,
    this.SellerID,
    this.BuyerID,
    this.Buyer_name,

    required this.quantity,
    this.id,
    required this.status,
  });

  // Convert CropData to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'isOffered': isOffered,
      'imagePath': imagePath,
      'cropName': cropName,
      'date': date,
      'dateSold' : dateSold,
      'yoursValue': yoursValue,
      'offeredValue': offeredValue,
      'offeredQuantity': offeredQuantity,
      'govt_value': govt_value,
      'quantity': quantity,
      'Seller_name': Seller_name,
      'Desciption_crop': Desciption_crop,
      'sellerId': SellerID,
      'buyerId': BuyerID,
      'buyerName': Buyer_name,
      'purchaseStatus': status,
    };
  }

  // Create CropData from Firestore document
  factory CropData.fromFirestore(Map<String, dynamic> data, String docId) {
    return CropData(
      id: docId,
      isOffered: data['isOffered'] ?? false,
      imagePath: data['imagePath'] ?? '',
      cropName: data['cropName'] ?? '',
      date: data['date'] ?? '',
      dateSold : data['dateSold'] ?? '',
      yoursValue: (data['yoursValue'] ?? 0).toDouble(),
      offeredValue: (data['offeredValue'] ?? 0).toDouble(),
      offeredQuantity: (data['offeredQuantity'] ?? 0).toDouble(),
      govt_value: (data['govt_value'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toDouble(),
      Seller_name: data['Seller_name'],
      SellerID: data['sellerId'],
      BuyerID: data['buyerId'],
      Buyer_name: data['buyerName'],
      Desciption_crop: data['Desciption_crop'],
      status: data['purchaseStatus'],
    );
  }

  // Create a copy of CropData with updated fields
  CropData copyWith({
    bool? isOffered,
    String? imagePath,
    String? cropName,
    String? date,
    String? dateSold,
    double? yoursValue,
    double? offeredValue,
    double? offeredQuantity,
    double? govt_value,
    double? quantity,
    String? Seller_name,
    String? SellerID,
    String? BuyerID,
    String? Buyer_name,

    String? Desciption_crop,
    String? id,
  }) {
    return CropData(
      isOffered: isOffered ?? this.isOffered,
      imagePath: imagePath ?? this.imagePath,
      cropName: cropName ?? this.cropName,
      date: date ?? this.date,
      dateSold: dateSold ?? this.dateSold,
      yoursValue: yoursValue ?? this.yoursValue,
      offeredValue: offeredValue ?? this.offeredValue,
      offeredQuantity: offeredQuantity ?? this.offeredQuantity,
      govt_value: govt_value ?? this.govt_value,
      quantity: quantity ?? this.quantity,
      Seller_name: Seller_name ?? this.Seller_name,
      SellerID: SellerID ?? this.SellerID,
      BuyerID: BuyerID ?? this.BuyerID,
      Buyer_name: Buyer_name ?? this.Buyer_name,
      Desciption_crop: Desciption_crop ?? this.Desciption_crop,
      id: id ?? this.id,
      status: status ?? this.status,
    );
  }
}
