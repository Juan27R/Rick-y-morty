import 'package:flutter/material.dart';
import 'package:rickandmortyapp/home/controllers/home-controller.dart';
import 'package:rickandmortyapp/home/controllers/video_screen.dart'; // Corregido: Importa la pantalla de video
import 'package:rickandmortyapp/home/models/character.dart';
import 'package:rickandmortyapp/home/screens/widgets/characters-card.dart';
import 'package:rickandmortyapp/utils/widgets/drawer.dart'; 

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final HomeController _homeController = HomeController();

  Future<void> _signOut() async {
    try {
      Navigator.of(context).pushReplacementNamed('/login');
      print('Sesión cerrada exitosamente.');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  void showCharacterDetails(BuildContext context, CharacterDTO character) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(character.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(character.image),
              SizedBox(height: 10),
              Text('Nombre: ${character.name}'),
              Text('Especie: ${character.species}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/rickandmorty.jpg', width: 100, height: 100),
            SizedBox(width: 10),
            Text(
              "Rick & Morty APP",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 0, 255, 106),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoScreen()), // Corregido: Navega a la pantalla de video
              );
            },
          ),
        ],
      ),
      drawer: DrawerApp(),
      body: FutureBuilder<List<CharacterDTO>>(
        future: _homeController.getCharacters(),
        builder: (context, AsyncSnapshot<List<CharacterDTO>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los personajes: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final character = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    showCharacterDetails(context, character);
                  },
                  child: CharacterCard(character: character),
                );
              },
            );
          } else {
            return Center(
              child: Text('No hay personajes disponibles'),
            );
          }
        },
      ),
    );
  }
}
