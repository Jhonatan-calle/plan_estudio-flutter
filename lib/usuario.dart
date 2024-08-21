import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String nombre;
  final String dni;
  final DocumentReference ref;
  final List<UserCarrera> carreras;
  static Usuario? _instance;

  Usuario._(this.nombre, this.dni, this.ref, this.carreras);

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
      QuerySnapshot carrerasDocs = await FirebaseFirestore.instance.collection('Carreras').get();
      List<DocumentSnapshot> carrerasSnapshots = carrerasDocs.docs;
      List<Map<String,dynamic>> carrerasList = [];
      for(var snapshots in carrerasSnapshots){
        if (snapshots.exists){
          carrerasList.add(snapshots.data()as Map<String,dynamic>);
        }
      }

      // Buscar la carrera por nombre
      final Map<String,dynamic> carreraMap = carrerasList.firstWhere((option) => option['nombre'] == carreraNombre);
      DocumentReference ref = FirebaseFirestore.instance.collection('Usuarios').doc(dni);
      //crea el usuario y establece campo nombre
      await ref.set({'nombre': nombre});
      DocumentReference idCarrera = await ref.collection('Carreras').add(carreraMap);
      carreraMap['ref'] = idCarrera;

      DocumentReference materiasRef = carreraMap['materiasRef'];
      DocumentSnapshot doc = await materiasRef.get();
      Map<String, dynamic> materiasMap = doc.data() as Map<String, dynamic>;
      carreraMap['materias'] = materiasMap['materias'];
      
      UserCarrera usuarioCarrera = UserCarrera.fromJson(carreraMap as Map<String, dynamic>); 
      Usuario usuario = Usuario._(nombre, dni, ref, [usuarioCarrera]);
      _instance = usuario;

      // Cuando se haya creado con éxito
      return true;
    } catch (e) {
      // Manejo de errores
      print('crear: Error creando usuario: $e');
      return false;
    }
  }

  //informa si el usuario existe y en caso afirmativo inicializa la instancia
  static Future<bool> exists(String dni) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance.collection('Usuarios').doc(dni);
      DocumentSnapshot docUser = await ref.get();
      if (docUser.exists) {
        Map<String, dynamic> data = docUser.data() as Map<String, dynamic>;
        String nombre = data['nombre'];
        QuerySnapshot querySnapshot = await ref.collection('Carreras').get();
        List<QueryDocumentSnapshot> carrerasSnapshot = querySnapshot.docs;
        List<UserCarrera> carreras = [];
        for (QueryDocumentSnapshot snapshot in carrerasSnapshot){
          if(snapshot.exists){
            Map<String,dynamic> carreraMap = snapshot.data() as Map<String, dynamic>;
            carreraMap['ref'] = snapshot.reference;
            DocumentReference materiasRef = carreraMap['materiasRef'];
            DocumentSnapshot doc = await materiasRef.get();
            Map<String, dynamic> materiasMap = doc.data() as Map<String, dynamic>;
            carreraMap['materias'] = materiasMap['materias'];
            carreras.add(UserCarrera.fromJson(carreraMap));
          }
        }
        _instance = Usuario._(nombre, dni, ref, carreras);
      }
      return docUser.exists;
    } catch (e) {
      throw 'No hay conexión a Internet. Por favor, verifica tu conexión.';
    }
  }

}

class UserCarrera extends Carrera {
  final int horasA;
  final List<Materia> materiasA;
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
      DocumentSnapshot doc = await ref.get();
      Map<String, dynamic> carreraMap = doc.data() as Map<String, dynamic>;
      List<Materia> materiasACarrera = (carreraMap['materiasA'] ?? [])
        .map<Materia>((materia) => Materia.fromJson(materia))
          .toList();
      materiasACarrera.add(materia);
      List<Map<String,dynamic>> materiasMap = materiasACarrera.map((element)=> element.toJson()).toList();
      await ref.update({'materiasA': materiasMap});
      materiasA.add(materia);
    } catch (e) {
      print('ocurrio un problema añadiendo la materia a aprovadas $e');
      throw('ocurrio un problema añadiendo la materia a aprovadas');
    }
  }

  Future<void> delA(Materia materia) async{
    try {
      DocumentSnapshot doc = await ref.get();
      Map<String, dynamic> carreraMap = doc.data() as Map<String, dynamic>;
      List<Materia> materiasACarrera = (carreraMap['materiasA'] ?? [])
        .map<Materia>((materia) => Materia.fromJson(materia))
          .toList();
      materiasACarrera.remove(materia);
      List<Map<String,dynamic>> materiasMap = materiasACarrera.map((element)=> element.toJson()).toList();
      await ref.update({'materiasA': materiasMap});
      materiasA.remove(materia);
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
  final List<MateriaRequisito> rCursar;
  final List<MateriaRequisito> rRendir;
  final int year;

  Materia._(this.horas, this.id, this.nombre, this.periodo, this.rCursar,
      this.rRendir, this.tipo, this.year);

  Map<String,dynamic> toJson(){
    return {
      'nombre': nombre,
      'horas': horas,
      'id': id,
      'periodo': periodo,
      'tipo': tipo,
      'rCursar': rCursar.map((e)=> e.toJson()).toList(),
      'rRendir': rRendir.map((e)=> e.toJson()).toList(),
      'year': year
    };
  }

  factory Materia.fromJson(Map<String, dynamic> materia) {
    try {
      List<MateriaRequisito> condicionesC = materia['rCursar']
          .map<MateriaRequisito>((condicion) => MateriaRequisito.fromJson(condicion))
          .toList();
      List<MateriaRequisito> condicionesR = materia['rRendir']
          .map<MateriaRequisito>((condicion) => MateriaRequisito.fromJson(condicion))
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

class MateriaRequisito {
  final int id;
  final String estado;

  MateriaRequisito(this.id, this.estado);

  factory MateriaRequisito.fromJson(Map<String, dynamic> materia) {
    try {
      return MateriaRequisito(materia['id'], materia['estado']);
    } catch (e) {
      print('MateriaRequisito.fromJson: Error convirtiendo JSON a MateriaRequisito: $e');
      throw Exception('MateriaRequisito.fromJson: Ocurrió un error al convertir JSON a MateriaRequisito: $e');
    }
  }

  Map<String,dynamic> toJson(){
    return{
      'id':id,
      'estado':estado
    };
  }
}
