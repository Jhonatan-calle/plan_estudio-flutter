import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String nombre;
  final String dni;
  final List<UserCarrera> carrera;
  static Usuario? _instance;

  Usuario._(this.nombre, this.dni, this.carrera);

  // se encarga de siempre devolver la misma instancia de usuario
  static Usuario get instance {
    if (_instance == null) {
      throw Exception("instance: El usuario no ha sido creado. Llama primero a 'crear'.");
    }
    return _instance!;
  }

  //Crea un usuario en la base de datos y inicializa la instancia
  static Future<bool> crear(String nombre, String dni, String carreraNombre) async {
    try {
      DocumentSnapshot carrerasDoc = await FirebaseFirestore.instance
          .collection('carreras')
          .doc('opciones')
          .get();

      Map<String, dynamic> carrerasData = carrerasDoc.data() as Map<String, dynamic>;
      List<dynamic> carrerasList = carrerasData['carreras'] as List<dynamic>;

      // Buscar la carrera por nombre
      var carreraMap = carrerasList.firstWhere((option) => option['nombre'] == carreraNombre);

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

  //informa si un usuario existe o no y en caso de existir
  //inicializa la instancia
  static Future<bool> exists(String dni) async {
    try {
      DocumentSnapshot docUser = await FirebaseFirestore.instance.collection('Usuarios').doc(dni).get();
      if (docUser.exists) {
        Map<String, dynamic> data = docUser.data() as Map<String, dynamic>;
        String nombre = data['nombre'];
        List<dynamic> carrerasJson = data['carreras'] as List<dynamic>;
        List<UserCarrera> carreras = carrerasJson
            .map((carrera) =>
                UserCarrera.fromJson(carrera as Map<String, dynamic>))
            .toList();
        _instance = Usuario._(nombre, dni, carreras);
      }
      return docUser.exists;
    } catch (e) {
      throw 'No hay conexión a Internet. Por favor, verifica tu conexión.';
      
    }
  }

  //retorna plan de estudios de una carrera
  Future<List<Materia>> planEstudio(UserCarrera userCarrera) async {
    print(userCarrera.materiasA);
    try {
      DocumentSnapshot doc = await userCarrera.ref.get();
      Map<String, dynamic> carreraJson = doc.data() as Map<String, dynamic>;
      List<Materia> materiasTotal = carreraJson['materias']
          .map<Materia>((materia) => Materia.fromJson(materia))
          .toList();
      List<int> materiasAprobadas = List.from(userCarrera.materiasA);

      //por ahora solo con las materias obligatorias a manera de prueba
      List<Materia> materiasRestantes = materiasTotal.where((materia) {
        return materia.tipo == 'OB' && !materiasAprobadas.contains(materia.id);}).toList();

      List<Materia> plan = [];
      bool sePuedeCursar;
      List<Materia> mySet = [];

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
      return plan;
    } catch (e) {
      print('planEstudio: Error calculando el plan de estudio: $e');
      throw 'No hay conexión a Internet. Por favor, verifica tu conexión.';
    }
  }
}

class UserCarrera extends Carrera {
  final int horasA;
  final List<int> materiasA;

  UserCarrera(
    String nombre, 
    String facultad, 
    String institucion, 
    int horasTotales,
    int cargaHPromedio,
    int cargaHMinima,
    this.horasA,
    DocumentReference ref, 
    this.materiasA
  ) : super(nombre, facultad, institucion, horasTotales, cargaHPromedio, cargaHMinima, ref);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      "horasA": horasA,
      "materiasA": materiasA,
    });
    return json;
  }

  factory UserCarrera.fromJson(Map<String, dynamic> carrera) {
    try {
      return UserCarrera(
        carrera['nombre'], 
        carrera['facultad'],
        carrera['institucion'],
        carrera['horasTotales'],
        carrera['cargaHPromedio'],
        carrera['cargaHMinima'],
        carrera['horasA'] ?? 0,
        carrera['ref'], 
        List<int>.from(carrera['materiasA'] ?? [])
      );
    } catch (e) {
      print('UserCarrera.fromJson: Error convirtiendo JSON a UserCarrera: $e');
      throw Exception('UserCarrera.fromJson: Ocurrió un error al convertir JSON a UserCarrera: $e');
    }
  }
}

class Carrera {
  final String nombre;
  final String facultad;
  final String institucion;
  final int horasTotales;
  final int cargaHPromedio;
  final int cargaHMinima;
  final DocumentReference ref;

  Carrera(
    this.nombre, 
    this.facultad, 
    this.institucion, 
    this.horasTotales,
    this.cargaHPromedio,
    this.cargaHMinima,
    this.ref
  );

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "facultad": facultad,
      "institucion": institucion,
      "horasTotales": horasTotales,
      "cargaHPromedio": cargaHPromedio,
      "cargaHMinima": cargaHMinima,
      "ref": ref,
    };
  }

  factory Carrera.fromJson(Map<String, dynamic> carrera) {
    try {
      return Carrera(
        carrera['nombre'], 
        carrera['facultad'],
        carrera['institucion'],
        carrera['horasTotales'],
        carrera['cargaHPromedio'],
        carrera['cargaHMinima'],
        carrera['ref']
      );
    } catch (e) {
      print('Carrera.fromJson: Error convirtiendo JSON a Carrera: $e');
      throw Exception('Carrera.fromJson: Ocurrió un error al convertir JSON a Carrera: $e');
    }
  }

  static Future<Iterable<String>> opciones(String query) async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance.collection('carreras').doc('opciones').get();
      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        List<String> carreras = List<String>.from(data['carreras'].map((carrera) => carrera['nombre'] as String));

        if (query == '') {
          carreras.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          return carreras;
        } else {
          return carreras.where((String option) => option.toLowerCase().contains(query.toLowerCase()));
        }
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
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
