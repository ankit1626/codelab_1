import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  void loadselectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    });
  }

  void setselectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedIndex', selectedIndex);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadselectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  setselectedIndex();
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  var current = WordPair.random();
  static var favorites = [];
  void loadfavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var favorite = prefs.getString('favorites') ?? [].toString();
      favorites = jsonDecode(favorite);
    });
  }

  void setfavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', jsonEncode(favorites));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadfavorites();
  }

  void getNext() {
    current = WordPair.random();
    setState(() {});
  }

  void toggleFavorite() {
    if (favorites.contains(current.asString)) {
      favorites.remove(current.asString);
      setfavorites();
    } else {
      favorites.add(current.asString);
      setfavorites();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (favorites.contains(current.asString)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: current),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Card(
      color: theme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Text(pair.asLowerCase,
            style: textstyle, semanticsLabel: "${pair.first} ${pair.second}"),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  var fav = _GeneratorPageState.favorites;

  void loadfavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var favorite = prefs.getString('favorites') ?? [].toString();
      fav = jsonDecode(favorite);
    });
  }

  void setfavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'favorites', jsonEncode(_GeneratorPageState.favorites));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadfavorites();
  }

  void removeFavorite(value) {
    _GeneratorPageState.favorites.removeAt(value);
    fav.removeAt(value);
    setfavorites();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: fav.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPressEnd: (details) {
              removeFavorite(index);
            },
            child: Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              elevation: 2.0,
              margin: EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(fav[index]),
              ),
            ),
          );
        });
  }
}
