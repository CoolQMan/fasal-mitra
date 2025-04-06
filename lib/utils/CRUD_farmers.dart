import 'package:cloud_firestore/cloud_firestore.dart';
import 'crop_data_class.dart';

class CropFirestoreService {
  final CollectionReference cropsCollection = 
      FirebaseFirestore.instance.collection('crops');

  // CREATE - Add a new crop
  Future<String> addCrop(CropData crop) async {
    try {
      DocumentReference docRef = await cropsCollection.add(crop.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding crop: $e');
      throw e;
    }
  }

  // READ - Get all crops
  Stream<List<CropData>> getCrops() {
    return cropsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CropData.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }

  // READ - Get a single crop by ID
  Future<CropData?> getCropById(String cropId) async {
    try {
      DocumentSnapshot doc = await cropsCollection.doc(cropId).get();
      if (doc.exists) {
        return CropData.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }
      return null;
    } catch (e) {
      print('Error getting crop: $e');
      throw e;
    }
  }

  // UPDATE - Update a crop
  Future<void> updateCrop(CropData crop) async {
    try {
      await cropsCollection.doc(crop.id).update(crop.toMap());
    } catch (e) {
      print('Error updating crop: $e');
      throw e;
    }
  }

  // DELETE - Delete a crop
  Future<void> deleteCrop(String cropId) async {
    try {
      await cropsCollection.doc(cropId).delete();
    } catch (e) {
      print('Error deleting crop: $e');
      throw e;
    }
  }

  // READ - Get crops by seller name
  Stream<List<CropData>> getCropsBySeller(String sellerName) {
    return cropsCollection
        .where('Seller_name', isEqualTo: sellerName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CropData.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }

  // READ - Get offered crops
  Stream<List<CropData>> getOfferedCrops() {
    return cropsCollection
        .where('isOffered', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CropData.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }
}
