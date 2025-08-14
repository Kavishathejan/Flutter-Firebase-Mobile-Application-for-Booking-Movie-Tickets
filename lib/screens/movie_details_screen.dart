import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import '../services/firestore_service.dart';
import 'seat_selection_screen.dart';

class MovieDetailsScreen extends StatelessWidget {
  final String movieId;
  final Map<String, dynamic> movieData;
  final ScrollController scrollController;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    required this.movieData,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // Poster
            if (movieData['posterUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movieData['posterUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 320, 
                ),
              ),
            const SizedBox(height: 12),

            // Title
            Text(
              movieData['title'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // Genre & Duration
            Text(
              '${movieData['genre'] ?? ''} • ${movieData['duration'] ?? ''} min',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              movieData['description'] ?? '',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Showtimes Title
            const Text(
              'Showtimes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Showtimes List
            StreamBuilder<QuerySnapshot>(
              stream: fs.showtimesStream(movieId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    ),
                  );
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No showtimes available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return Column(
                  children: docs.map((d) {
                    final dt = (d['startAt'] as Timestamp).toDate();
                    final price = (d['price'] ?? 0).toDouble();
                    
                    
                    final timeFormat = DateFormat('h:mm a'); 
                    final formattedTime = timeFormat.format(dt);
                    
                    
                    final dateFormat = DateFormat('EEE, MMM d');
                    final formattedDate = dateFormat.format(dt);

                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Price: Rs.${price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 55, 115, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              SeatSelectionScreen.routeName,
                              arguments: {
                                'movieId': movieId,
                                'showtimeId': d.id,
                                'movieTitle': movieData['title'],
                                'showtime': formattedTime, 
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}