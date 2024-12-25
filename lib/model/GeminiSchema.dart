import 'package:google_generative_ai/google_generative_ai.dart';

final Schema movieListSchema = Schema.array(
    items: Schema.string(description: "The Movie Title", nullable: false),
    description: "List of movies title",
    nullable: false);
