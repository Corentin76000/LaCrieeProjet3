import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SupprimerBacsPage extends StatefulWidget {
  const SupprimerBacsPage({Key? key}) : super(key: key);

  @override
  _SupprimerBacsPageState createState() => _SupprimerBacsPageState();
}


class _SupprimerBacsPageState extends State {
  late String _selectedBacId;
  List<String> _bacIds = [];

  // Initialisation
  @override
  void initState() {
    super.initState();
    _getBacIds();
  }

  // Obtention des ids bac
  Future<void> _getBacIds() async {
    try {
      final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('bac').get();
      final List<String> ids =
      querySnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _bacIds = ids;
        _selectedBacId = ids.isNotEmpty ? ids.first : '';
      });
    } catch (error) {
      print('Problème lors de la récupération des IDs bac: $error');
    }
  }


  // Affichage global
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer les bacs de pêche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Sélectionnez le bac à supprimer :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedBacId,
              onChanged: (newValue) {
                setState(() {
                  _selectedBacId = newValue!;
                });
              },
              items: _bacIds.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Spacer(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _confirmDeleteDialog();
              },
              child: Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }


  // Message de confirmation
  void _confirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Êtes-vous sûr de la supression ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBac();
              },
            ),
            TextButton(
              child: Text("Non"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Suppression du bac
  Future<void> _deleteBac() async {
    try {
      await FirebaseFirestore.instance
          .collection('bac')
          .doc(_selectedBacId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bac supprimé avec succès!')),
      );
      await _getBacIds();
    } catch (error) {
      print('Erreur lors de la suppression du bac: $error');
    }
  }
}
