import 'package:flutter/material.dart';

class CharacterDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dynamic character = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(character['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(character['image']),
            SizedBox(height: 30),
            Text('Género: ${character['gender']}'),
            Text('Especie: ${character['species']}'),
          ],
        ),
      ),
    );
  }
}
