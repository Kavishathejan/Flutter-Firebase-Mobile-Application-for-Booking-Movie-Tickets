import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Stream<QuerySnapshot> moviesStream() {
    return _db.collection('movies').orderBy('title').snapshots();
  }

 
  Stream<QuerySnapshot> showtimesStream(String movieId) {
    return _db.collection('movies').doc(movieId).collection('showtimes').orderBy('startAt').snapshots();
  }

  Future<DocumentSnapshot> getShowtime(String movieId, String showtimeId) {
    return _db.collection('movies').doc(movieId).collection('showtimes').doc(showtimeId).get();
  }

  
  Future<void> bookSeats({
    required String movieId,
    required String showtimeId,
    required String userId,
    required String movieTitle,
    required List<String> seats,
    required double totalPrice,
  }) async {
    final showtimeRef = _db.collection('movies').doc(movieId).collection('showtimes').doc(showtimeId);
    final userBookingRef = _db.collection('users').doc(userId).collection('bookings').doc();

    return _db.runTransaction((tx) async {
      final snap = await tx.get(showtimeRef);
      if (!snap.exists) throw Exception('Showtime no longer exists');

      final data = snap.data() as Map<String, dynamic>;
      final booked = List<String>.from(data['bookedSeats'] ?? []);
      
      for (var s in seats) {
        if (booked.contains(s)) {
          throw Exception('Seat $s is already booked');
        }
      }
      final updatedBooked = List<String>.from(booked)..addAll(seats);
      tx.update(showtimeRef, {'bookedSeats': updatedBooked});

      tx.set(userBookingRef, {
        'movieId': movieId,
        'movieTitle': movieTitle,
        'showtimeId': showtimeId,
        'seats': seats,
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  
  Stream<QuerySnapshot> userBookingsStream(String userId) {
    return _db.collection('users').doc(userId).collection('bookings').orderBy('createdAt', descending: true).snapshots();
  }

  
  Future<void> addMovieWithShowtime(Map<String, dynamic> movieData, List<Map<String, dynamic>> showtimes) async {
    final movieRef = await _db.collection('movies').add(movieData);
    for (var s in showtimes) {
      await movieRef.collection('showtimes').add(s);
    }
  }
}
