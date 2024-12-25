import 'package:flutter/material.dart';

class ListDetailScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categorizedLists;

  ListDetailScreen({required this.categorizedLists});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 42, 56, 62),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'porchheng',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              'List',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: categorizedLists.length,
          itemBuilder: (context, index) {
            final category = categorizedLists[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 150, // Height of the horizontal movie list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category['movies'].length,
                    itemBuilder: (context, movieIndex) {
                      final movie = category['movies'][movieIndex];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: movie['posterPath'] != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w200${movie['posterPath']}',
                                      width: 100,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 150,
                                      color: Colors.grey,
                                      child: Icon(
                                        Icons.movie,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              movie['title'] ?? 'No Title',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16), // Spacing between categories
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print("Reply clicked");
        },
        backgroundColor: Colors.grey[850],
        label: Text(
          "Reply",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
