class Movie {
  final String id;
  final String title;
  final String genre;
  final int duration; // minutes
  final String description;
  final String posterUrl;

  Movie({required this.id, required this.title, required this.genre, required this.duration, required this.description, required this.posterUrl});

  factory Movie.fromDoc(String id, Map<String, dynamic> d) {
    return Movie(
      id: id,
      title: d['title'] ?? '',
      genre: d['genre'] ?? '',
      duration: d['duration'] ?? 0,
      description: d['description'] ?? '',
      posterUrl: d['posterUrl'] ?? '',
    );
  }
}
