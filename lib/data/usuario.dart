import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_estudio/data/user_carrera.dart';

class Usuario {
  final String nombre;
  final String dni;
  final DocumentReference ref;
  final List<UserCarrera> carreras;
  static Usuario? _instance;

  Usuario._(this.nombre, this.dni, this.ref, this.carreras);

  // return the same instance
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

