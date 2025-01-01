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
