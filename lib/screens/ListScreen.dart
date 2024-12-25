import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:molist/model/movie.dart';
import 'package:molist/model/movieList.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/reseource/searchMode.dart';
import 'package:molist/screens/CRUD/createListDialog.dart';
import 'package:molist/screens/CRUD/movieListViewScreen.dart';
import 'package:path_provider/path_provider.dart';

class ListScreen extends StatefulWidget {
  final MovieList movieList;

  const ListScreen({
    Key? key,
    required this.movieList,
  }) : super(key: key);

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  late List<Movie> _movies;
  late List<MovieList> _userCreatedLists = [];

  Searchmode searchMode = Searchmode.addMovie;

  @override
  void initState() {
    super.initState();
    _movies = widget.movieList.movies;
    _loadUserCreatedLists();
  }

  Future<void> _loadUserCreatedLists() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_lists.json');

      if (file.existsSync()) {
        final data = json.decode(await file.readAsString());
        setState(() {
          _userCreatedLists = (data as List<dynamic>)
              .map((listJson) => MovieList.fromLocalJson(listJson))
              .toList();
        });
      }
    } catch (e) {
      print("Error loading user-created lists: $e");
    }
  }

  Future<void> saveListLocally(String listName, List<Movie> movies) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_lists.json');

      // Read existing data or create a new list if none exists
      List<dynamic> existingData = [];
      if (file.existsSync()) {
        existingData = json.decode(await file.readAsString());
      }

      // Check if the list already exists
      final index = existingData.indexWhere((list) => list['name'] == listName);
      if (index != -1) {
        // Update the existing list
        existingData[index]['movies'] =
            movies.map((movie) => movie.toJson()).toList();
      } else {
        // Add a new list if it doesn't exist
        existingData.add({
          'name': listName,
          'description': '', // Optional description
          'movies': movies.map((movie) => movie.toJson()).toList(),
        });
      }

      // Write updated data back to the file
      await file.writeAsString(json.encode(existingData));
    } catch (e) {
      print("Error saving list locally: $e");
    }
  }

  Future<void> _saveUserCreatedLists() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_lists.json');

      // Convert all user-created lists to JSON
      final data = _userCreatedLists.map((list) => list.toJson()).toList();

      // Write updated data to the file
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print("Error saving all user-created lists: $e");
    }
  }

  void _removeList(int index) {
    // Remove the list from memory and update the local JSON file
    setState(() {
      _userCreatedLists.removeAt(index);
    });
    _userCreatedLists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 56, 62),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.movieList.name ?? "My Lists",
          style: Font.headline3,
        ),
      ),
      body: ListView.builder(
        itemCount: _userCreatedLists.length,
        itemBuilder: (context, index) {
          final userList = _userCreatedLists[index];

          return Dismissible(
            key: Key(userList.name ?? 'List_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.transparent,
              padding: const EdgeInsets.only(right: 20.0),
             
            ),
            onDismissed: (direction) async {
              final removedList = _userCreatedLists[index];

              setState(() {
                _userCreatedLists.removeAt(index);
              });

              await _saveUserCreatedLists();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${removedList.name ?? "Unnamed List"} deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      setState(() {
                        _userCreatedLists.insert(index, removedList);
                      });

                      await _saveUserCreatedLists();
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      title: Text(
                        userList.name ?? "Unnamed List",
                        style: Font.subtitle1,
                      ),
                      subtitle: Text(
                        userList.description ?? "",
                        style: Font.subtitle2,
                      ),
                      trailing: Text(
                        "${userList.movies.length} movies",
                        style: Font.bodyText1,
                      ),
                      onTap: () async {
                        final updatedMovieList =
                            await Navigator.push<MovieList>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieListViewScreen(
                              movieList: userList,
                              onUpdate: (updatedMovieList) {
                                if (!mounted) return;
                                setState(() {
                                  final index = _userCreatedLists.indexWhere(
                                      (list) =>
                                          list.name == updatedMovieList.name);
                                  if (index != -1) {
                                    _userCreatedLists[index] = updatedMovieList;
                                  }
                                });
                              },
                            ),
                          ),
                        );

                        // Check if the updated list is not null and apply updates
                        if (updatedMovieList != null) {
                          setState(() {
                            final index = _userCreatedLists.indexWhere(
                                (list) => list.name == updatedMovieList.name);
                            if (index != -1) {
                              _userCreatedLists[index] = updatedMovieList;
                            }
                          });
                        }
                      }),
                  userList.movies.isNotEmpty
                      ? SizedBox(
                          height: 150,
                          child: Stack(
                            children:
                                userList.movies.asMap().entries.map((entry) {
                              final movie = entry.value;
                              final position =
                                  entry.key * 50.0; // Offset for stacking
                              return Positioned(
                                left: position,
                                
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image,
                                          color: Colors.grey);
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "No movies in this list",
                            style: Font.bodyText2,
                          ),
                        ),
                  const Divider(color: Colors.white24), // Divider between lists
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open the CreateListScreen
          final newMovieList = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateListScreen(
                onCreate: (listName, description) {
                  // Create a new MovieList object
                  final newList = MovieList(
                    name: listName,
                    movies: [],
                    page: null,
                    totalPages: null,
                  );

                  setState(() {
                    // Add the new MovieList to the user-created lists
                    _userCreatedLists.add(newList);
                  });

                  // Save the new MovieList locally
                  _saveUserCreatedLists();
                },
              ),
            ),
          );

          // If a new MovieList was returned, add it to the state
          if (newMovieList != null && newMovieList is MovieList) {
            setState(() {
              _userCreatedLists.add(newMovieList);
            });
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
