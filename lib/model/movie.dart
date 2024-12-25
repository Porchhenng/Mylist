import 'package:molist/model/cast.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  final List<Cast> cast;
  final double popularity;
  final String originalTitle;
  final String originalLanguage;
  final int voteCount;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
    required this.cast,
    required this.popularity,
    required this.originalTitle,
    required this.originalLanguage,
    required this.voteCount,
  });

  // Convert JSON data to a Movie object
  factory Movie.fromJson(Map<String, dynamic> json) {
    var castList = (json['cast'] as List? ?? [])
        .map((castJson) => Cast.fromJson(castJson))
        .toList();

    return Movie(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No Overview Available',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? 'Unknown',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      cast: castList,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      originalTitle: json['original_title'] ?? 'No Original Title',
      originalLanguage: json['original_language'] ?? 'en',
      voteCount: json['vote_count'] ?? 0,
    );
  }

  // Convert Movie object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'genre_ids': genreIds,
      'cast': cast.map((c) => c.toJson()).toList(),
      'popularity': popularity,
      'original_title': originalTitle,
      'original_language': originalLanguage,
      'vote_count': voteCount,
    };
  }
 String toPrompt ( ){
  return "Please Reccomend me 10 movies related to ${this.title},";
 }
}
