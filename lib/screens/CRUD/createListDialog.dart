import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:molist/model/movie.dart';
import 'package:molist/model/movieList.dart';
import 'package:molist/reseource/color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// Import dotenv for API key

class CreateListScreen extends StatefulWidget {
  final Function(String, List<Movie>) onCreate;

  CreateListScreen({required this.onCreate});

  @override
  _CreateListScreenState createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final TextEditingController listNameController = TextEditingController();
  final TextEditingController listDescController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<Movie> selectedMovies = [];
  List<Movie> searchResults = [];
  bool isSearching = false;

  Future<void> saveListLocally(String listName, List<Movie> movies, String? Description) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_lists.json');

      print(file);

      // Read existing data
      List<dynamic> existingData = [];
      if (file.existsSync()) {
        existingData = json.decode(await file.readAsString());
      }

      // Add the new list
      final newList = {
        'name': listName,
        'description': Description, // Optional description for now
        'movies': movies.map((movie) => movie.toJson()).toList(),
      };

      existingData.add(newList);

      // Save back to the file
      await file.writeAsString(json.encode(existingData));
    } catch (e) {
      print("Error saving list locally: $e");
    }
  }

  Future<void> searchMovies(String query) async {
    setState(() {
      isSearching = true;
    });

    try {
      final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
      final String url =
          'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = (data['results'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        });
      } else {
        print("Error fetching movies: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during movie search: $e");
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A383E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("New List", style: Font.headline3),
        actions: [
          TextButton(
            onPressed: () async {
              final listName = listNameController.text.trim();
              final description = listDescController.text.trim();

              if (listName.isNotEmpty) {
                final newList = MovieList(
                  name: listName,
                  movies: selectedMovies,
                  description: description,
                  page: null,
                  totalPages: null,
                );

                // Save the list locally
                await saveListLocally(listName, selectedMovies, description);

                // Return the new list to the parent screen
                Navigator.pop(context, newList);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('List name cannot be empty!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Save", style: Font.subtitle1),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name", style: TextStyle(color: AppColors.textSecondary)),
            TextField(
              controller: listNameController,
              style: Font.subtitle2,
              decoration: InputDecoration(
                hintText: "Add list name...",
                hintStyle: Font.subtitle2,
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text("Description",
                style: TextStyle(color: AppColors.textSecondary)),
            TextField(
              controller: listDescController,
              style: Font.subtitle2,
              decoration: InputDecoration(
                hintText: "Add  Description...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Add Movies",
                style: Font.subtitle2),
            TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (query) {
                searchMovies(query);
              },
            ),
            const SizedBox(height: 16),
            if (isSearching)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final movie = searchResults[index];
                    final isSelected = selectedMovies.contains(movie);

                    return ListTile(
                      title: Text(
                        movie.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Release Date: ${movie.releaseDate}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      leading: movie.posterPath.isNotEmpty
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.movie, color: Colors.white),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle,
                          color: isSelected ? Colors.green : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              selectedMovies.remove(movie);
                            } else {
                              selectedMovies.add(movie);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
