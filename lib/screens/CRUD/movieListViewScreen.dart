import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:molist/model/movie.dart';
import 'package:molist/model/movieList.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/reseource/searchMode.dart';
import 'package:molist/screens/movieDetails.dart';
import 'package:molist/screens/searchScreen.dart';
import 'package:path_provider/path_provider.dart';

class MovieListViewScreen extends StatefulWidget {
  final MovieList movieList;
  final Function(MovieList) onUpdate;

  const MovieListViewScreen({
    Key? key,
    required this.movieList,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _MovieListViewScreenState createState() => _MovieListViewScreenState();
}

class _MovieListViewScreenState extends State<MovieListViewScreen> {
  bool isVertical = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A383E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.movieList.name ?? "Movie List",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditTitleDialog(),
          ),
          IconButton(
            icon: Icon(
              isVertical ? Icons.grid_view : Icons.view_list,
              color: Colors.white,
            ),
            onPressed: () {
              // Toggle between vertical and grid layout
              setState(() {
                isVertical = !isVertical;
              });
            },
          ),
        ],
      ),
      body: widget.movieList.movies.isEmpty
          ? const Center(
              child: Text(
                'No movies in this list',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : isVertical
              ? _buildVerticalList()
              : _buildGridList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to SearchScreen to add a movie
          final newMovie = await Navigator.push<Movie>(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(
                searchMode: Searchmode.addMovie,
              ),
            ),
          );

          if (newMovie != null) {
            // Add the new movie to the current list
            setState(() {
              widget.movieList.movies.add(newMovie);
            });

            // Update the local JSON file with the updated movie list
            await _updateLocalData(widget.movieList);

            // Notify the parent (if needed)
            widget.onUpdate(widget.movieList);
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

Future<void> _updateLocalData(MovieList updatedList) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_lists.json');

    if (file.existsSync()) {
      final data = json.decode(await file.readAsString());

      // Update the specific list in local storage
      List<dynamic> updatedLists = (data as List<dynamic>).map((listJson) {
        if (listJson['name'] == updatedList.name) {
          return updatedList.toJson();
        }
        return listJson;
      }).toList();

      await file.writeAsString(json.encode(updatedLists));
    }
  } catch (e) {
    print("Error updating local data: $e");
  }
}


  void _showEditTitleDialog() {
    String newTitle = widget.movieList.name ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            "Edit List Title",
            style: Font.subtitle1,
          ),
          content: TextField(
            style: Font.bodyText1,
            onChanged: (value) {
              newTitle = value;
            },
            controller: TextEditingController(text: newTitle),
            decoration: const InputDecoration(
              hintText: "Enter new title",
              hintStyle: const TextStyle(color: Colors.grey), // Hint text color
              filled: true,
              fillColor: AppColors.background,
              labelStyle: Font.subtitle1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (newTitle.isNotEmpty) {
                  setState(() {
                    widget.movieList.name = newTitle;
                  });
                  await _updateLocalData(widget.movieList);
                  widget.onUpdate(widget.movieList);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Title cannot be empty!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalList() {
    return ListView.builder(
      itemCount: widget.movieList.movies.length,
      itemBuilder: (context, index) {
        final movie = widget.movieList.movies[index];

        return Dismissible(
          key: Key(movie.id.toString()), // Unique key for each movie
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.transparent,
            padding: const EdgeInsets.only(right: 20.0),
          ),
          onDismissed: (direction) async {
            final removedMovie = widget.movieList.movies[index];

            setState(() {
              widget.movieList.movies.removeAt(index);
            });

            await _updateLocalData(widget.movieList);

            // Notify the parent (ListScreen) about the updated movie list
            widget.onUpdate(widget.movieList);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${removedMovie.title} removed from the list"),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    setState(() {
                      widget.movieList.movies.insert(index, removedMovie);
                    });

                    // Update local storage again
                    await _updateLocalData(widget.movieList);
                    widget
                        .onUpdate(widget.movieList); // Notify parent about undo
                  },
                ),
              ),
            );
          },

          child: _buildMovieCard(movie),
        );
      },
    );
  }

  Widget _buildGridList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.5, // Adjust to control card proportions
      ),
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.movieList.movies.length,
      itemBuilder: (context, index) {
        final movie = widget.movieList.movies[index];

        return Dismissible(
          key: Key(movie.id.toString()),
          direction: DismissDirection.vertical,
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.transparent,
            padding: const EdgeInsets.only(right: 20.0),
          ),
          onDismissed: (direction) async {
            // Remove the movie
            final removedMovie = widget.movieList.movies[index];

            setState(() {
              widget.movieList.movies.removeAt(index);
            });

            // Update local storage
            await _updateLocalData(widget.movieList);

            // Show Snackbar with undo option
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${removedMovie.title} removed from the list"),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    setState(() {
                      widget.movieList.movies.insert(index, removedMovie);
                    });

                    // Update local storage again
                    await _updateLocalData(widget.movieList);
                  },
                ),
              ),
            );
          },
          child: _buildMovieGridCard(movie),
        );
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xFF1F2C34),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: movie.posterPath.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 150,
                            color: Colors.grey,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 150,
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
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Release Date: ${movie.releaseDate}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieGridCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF1F2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: movie.posterPath.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey,
                      child: const Icon(Icons.movie, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
