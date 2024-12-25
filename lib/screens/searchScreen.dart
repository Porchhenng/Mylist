import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/reseource/searchMode.dart';
import 'package:molist/screens/movieDetails.dart';

import '../model/movie.dart';

class SearchScreen extends StatefulWidget {
  final Searchmode searchMode;
  @override
  _SearchScreenState createState() => _SearchScreenState();
  
  const SearchScreen({super.key, required this.searchMode});
}

class _SearchScreenState extends State<SearchScreen> {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  

  // Search for movies using TMDB API
  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final apiKey = dotenv.env['TMDB_API_KEY'];
    final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$apiKey&language=en-US&query=$query&page=1&include_adult=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body)['results'];
        setState(() {
          _searchResults = results
              .map((data) =>
                  Movie.fromJson(data)) // Convert JSON to Movie objects
              .toList();
          _isLoading = false;
        });
      } else {
        print('Error fetching search results: ${response.statusCode}');
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Search Movies', style: Font.headline3),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              style: Font.subtitle1,
              controller: _searchController,
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
                    _searchMovies(_searchController.text);
                  },
                ),
              ),
              onSubmitted: _searchMovies,
            ),
            SizedBox(height: 16),
            // Results or Loading Indicator
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: AppColors.selectedItem))
                : _searchResults.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'No results found. Start searching!',
                            style: Font.subtitle2,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[700], // Line color
                            thickness: 0.5, // Line thickness
                            indent: 80, // Space from left edge
                          ),
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.searchMode == Searchmode.normal) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MovieDetailsScreen(
                                          movie: movie,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pop(movie);
                                  }
                                },
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
                                              child: Icon(Icons.movie,
                                                  color: Colors.white),
                                            ),
                                    ),
                                    SizedBox(width: 16),
                                    // Movie Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(movie.title ?? 'No Title',
                                              style: Font.subtitle1),
                                          SizedBox(height: 4),
                                          Text(
                                              'Release Date: ${movie.releaseDate ?? 'N/A'}',
                                              style: Font.subtitle2),
                                          SizedBox(height: 4),
                                          Text(
                                              'Language: ${movie.originalLanguage}',
                                              style: Font.subtitle2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
