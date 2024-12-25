import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  GenerativeModel weHaveChatGPTatHome = GenerativeModel(
    model: "gemini-1.5-flash-latest",
    apiKey: dotenv.env['GEMINI_API_KEY']!,
    generationConfig: GenerationConfig(
        responseMimeType: 'application/json', responseSchema: movieListSchema),
  );
  Movie? sourceMovie;
  MovieList? recommendations;
  List<Movie> searchResults = [];
  List<Movie> reccomendResult = [];
  bool isLoadingRec = false;
  bool isLoading = false;
  bool isSearching = false;

  Future<void> fetchRecommendations(Movie movie) async {
    setState(() {
      isLoading = true;
      print('start');
    });
    String prompt = movie.toPrompt();

    final GenerateContentResponse response =
        await weHaveChatGPTatHome.generateContent(
      [Content.text(prompt)],
    );
    print("run this");

    List<dynamic> results = jsonDecode(response.text!);

    List<Movie> list = [];

    for (String result in results) {
      List<Movie> search = await TMDbService.searchMovies(result);
      if (search.isNotEmpty) {
        list.add(search.first);
      }
      reccomendResult = list;
      print(reccomendResult);
    }
    print(results);
    setState(() {
      isLoading = false;
    });
    saveListLocally(
        "Recommended List", reccomendResult, "generated from ur choice");
  }

  Future<void> searchMovies(String query) async {
    try {
      setState(() {
        isSearching = true;
        reccomendResult.clear();
      });

      final String apiKey = "c71d41fc40e414d01d6a1c0c531e5e70";
      final String url =
          "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query";

      final response = await http.get(Uri.parse(url));

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
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> saveListLocally(
      String listName, List<Movie> movies, String? Description) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_lists.json');

      print(file);

      List<dynamic> existingData = [];
      if (file.existsSync()) {
        existingData = json.decode(await file.readAsString());
      }
      final newList = {
        'name': listName,
        'description': Description, // Optional description for now
        'movies': reccomendResult.map((movie) => movie.toJson()).toList(),
      };

      existingData.add(newList);
      print(newList);

      // Save back to the file
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
        backgroundColor: Colors.black,
        title: sourceMovie != null
            ? Text(
                "Recommendations for ${sourceMovie!.title}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
              )
            : const Text("Search and Select a Movie"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: Font.subtitle1,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  searchMovies(query);
                }
              },
              decoration: InputDecoration(
                hintText: "Need a reccomendation?",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (isSearching)
            const Center(child: CircularProgressIndicator(color: Colors.green))
          else if (reccomendResult.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: reccomendResult.length,
                itemBuilder: (context, index) {
                  final movie = reccomendResult[index];
                  return buildMovieListTile(movie, context, () {
                    fetchRecommendations(movie);
                  });
                },
              ),
            )
          else if (sourceMovie != null && recommendations != null)
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : recommendations!.movies.isEmpty
                    ? const Center(
                        child: Text(
                          "No recommendations available.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Expanded(
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
                      )
          else if (searchResults.isNotEmpty)
            Expanded(
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
                      )
          else if (sourceMovie != null && recommendations != null)
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : recommendations!.movies.isEmpty
                    ? const Center(
                        child: Text(
                          "No recommendations available.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Expanded(
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
                      )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

Widget buildMovieListTile(
    Movie movie, BuildContext context, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
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
          // Movie Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
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
