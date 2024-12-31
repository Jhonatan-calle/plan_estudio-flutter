import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_estudio/data/carrera.dart';
import 'package:plan_estudio/data/materia.dart';
import 'package:plan_estudio/data/usuario.dart';

class UserCarrera extends Carrera {
  int horasA;
  List<Materia> materiasA;
  List<Materia> materiasOp;
  final DocumentReference ref;

  UserCarrera(
    super.nombre, 
    super.materias,
    super.facultad, 
    super.institucion, 
    super.horasTotales,
    super.horasObligatorias,
    super.cargaHPromedio,
    super.cargaHMinima,
    super.materiasRef, 
    this.horasA,
    this.materiasA,
    this.materiasOp,
    this.ref
  );

  Future<List<Materia>> planEstudio() async {
    try {
      List<int> materiasAprobadas = materiasA.map((materia)=> materia.id).toList();

      List<int> idMateriasOp = materiasOp.map((materia)=> materia.id).toList();
      //por ahora solo con las materias obligatorias a manera de prueba
      List<Materia> materiasRestantes = materias.where((materia) {
        return (!materiasAprobadas.contains(materia.id) && (idMateriasOp.contains(materia.id) || materia.tipo == 'OB'));}).toList();
        
      bool sePuedeCursar;
      List<Materia> mySet = [];
      List<Materia> plan = [];

      DateTime now = DateTime.now();
      int month = now.month;

      if (month <= 6) {
        while (materiasRestantes.isNotEmpty) {
          List<Materia> primerCuatrimestre = materiasRestantes.where((materia) => materia.periodo == 1 || materia.periodo == 100).toList();

          for (Materia materia in primerCuatrimestre) {
            sePuedeCursar = materia.rCursar.every((condicion)=> materiasAprobadas.contains(condicion.id));
            if (sePuedeCursar) {
              mySet.add(materia);
              materiasRestantes.removeWhere((item)=>item.id == materia.id);
            }
          }
          materiasAprobadas.addAll(mySet
              .where((element) => element.periodo != 100)
              .map((element) => element.id)
              .toList(),
          );

          plan.addAll(mySet);
          mySet.clear();

          List<Materia> sdoCuatrimestre = materiasRestantes.where((materia)=>materia.periodo == 2).toList();
          for (Materia materia in sdoCuatrimestre){
            sePuedeCursar = materia.rCursar.every((condicion)=> materiasAprobadas.contains(condicion.id));
            if (sePuedeCursar) {
              mySet.add(materia);
              materiasRestantes.removeWhere((item)=>item.id == materia.id);
            }
          }
          materiasAprobadas.addAll(mySet.map((element)=>element.id).toList());
          plan.addAll(mySet);
          mySet.clear();

          for (Materia materia  in plan ){
            if (materia.periodo == 100){
              materiasAprobadas.add(materia.id);
            }
          }
        }
      } else {
        while (materiasRestantes.isNotEmpty) {
        

          List<Materia> sdoCuatrimestre = materiasRestantes.where((materia)=>materia.periodo == 2).toList();
          for (Materia materia in sdoCuatrimestre){
            sePuedeCursar = materia.rCursar.every((condicion)=> materiasAprobadas.contains(condicion.id));
            if (sePuedeCursar) {
              mySet.add(materia);
              materiasRestantes.removeWhere((item)=>item.id == materia.id);
            }
          }
          materiasAprobadas.addAll(mySet.map((element)=>element.id).toList());
          plan.addAll(mySet);
          mySet.clear();


          List<Materia> primerCuatrimestre = materiasRestantes.where((materia) => materia.periodo == 1 || materia.periodo == 100).toList();

          for (Materia materia in primerCuatrimestre) {
            sePuedeCursar = materia.rCursar.every((condicion)=> materiasAprobadas.contains(condicion.id));
            if (sePuedeCursar) {
              mySet.add(materia);
              materiasRestantes.removeWhere((item)=>item.id == materia.id);
            }
          }
          materiasAprobadas.addAll(mySet
              .where((element) => element.periodo != 100)
              .map((element) => element.id)
              .toList(),
          );

          plan.addAll(mySet);
          mySet.clear();


          for (Materia materia  in plan ){
            if (materia.periodo == 100){
              materiasAprobadas.add(materia.id);
            }
          }
        }
      }
      
      
      return plan;
    } catch (e) {
      print('planEstudio: Error calculando el plan de estudio: $e');
      throw 'No hay conexión a Internet. Por favor, verifica tu conexión.';
    }
  }

  Future<void> addAprovada(Materia materia) async{
    try {
      
      horasA += materia.horas;
      materiasA.add(materia);
      List<Map<String,dynamic>> materiasMap = materiasA.map((element)=> element.toJson()).toList();
      await ref.update({
        'horasA':horasA,
        'materiasA': materiasMap
        });
      
    } catch (e) {
      print('ocurrio un problema añadiendo la materia a aprovadas $e');
      throw('ocurrio un problema añadiendo la materia a aprovadas');
    }
  }

  Future<void> delA(Materia materia) async{
    try {
      horasA -= materia.horas; 
      materiasA.remove(materia);
      List<Map<String,dynamic>> materiasMap = materiasA.map((element)=> element.toJson()).toList();
      await ref.update({
        'horasA':horasA,
        'materiasA': materiasMap
        });
      
    } catch (e) {
      print('ocurrio un problema eliminando la materia de aprovadas $e');
      throw('ocurrio un problema eliminando la materia de aprovadas');
    }
  }

  Future<void> saveOptativas(List<Materia> optativas)async{
    try {
      List<Map<String,dynamic>> optativasJson = optativas.map((element)=> element.toJson()).toList();
      materiasOp = optativas;
      await ref.update({
        'materiasOp':optativasJson
      });
    } catch (e) {
      print('ocurrio un problema manejando las materias optativas $e');
      throw('ocurrio un problema manejando las materias optativas ');
    }
  }
  
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      "horasA": horasA,
      "materiasA": materiasA,
      "materiasOP": materiasOp
    });
    return json;
  }

  factory UserCarrera.fromJson(Map<String, dynamic> carrera){
    try {
      return UserCarrera(
        carrera['nombre'], 
        carrera['materias']
          .map<Materia>((materia) => Materia.fromJson(materia))
          .toList(),
        carrera['facultad'],
        carrera['institucion'],
        carrera['horasTotales'],
        carrera['horasObligatorias'],
        carrera['cargaHPromedio'],
        carrera['cargaHMinima'],
        carrera['materiasRef'], 
        carrera['horasA'] ?? 0,
        (carrera['materiasA'] ?? [])
        .map<Materia>((materia) => Materia.fromJson(materia))
          .toList(),
        (carrera['materiasOp'] ?? [])
          .map<Materia>((materiaOp) =>  Materia.fromJson(materiaOp))
          .toList(),
        carrera['ref']
      );
    } catch (e) {
      print('UserCarrera.fromJson: Error convirtiendo JSON a UserCarrera: $e');
      throw Exception('UserCarrera.fromJson: Ocurrió un error al convertir JSON a UserCarrera: $e');
    }
  }

}
