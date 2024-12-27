import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:molist/model/movie.dart';
import 'package:molist/model/movieList.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:molist/model/GeminiSchema.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/services/tmdb_service.dart';
import 'package:path_provider/path_provider.dart';

class GeminiRecommendationScreen extends StatefulWidget {
  const GeminiRecommendationScreen({Key? key}) : super(key: key);

  @override
  _GeminiRecommendationScreenState createState() =>
      _GeminiRecommendationScreenState();
}

class _GeminiRecommendationScreenState
    extends State<GeminiRecommendationScreen> {
  final GenerativeModel weHaveChatGPTatHome = GenerativeModel(
    model: "gemini-1.5-flash-latest",
    apiKey: dotenv.env['GEMINI_API_KEY']!,
    generationConfig: GenerationConfig(
        responseMimeType: 'application/json', responseSchema: movieListSchema),
  );

  Movie? sourceMovie;
  List<Movie> searchResults = [];
  List<Movie> recommendResults = [];
  bool isLoading = false;
  bool isSearching = false;

  Future<void> fetchRecommendations(Movie movie) async {
    setState(() => isLoading = true);
    try {
      String prompt = movie.toPrompt();
      final response = await weHaveChatGPTatHome.generateContent(
        [Content.text(prompt)],
      );

      List<dynamic> results = jsonDecode(response.text!);
      List<Movie> recommendations = [];

      for (String title in results) {
        List<Movie> search = await TMDbService.searchMovies(title);
        if (search.isNotEmpty) recommendations.add(search.first);
      }

      setState(() => recommendResults = recommendations);
      saveListLocally(
          "Generated from ${movie.title}", recommendResults, "this is some movies you should checkout");
    } catch (e) {
      print("Error fetching recommendations: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isSearching = true;
      searchResults.clear();
    });

    try {
      final String apiKey = dotenv.env['TMDB_API_KEY']!;
      final url =
          Uri.parse("https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = (data['results'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        });
      } else {
        print("Error searching movies: ${response.statusCode}");
      }
    } catch (e) {
      print("Error searching movies: $e");
    } finally {
      setState(() => isSearching = false);
    }
  }

  Future<void> saveListLocally(
      String listName, List<Movie> movies, String description) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_lists.json');

      List<dynamic> existingData = [];
      if (file.existsSync()) {
        existingData = json.decode(await file.readAsString());
      }

      existingData.add({
        'name': listName,
        'description': description,
        'movies': movies.map((movie) => movie.toJson()).toList(),
      });

      await file.writeAsString(json.encode(existingData));
    } catch (e) {
      print("Error saving list locally: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A383E),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: sourceMovie != null
            ? Text(
                "Recommendations for ${sourceMovie!.title}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Font.headline3,
              )
            : const Text("Search and Select a Movie", style: Font.headline3,),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: Font.subtitle1,
              onSubmitted: searchMovies,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: 'Search for a movie...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: FaIcon(FontAwesomeIcons.magnifyingGlass,
                      color: AppColors.textPrimary),
                  onPressed: () {
                    searchMovies;
                  },))
            ),
          ),
          if (isSearching)
            const Center(child: CircularProgressIndicator(color: Colors.green))
          else if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green))
          else if (searchResults.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final movie = searchResults[index];
                    return buildMovieListTile(movie, context, () {
                      setState(() {
                        sourceMovie = movie;
                        searchResults.clear();
                      });
                      fetchRecommendations(movie);
                    });
                  },
                ),
              ),
            )
          else if (recommendResults.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: recommendResults.length,
                  itemBuilder: (context, index) {
                    final movie = recommendResults[index];
                    return buildMovieListTile(movie, context, () {});
                  },
                ),
              ),
            )
          else
            const Center(
              child: Text(
                "No results found, Start searching.",
                style: Font.subtitle2,
              ),
            ),
        ],
      ),
    );
  }
}

Widget buildMovieListTile(Movie movie, BuildContext context, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: movie.posterPath != null
                ? Image.network(
                    'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 90,
                    color: Colors.grey,
                    child: const Icon(Icons.movie, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title ?? 'No Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Release Date: ${movie.releaseDate ?? 'N/A'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Language: ${movie.originalLanguage ?? 'N/A'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
