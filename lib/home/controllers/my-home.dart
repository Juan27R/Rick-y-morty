import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rickandmortyapp/home/models/character_details_screen.dart';
import 'package:rickandmortyapp/home/repository/home-api-repository.dart';
import 'package:rickandmortyapp/home/screens/ui/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/character': (context) => CharacterDetailsPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> characters = [];

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  void fetchCharacters() async {
    try {
      http.Response response = await HomeApiRepository().getCharacters();
      List<dynamic> fetchedCharacters = json.decode(response.body)['results'];
      setState(() {
        characters = fetchedCharacters;
      });
    } catch (e) {
      print('Error fetching characters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Personajes'),
      ),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          return ListTile(
            title: Text(character['name']),
            subtitle: Text('Género: ${character['gender']}, Especie: ${character['species']}'),
            onTap: () {
              Navigator.pushNamed(context, '/character', arguments: character);
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(character['image']),
            ),
          );
        },
      ),
    );
  }
}
