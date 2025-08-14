import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class BookingHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Not logged in',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Bookings',
         style:TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),),
       
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fs.userBookingsStream(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final booking = docs[i].data() as Map<String, dynamic>;
              final created = (booking['createdAt'] as Timestamp?)?.toDate();

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Title
                      Text(
                        booking['movieTitle'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),

                      // Seats & Price
                      Text(
                        'Seats: ${(booking['seats'] ?? []).join(', ')}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Price: \Rs.${(booking['totalPrice'] ?? 0).toString()}',
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 8),

                      // Date
                      if (created != null)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '${created.toLocal()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
