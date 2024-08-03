import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Usuario {
  final String nombre;
  final String dni;
  final List<UserCarrera> carrera;

  Usuario._(this.nombre, this.dni, this.carrera);

  //constructor privado
  static Usuario? _instance;

  //Crea un usuario en la base de datos y inicializa la instancia
  static Future<bool> crear(String nombre, String dni, String carreraNombre) async {
    try {
      DocumentSnapshot carrerasDoc = await FirebaseFirestore.instance
          .collection('carreras')
          .doc('opciones')
          .get();

      if (!carrerasDoc.exists) {
        throw Exception("crear: No se encontraron opciones de carreras.");
      }

      Map<String, dynamic> carrerasData = carrerasDoc.data() as Map<String, dynamic>;
      List<dynamic> carrerasList = carrerasData['carreras'] as List<dynamic>;

      // Buscar la carrera por nombre
      var carreraMap = carrerasList.firstWhere(
          (option) => option['nombre'] == carreraNombre,
          orElse: () => null);
      if (carreraMap == null) {
        throw Exception("crear: No se encontró una carrera con el nombre proporcionado.");
      }

      UserCarrera usuarioCarrera = UserCarrera.fromJson(carreraMap as Map<String, dynamic>);
      Usuario usuario = Usuario._(nombre, dni, [usuarioCarrera]);
      _instance = usuario;

      await FirebaseFirestore.instance.collection('Usuarios').doc(dni).set({
        'nombre': nombre,
        'carreras': [usuarioCarrera.toJson()]
      });

      // Cuando se haya creado con éxito
      return true;
    } catch (e) {
      // Manejo de errores
      print('crear: Error creando usuario: $e');
      return false;
    }
  }

  // se encarga de siempre devolver la misma instancia de usuario
  static Usuario get instance {
    if (_instance == null) {
      throw Exception("instance: El usuario no ha sido creado. Llama primero a 'crear'.");
    }
    return _instance!;
  }

  // Inicializa la instancia cuando el usuario ya existe (privada)
  static Future<void> _inicializarDesdeBD(String dni) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(dni)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String nombre = data['nombre'];
        List<dynamic> carrerasJson = data['carreras'] as List<dynamic>;
        List<UserCarrera> carreras = carrerasJson
            .map((carrera) =>
                UserCarrera.fromJson(carrera as Map<String, dynamic>))
            .toList();
        _instance = Usuario._(nombre, dni, carreras);
      } else {
        throw Exception("_inicializarDesdeBD: No se encontró un usuario con el DNI proporcionado.");
      }
    } catch (e) {
      print('_inicializarDesdeBD: Error buscando el usuario en la base de datos: $e');
    }
  }

  //informa si un usuario existe o no y en caso de existir
  //inicializa la instancia
  static Future<bool> exists(String dni) async {
    try {
      DocumentSnapshot docUser = await FirebaseFirestore.instance.collection('Usuarios').doc(dni).get();
      if (docUser.exists) {
        await _inicializarDesdeBD(dni);
      }
      return docUser.exists;
    } catch (e) {
      print('exists: Error verificando la existencia del usuario: $e');
      return false;
    }
  }

  //restablece la instancia usuario
  static void reset() {
    _instance = null;
  }

  //retorna plan de estudios de una carrera
  Future<List<Materia>> planEstudio(UserCarrera userCarrera) async {
    try {
      DocumentSnapshot doc = await userCarrera.ref.get();
      Map<String, dynamic> carreraJson = doc.data() as Map<String, dynamic>;
      List<Materia> materiasTotal = carreraJson['materias']
          .map<Materia>((materia) => Materia.fromJson(materia))
          .toList();
      List<int> materiasAprobadas = [];

      //por ahora solo con las materias obligatorias a manera de prueba
      List<Materia> materiasRestantes = materiasTotal.where((materia) {
        return !materiasAprobadas.contains(materia.id) && materia.tipo == 'OB';
      }).toList();

      List<Materia> plan = [];
      bool sePuedeCursar;
      List<Materia> mySet = [];

      while (materiasRestantes.isNotEmpty) {
        List<Materia> primerCuatrimestre = materiasRestantes.where((materia) => materia.periodo == 1).toList();

        for (Materia materia in primerCuatrimestre) {
          sePuedeCursar = materia.rCursar.every((condicion)=> materiasAprobadas.contains(condicion.id));
          if (sePuedeCursar) {
            mySet.add(materia);
            materiasRestantes.removeWhere((item)=>item.id == materia.id);
          }
        }
        materiasAprobadas.addAll(mySet.map((element)=>element.id).toList());
        plan.addAll(mySet);
        mySet.clear();

        List<Materia> sdoCuatrimestre = materiasRestantes.where((materia)=>materia.periodo == 2).toList();
        for (Materia materia in sdoCuatrimestre){
          sePuedeCursar = materia.rCursar.every((condicion)=> materiasAprobadas.contains(condicion.id));
          if (sePuedeCursar) {
            mySet.add(materia);
            materiasAprobadas.add(materia.id);
            materiasRestantes.removeWhere((item)=>item.id == materia.id);
          }
        }
        materiasAprobadas.addAll(mySet.map((element)=>element.id).toList());
        plan.addAll(mySet);
        mySet.clear();
      }
      return plan;
    } catch (e) {
      print('planEstudio: Error calculando el plan de estudio: $e');
      throw Exception("planEstudio: Ocurrió un error al calcular tu plan de estudio: $e");
    }
  }
}

class UserCarrera {
  final String nombre;
  final String facultad;
  final String institucion;
  final DocumentReference ref;
  final List<int> materiasA;

  UserCarrera(this.nombre, this.facultad, this.institucion, this.ref, this.materiasA);

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "facultad": facultad,
      "institucion": institucion,
      "ref": ref,
      "materiasA": materiasA
    };
  }

  factory UserCarrera.fromJson(Map<String, dynamic> carrera) {
    try {
      return UserCarrera(carrera['nombre'], carrera['facultad'],
          carrera['institucion'], carrera['ref'], List<int>.from(carrera['materiasA'] ?? []));
    } catch (e) {
      print('UserCarrera.fromJson: Error convirtiendo JSON a UserCarrera: $e');
      throw Exception('UserCarrera.fromJson: Ocurrió un error al convertir JSON a UserCarrera: $e');
    }
  }
}

class Materia {
  final int horas;
  final int id;
  final String nombre;
  final int periodo;
  final String tipo;
  final List<UserMateria> rCursar;
  final List<UserMateria> rRendir;
  final int year;

  Materia._(this.horas, this.id, this.nombre, this.periodo, this.rCursar,
      this.rRendir, this.tipo, this.year);

  factory Materia.fromJson(Map<String, dynamic> materia) {
    try {
      List<UserMateria> condicionesC = materia['rCursar']
          .map<UserMateria>((condicion) => UserMateria.fromJson(condicion))
          .toList();
      List<UserMateria> condicionesR = materia['rRendir']
          .map<UserMateria>((condicion) => UserMateria.fromJson(condicion))
          .toList();
      return Materia._(
          materia['horas'],
          materia['id'],
          materia['nombre'],
          materia['periodo'],
          condicionesC,
          condicionesR,
          materia['tipo'],
          materia['year']);
    } catch (e) {
      print('Materia.fromJson: Error convirtiendo JSON a Materia: $e');
      throw Exception('Materia.fromJson: Ocurrió un error al convertir JSON a Materia: $e');
    }
  }
}

class UserMateria {
  final int id;
  final String estado;

  UserMateria(this.id, this.estado);

  factory UserMateria.fromJson(Map<String, dynamic> materia) {
    try {
      return UserMateria(materia['id'], materia['estado']);
    } catch (e) {
      print('UserMateria.fromJson: Error convirtiendo JSON a UserMateria: $e');
      throw Exception('UserMateria.fromJson: Ocurrió un error al convertir JSON a UserMateria: $e');
    }
  }
}
