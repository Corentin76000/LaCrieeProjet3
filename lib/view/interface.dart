import 'package:flutter/material.dart';
import 'creerBacs.dart';
import 'afficherBacs.dart';
import 'modifierBacs.dart';
import 'supprimerBacs.dart';

class InterfacePage extends StatelessWidget {
  const InterfacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('La Criee'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Interface des fonctionnalités',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreerBacsPage(),
                  ),
                );
              },
              child: Text('Créer un bac de pêche du jour'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AfficherBacsPage(),
                  ),
                );
              },
              child: Text('Afficher les bacs de pêche du jour'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifierBacsPage(),
                  ),
                );
              },
              child: Text('Modifier les bacs de pêche du jour'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupprimerBacsPage(),
                  ),
                );
              },
              child: Text('Supprimer les bacs de pêche du jour'),
            ),
          ],
        ),
      ),
    );
  }
}
