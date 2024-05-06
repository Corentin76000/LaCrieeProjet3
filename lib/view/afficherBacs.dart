import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AfficherBacsPage extends StatefulWidget {
  const AfficherBacsPage({Key? key}) : super(key: key);

  @override
  _AfficherBacsPageState createState() => _AfficherBacsPageState();
}


class _AfficherBacsPageState extends State
{
  List<String> _bacIds = [];
  late String _selectedBacId = '';

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
      print('Erreur lors de la récupération des IDs bac: $error');
    }
  }


// Affichage global
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afficher les bacs de pêche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez le bac à afficher :',
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
            SizedBox(height: 20),
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('bac')
                  .doc(_selectedBacId)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Aucun bac de pêche trouvé'));
                } else {
                  final bacData = snapshot.data!;
                  return FutureBuilder(
                    future: _getBateauData(bacData['idBateau']),
                    builder: (context, AsyncSnapshot<Map<String, dynamic>?> bateauSnapshot) {
                      if (bateauSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        final bateauData = bateauSnapshot.data!;
                        return FutureBuilder(
                          future: _getTypeBacData(bacData['idTypeBac']),
                          builder: (context, AsyncSnapshot<Map<String, dynamic>?> typeBacSnapshot) {
                            if (typeBacSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              final typeBacData = typeBacSnapshot.data!;
                              return DataTable(
                                columnSpacing: 30,
                                columns: [
                                  DataColumn(label: Text('Bateau')),
                                  DataColumn(label: Text('Date pêche')),
                                  DataColumn(label: Text('N°lot')),
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Type (tare)')),
                                ],
                                rows: [
                                  DataRow(cells: [
                                    DataCell(Text(bateauData['nom'].toString())),
                                    DataCell(Text(bacData['datePeche'].toString())),
                                    DataCell(Text(bacData['idLot'].toString())),
                                    DataCell(Text(bacData['idBac'].toString())),
                                    DataCell(Text(typeBacData['tare'].toString())),
                                  ]),
                                ],
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Récupération des données du bateau
  Future<Map<String, dynamic>?> _getBateauData(String bateauId) async {
    final DocumentSnapshot bateauSnapshot = await FirebaseFirestore.instance
        .collection('bateau')
        .doc(bateauId)
        .get();

    if (bateauSnapshot.exists) {
      return bateauSnapshot.data() as Map<String, dynamic>;
    } else {
      return null;
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
}