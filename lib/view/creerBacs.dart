import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CreerBacsPage extends StatefulWidget {
  const CreerBacsPage({Key? key}) : super(key: key);

  @override
  _CreerBacsPageState createState() => _CreerBacsPageState();
}


class _CreerBacsPageState extends State
{
  List<String> _lotIds = [];
  late String _selectedLotId = '';

  List<String> _typeBacIds = [];
  late String _selectedTypeBacId = '';

  late String _champsIdBac = '';

  // Initialisation
  @override
  void initState() {
    super.initState();
    _getLotIds();
    _getTypeBacIds();
  }


  // Obtention des ids lot
  Future<void> _getLotIds() async {
    try {
      final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('lot').get();
      final List<String> ids =
      querySnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _lotIds = ids;
        _selectedLotId = ids.isNotEmpty ? ids.first : '';
      });
    } catch (error) {
      print('Erreur lors de la récupération des IDs lot: $error');
    }
  }

// Obtention des ids typebac
  Future<void> _getTypeBacIds() async {
    try {
      final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('typebac').get();
      final List<String> ids =
      querySnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _typeBacIds = ids;
        _selectedTypeBacId = ids.isNotEmpty ? ids.first : '';
      });
    } catch (error) {
      print('Erreur lors de la récupération des IDs typebac: $error');
    }
  }


  // Affichage global
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un nouveau bac de pêche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Sélectionnez le lot pour le bac :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedLotId,
              onChanged: (newValue) {
                setState(() {
                  _selectedLotId = newValue!;
                });
              },
              items: _lotIds.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 36),
            FutureBuilder<Map<String, dynamic>?>(
              future: _getTypeBacData(_selectedTypeBacId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('Aucune donnée disponible');
                } else {
                  final typeBacData = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        'Sélectionnez le type (tare) : ${typeBacData['tare']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: _selectedTypeBacId,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTypeBacId = newValue!;
                          });
                        },
                        items: _typeBacIds.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 36),
            Text(
              'Choisissez le nom du bac :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nom du bac',
              ),
              onChanged: (value) {
                setState(() {
                  _champsIdBac = value;
                });
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_champsIdBac.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('/!\\ Veuillez remplir le nom du bac')),
                  );
                } else {
                  _confirmCreerDialog();
                }
              },
              child: Text('Créer le bac'),
            ),
          ],
        ),
      ),
    );
  }


  // Message de confirmation
  void _confirmCreerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Êtes-vous sûr de la création ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                Navigator.of(context).pop();
                _creerBac();
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


  // Création du bac
  Future<void> _creerBac() async {
    try {
      final Map<String, dynamic>? lotData = await _getLotData(_selectedLotId);
      if (lotData == null) {
        return;
      }

      await FirebaseFirestore.instance.collection('bac').add({
        'idBateau': lotData['idBateau'],
        'datePeche': lotData['datePeche'],
        'idLot': _selectedLotId,
        'idTypeBac': _selectedTypeBacId,
        'idBac': _champsIdBac,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bac créé avec succès !')),
      );
      _getTypeBacIds();
    } catch (error) {
      print('Erreur lors de la création du bac: $error');
    }
  }


  // Récupération des données du type bac
  Future<Map<String, dynamic>?> _getTypeBacData(String typeBacId) async {
    final DocumentSnapshot typeBacSnapshot = await FirebaseFirestore.instance
        .collection('typebac')
        .doc(typeBacId)
        .get();

    if (typeBacSnapshot.exists) {
      return typeBacSnapshot.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  // Récupération des données du lot
  Future<Map<String, dynamic>?> _getLotData(String lotId) async {
    final DocumentSnapshot lotSnapshot = await FirebaseFirestore.instance
        .collection('lot')
        .doc(lotId)
        .get();

    if (lotSnapshot.exists) {
      return lotSnapshot.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }
}
