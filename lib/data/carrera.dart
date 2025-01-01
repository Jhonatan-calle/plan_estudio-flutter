import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_estudio/data/materia.dart';

class Carrera {
  final String nombre;
  final List<Materia> materias;
  final String facultad;
  final String institucion;
  final int horasTotales;
  final int horasObligatorias;
  final int cargaHPromedio;
  final int cargaHMinima;
  final DocumentReference materiasRef;

  Carrera(
    this.nombre,
    this.materias,
    this.facultad, 
    this.institucion, 
    this.horasTotales,
    this.horasObligatorias,
    this.cargaHPromedio,
    this.cargaHMinima,
    this.materiasRef
  );

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "facultad": facultad,
      "institucion": institucion,
      "horasTotales": horasTotales,
      "horasObligatorias": horasObligatorias,
      "cargaHPromedio": cargaHPromedio,
      "cargaHMinima": cargaHMinima,
      "materiasRef": materiasRef,
    };
  }


  static Future<Iterable<String>> opciones(String query) async {
    try {
        QuerySnapshot carrerasDocs = await FirebaseFirestore.instance.collection('Carreras').get();
        List<DocumentSnapshot> carrerasSnapshots = carrerasDocs.docs;
        List<Map<String,dynamic>> carrerasList = [];
        for(var snapshots in carrerasSnapshots){
          if (snapshots.exists){
            carrerasList.add(snapshots.data()as Map<String,dynamic>);
          }
        }
        List<String> carreras = carrerasList.map((carrera)=> carrera["nombre"] as String).toList();

        if (query == '') {
          carreras.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          return carreras;
        } else {
          return carreras.where((String option) => option.toLowerCase().contains(query.toLowerCase()));
        }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }


}
