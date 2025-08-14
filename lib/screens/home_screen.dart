import 'package:cinecapp/screens/logout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final backgroundColor = const Color(0xFF121212);
  final primaryColor = const Color(0xFFBB86FC);
  final cardColor = const Color(0xFF1E1E1E);

  void _showMovieDetails(BuildContext context, String movieId, Map<String, dynamic> movieData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return MovieDetailsScreen(
              movieId: movieId,
              movieData: movieData,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        "Are you sure?",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "Do you really want to log out?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          child: const Text("No", style: TextStyle(color: Colors.redAccent)),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBB86FC),
          ),
          child: const Text("Yes", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
    // Navigate to logout screen instead of directly to login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LogoutScreen()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Now Showing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F0819),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Booking History',
            onPressed: () => Navigator.pushNamed(context, '/bookingHistory'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white60),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.fitHeight,
          ),
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: fs.moviesStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No movies available yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                );
              }

              return Stack(
                children: [
                  CarouselSlider.builder(
                    itemCount: docs.length,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.9,
                      scrollDirection: Axis.vertical,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      viewportFraction: 0.6,
                      autoPlay: false,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () => _showMovieDetails(context, doc.id, data),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.6),
                                offset: const Offset(0, 6),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: MovieCard(
                              movieId: doc.id,
                              title: data['title'] ?? '',
                              genre: data['genre'] ?? '',
                              duration: data['duration']?.toString() ?? '',
                              posterUrl: data['posterUrl'] ?? '',
                              onTap: () => _showMovieDetails(context, doc.id, data),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Top Fade
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF0F0819), Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Fade
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF0F0819), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
