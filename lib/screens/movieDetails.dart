import 'package:flutter/material.dart';
import 'package:molist/model/cast.dart';
import 'package:molist/model/movie.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/services/tmdb_service.dart'; // Import your TMDB service

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TMDbService _tmdbService = TMDbService(); // Instance of TMDbService
  List<Cast> _cast = [];
  bool _isLoadingCast = false;
  bool _hasMoreCast = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieCast(widget.movie.id); // Fetch cast for the movie
  }

  Future<void> _fetchMovieCast(int movieId) async {
    if (_isLoadingCast || !_hasMoreCast) return;

    setState(() {
      _isLoadingCast = true;
    });

    try {
      final List<Cast> castList = await TMDbService.fetchMovieCast(movieId);

      setState(() {
        _cast.addAll(castList);
        _hasMoreCast = castList.isNotEmpty; 
      });
    } catch (e) {
      print("Error fetching cast: $e");
    } finally {
      setState(() {
        _isLoadingCast = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: null,
        slivers: [
          
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  Image.network(
                    "https://image.tmdb.org/t/p/w500${widget.movie.backdropPath}",
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                 Container(
                    clipBehavior: Clip.none,
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        // stops: const [0, 1],
                        colors: [
                          AppColors.background,
                          AppColors.background.withAlpha(5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
                    // Spacer
          const SliverToBoxAdapter(
            child: SizedBox(height: 30), // Adjust height as needed
          ),
          
          // Main content starts here
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Left side: Text content
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie Title
                        Text(
                          overflow: TextOverflow.clip,
                          widget.movie.title,
                          style: Font.headline1
                        ),
                        SizedBox(height: 8),

                        // Overview
                        Text(
                          widget.movie.overview,
                          style: Font.bodyText1,
                        ),
                        SizedBox(height: 16),

                        // Rating
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.yellow, size: 40),
                            SizedBox(width: 4),
                            Text(
                              widget.movie.voteAverage?.toString() ?? 'N/A',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 32),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Right side: Movie Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://image.tmdb.org/t/p/w500${widget.movie.posterPath}",
                      height: 300,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              
              
              
            ),
            
          ),
          // Genres Section at the Bottom
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Genres:',
                  style:Font.headline3
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: widget.movie.genreIds.map((genreId) {
                    return Chip(
                      label: Text(
                        genreId.toString(), 
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blueGrey,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        // Spacer
        const SliverToBoxAdapter(
          child: SizedBox(height: 30),
        ),
        // Cast Section at the Bottom
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cast:',
                  style: Font.headline3
                ),
                SizedBox(height: 8),
                _isLoadingCast
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _cast.isNotEmpty
                        ? Column(
                            children: _cast.map((actor) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: actor.profilePath != null
                                    ? ClipOval(
                                        child: Image.network(
                                          "https://image.tmdb.org/t/p/w500${actor.profilePath}",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(Icons.person, color: Colors.white),
                                title: Text(
                                  actor.name,
                                  style: Font.subtitle1
                                ),
                                subtitle: Text(
                                  actor.character,
                                  style: Font.subtitle2,
                                ),
                              );
                            }).toList(),
                          )
                        : Text(
                            'No cast available',
                            style: TextStyle(color: Colors.white70),
                          ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}        

}