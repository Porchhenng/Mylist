import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:molist/model/movieList.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/screens/movieDetails.dart';
import 'package:molist/services/tmdb_service.dart';
import 'package:molist/model/movie.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TMDbService _tmdbService = TMDbService();
  final ScrollController _scrollController = ScrollController();

  List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();

    // Listen to scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchMovies();
      }
    });
  }

Future<void> _fetchMovies() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // Fetch movie list from API
    final MovieList movieList =
        await TMDbService.fetchPopularMovies(_currentPage);

    setState(() {
      _movies.addAll(movieList.movies);

      // Ensure totalPages is non-null before comparison
      if (movieList.totalPages != null) {
        _hasMore = _currentPage < movieList.totalPages!;
      } else {
        _hasMore = false;
      }

      _currentPage++;
    });
  } catch (e) {
    print("Error fetching movies: $e");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
     appBar: AppBar(
  backgroundColor: Colors.black,
  title: null,  
  flexibleSpace: const Row(
    mainAxisAlignment: MainAxisAlignment.start,  // Title aligned to the right
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),  // Add padding around the title
        child: Text(
          'Popular Movies',
          style: Font.headline3,
        ),
      ),
    ],
  ),
),
      body: _movies.isEmpty && !_isLoading
          ? Center(
              child: Text("No movies found",
                  style: TextStyle(color: Colors.white)))
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.65,
                ),
                itemCount:
                    _movies.length + (_hasMore ? 1 : 0), // Add loading indicator
                itemBuilder: (context, index) {
                  if (index == _movies.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final movie = _movies[index];
                  return MovieCard(posterPath: movie.posterPath, movie: movie);
                },
              ),
          ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String posterPath;
  final Movie movie;

  const MovieCard({
    required this.posterPath,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          "https://image.tmdb.org/t/p/w500$posterPath",
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }
}
