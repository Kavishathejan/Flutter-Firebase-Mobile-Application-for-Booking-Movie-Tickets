import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieCard extends StatelessWidget {
  final String movieId;
  final String title;
  final String genre;
  final String duration;
  final String posterUrl;
  final VoidCallback onTap;

  const MovieCard({
    Key? key,
    required this.movieId,
    required this.title,
    required this.genre,
    required this.duration,
    required this.posterUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Poster
            AspectRatio(
              aspectRatio: 1, // poster-like ratio
              child: posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Container(color: Colors.grey),
                    )
                  : Container(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Genre & Duration
            Padding(
              padding: EdgeInsetsGeometry.only(left: 16),
              child: Text(
                '$genre • ${duration}min',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
