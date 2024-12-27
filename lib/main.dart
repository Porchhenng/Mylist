import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:molist/model/movieList.dart';
import 'package:molist/reseource/color.dart';
import 'package:molist/reseource/searchMode.dart';
import 'package:molist/screens/GeminiScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/ListScreen.dart';
import 'screens/searchScreen.dart';

Future<void> main() async {
 
  try {
    await dotenv.load(fileName: ".env");
    print("TMDB_API_KEY: ${dotenv.env['TMDB_API_KEY']}");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  runApp(MyApp());
}

enum AppScreen { home, list, search, discovered, user }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Current selected screen
  AppScreen _selectedScreen = AppScreen.home;

  // Map to access the screens based on the enum
  final Map<AppScreen, Widget> _screens = {
    AppScreen.home: HomeScreen(),
    AppScreen.list: ListScreen(movieList: MovieList(
    name: "Current List", 
    movies: [], 
    page: null, 
    totalPages: null,)), 
    AppScreen.search: SearchScreen(searchMode: Searchmode.normal,),
    AppScreen.discovered: GeminiRecommendationScreen(),
    AppScreen.user: UserScreen(),
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedScreen = AppScreen.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: AppColors.primary,
          backgroundColor: AppColors.background,
          
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
        ),
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: Colors.black,
            flexibleSpace: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        body: _screens[_selectedScreen]!,
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            unselectedIconTheme:
                const IconThemeData(color: AppColors.iconColor),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false, // Hide selected item labels
            showUnselectedLabels: false, // Hide unselected item labels
            selectedItemColor: AppColors.selectedItem,
            backgroundColor: AppColors.background,
            currentIndex: AppScreen.values.indexOf(_selectedScreen),
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.house,
                  size: 24,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.film,
                  size: 24,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.searchengin,
                  size: 24,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.lightbulb,
                  size: 24,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.user,
                  size: 24,
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('User Screen'),
    );
  }
}
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child; // Removes the overscroll glow effect
  }
}


