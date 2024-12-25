import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:molist/model/cast.dart';
import 'package:molist/model/movie.dart'; 
import 'package:molist/model/movieList.dart';


class TMDbService {
  static final String _baseUrl = "https://api.themoviedb.org/3";

  // Fetch popular movies with pagination
  static Future<MovieList> fetchPopularMovies(int page) async {
    final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
    final response = await http.get(
      Uri.parse("$_baseUrl/movie/popular?api_key=$apiKey&page=$page"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MovieList.fromJson(data); 
    } else {
      throw Exception("Failed to load popular movies");
    }
  }
   // Function to fetch movie cast
  static Future<List<Cast>> fetchMovieCast(int movieId) async {
    final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var castList = (data['cast'] as List? ?? [])
          .map((castJson) => Cast.fromJson(castJson))
          .toList();
      return castList;
    } else {
      throw Exception('Failed to load movie cast');
    }
  }
    static Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final apiKey = dotenv.env['TMDB_API_KEY'];
    final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$apiKey&language=en-US&query=$query&page=1&include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body)['results'];
           return results
              .map((data) =>
                  Movie.fromJson(data))
              .toList();
      } else {
        print('Error fetching search results: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }
}
