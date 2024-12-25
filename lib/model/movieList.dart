import 'package:molist/model/movie.dart';

class MovieList {
 String? name; // For user-created lists
  final int? page; // Optional, for API-driven lists
  final List<Movie> movies;
  final String? description; // For user-created lists
  final int? totalPages; // Optional, for API-driven lists

  MovieList({
    this.name,
    this.page,
    required this.movies,
    this.description,
    this.totalPages,
  });

  // Factory to create a MovieList from JSON (API-driven)
  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      page: json['page'],
      movies: (json['results'] as List<dynamic>? ?? [])
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList(),
      totalPages: json['total_pages'],
    );
  }

  // Factory for user-created lists
  factory MovieList.userCreated({
    required String name,
    required String description,
    required List<Movie> movies,
  }) {
    return MovieList(
      name: name,
      description: description,
      movies: movies,
    );
  }

  // Convert MovieList to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'movies': movies.map((movie) => movie.toJson()).toList(),
    };
  }

  // Create a MovieList from JSON for user-created lists
  factory MovieList.fromLocalJson(Map<String, dynamic> json) {
    return MovieList(
      name: json['name'],
      description: json['description'],
      movies: (json['movies'] as List<dynamic>? ?? [])
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList(),
    );
  }
}
