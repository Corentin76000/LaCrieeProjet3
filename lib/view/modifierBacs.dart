import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ModifierBacsPage extends StatefulWidget {
  const ModifierBacsPage({Key? key}) : super(key: key);

  @override
  _ModifierBacsPageState createState() => _ModifierBacsPageState();
}


class _ModifierBacsPageState extends State {
  List<String> _bacIds = [];
  late String _selectedBacId = '';

  List<String> _lotIds = [];
  late String _selectedLotId = '';

  List<String> _typeBacIds = [];
  late String _selectedTypeBacId = '';

  late String _champsIdBac = '';

  // Initialisation
  @override
  void initState() {
    super.initState();
    _getBacIds();
    _getLotIds();
    _getTypeBacIds();
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

  // Obtention des ids lot
  Future<void> _getLotIds() async {
    try {
      final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('lot').get();
      List<String> ids =
      querySnapshot.docs.map((doc) => doc.id).toList();
      ids.insert(0, '');
      setState(() {
        _lotIds = ids;
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
        ids.insert(0, ' ');
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
        title: Text('Modifier un bac de pêche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Sélectionnez le bac à modifier :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Dropdown pour la sélection du bac
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
            SizedBox(height: 64),
            Text(
              'Changer le lot :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Dropdown pour la sélection du lot
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
                  } else if (_selectedTypeBacId.isNotEmpty && snapshot.hasData) {
                    final typeBacData = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          'Sélectionnez le type (tare) : ${typeBacData['tare']}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // Dropdown pour la sélection du type de bac
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
                  else {
                    return Column(
                      children: [
                        Text(
                          'Sélectionnez le type (tare) :',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // Dropdown pour la sélection du type de bac
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
                }),
            SizedBox(height: 36),
            Text(
              'Modifiez le nom du bac :',
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
                _confirmModifierDialog();
              },
              child: Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }


  // Message de confirmation
  void _confirmModifierDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Êtes-vous sûr de la modification ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                Navigator.of(context).pop();
                _updateBac();
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


  // Modification du bac
  Future<void> _updateBac() async {
    try {
      final Map<String, dynamic>? lotData;
      if (_selectedLotId.isNotEmpty) {
        lotData = await _getLotData(_selectedLotId);
      } else {
        // Si _selectedLotId est vide, initialise lotData à null
        lotData = null;
      }

      final Map<String, dynamic> updateData = {};

      if (_champsIdBac.isNotEmpty) {
        updateData['idBac'] = _champsIdBac;
      }
      if (_selectedTypeBacId.isNotEmpty) {
        updateData['idTypeBac'] = _selectedTypeBacId;
      }
      if (lotData != null) {
        if (lotData['idBateau'] != null) {
          updateData['idBateau'] = lotData['idBateau'];
        }
        if (lotData['datePeche'] != null) {
          updateData['datePeche'] = lotData['datePeche'];
        }
      }
      if (_selectedLotId.isNotEmpty) {
        updateData['idLot'] = _selectedLotId;
      }

      if (_selectedBacId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('bac')
            .doc(_selectedBacId)
            .update(updateData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bac modifié avec succès !')),
        );
      }
    } catch (error) {
      print('Erreur lors de la modification du bac: $error');
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