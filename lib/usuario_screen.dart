import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';
Usuario usuario = Usuario.instance;

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen ({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextoExplicativo(),
        const ListadoCarreas(),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              onPressed: () => {},
              label: const Text('Añadir carrera'), // Usamos `label` en lugar de `child`
              icon: const Icon(Icons.add), // Puedes quitar esto si no quieres un icono
            ),
          ),
        )
      ],
    );
  }

  
}

class ListadoCarreas extends StatelessWidget {
  const ListadoCarreas({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: ListView.builder(
          itemCount: usuario.carreras.length,
          itemBuilder: (context, index) {
            final carrera = usuario.carreras[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Carrera: ${carrera.nombre}'),
                      const SizedBox(height: 8),
                      Text('Institución: ${carrera.institucion}'),
                      const SizedBox(height: 8),
                      Text('Facultad: ${carrera.facultad}'),
                      const SizedBox(height: 8),
                      Text('Horas totales: ${carrera.horasTotales}'),
                      const SizedBox(height: 8),
                      Text('Horas aprobadas: ${carrera.horasA}'),
                      const SizedBox(height: 8),
                      Text('porcentaje aprobado: ${((carrera.horasA/carrera.horasTotales)*100).toStringAsFixed(1)}%'),
                      const SizedBox(height: 8),
                      Text('Cantidad de materias aprobadas: ${carrera.materiasA.length}'),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: ()=> {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15.0),
                                ),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  child: Navigator(
                                    onGenerateRoute: (RouteSettings settings) {
                                      return MaterialPageRoute(
                                        builder: (BuildContext context) => DetallesScreen(carrera:  carrera),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          },
                          child: const Text('Personalizar')),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TextoExplicativo extends StatelessWidget {
  const TextoExplicativo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox (
        constraints: const BoxConstraints(maxWidth: 500),
        child:const  Text("El plan de estudio se genera teniendo en cuenta las materias correlativas y las horas disponibles que nos indicaste. Ten en cuenta que, aunque nos esforzamos por optimizar tu tiempo, el plan no considera los horarios específicos de cursada, por lo que algunas materias podrían superponerse")
      ),
    );
  }
}

class DetallesScreen extends StatelessWidget {
  const DetallesScreen({super.key, required this.carrera});
  final UserCarrera carrera;


  @override
  Widget build(BuildContext context) {
    return Column( 
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(carrera.nombre, textAlign: TextAlign.center),
        ),
        ListTile(
          title: Text('Elejir materias optativas'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            _navigateToScreen(context, Optativas(carrera: carrera));
          },
        ),
        ListTile(
          title: Text('Materias aprobadas'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            _navigateToScreen(context, Aprovadas(carrera: carrera,));
          },
        ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}


class Optativas extends StatefulWidget {
  Optativas({super.key, required this.carrera});
  final UserCarrera carrera;
  @override
  State<Optativas> createState()=> _Optativas();
}

class _Optativas extends State<Optativas>{
  List<Materia>materias = []; 
  List<int> idSeleccionadas = [];
  List<Materia> seleccionadas = [];
  int horasMini = 0;
  int horas = 0;
  
  @override
  void initState() {
    super.initState();
    seleccionadas = widget.carrera.materiasOp;
    idSeleccionadas = seleccionadas.map((materia)=>materia.id).toList();
    horasMini = widget.carrera.horasTotales - widget.carrera.horasObligatorias;
    horas = widget.carrera.materiasOp.fold(0, (previousValue, element) => previousValue + element.horas);
    materias = widget.carrera.materias.where((item)=> item.tipo == 'OP').toList();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elije Optativas'),
        actions: [
          TextButton(
            onPressed: ()=>{
              if (horas < horasMini) { // Aquí defines la condición
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Alerta"),
                      content: Text('La suma de la carga horaria del conjunto selecionado tiene que ser igual o mayor a: $horasMini'),
                      actions: [
                        TextButton(
                          child: const Text("Aceptar"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Cierra la alerta
                          },
                        ),
                      ],
                    );
                  },
                )
              }else{
                widget.carrera.saveOptativas(seleccionadas),
                Navigator.pop(context)
              },
            }, 
            child: Text('Guardar'))
        ],
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('cantidad de horas minima: ${widget.carrera.horasTotales - widget.carrera.horasObligatorias}'),
                  Text('Horas selecionadas $horas')
                ],
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:materias.length,
              itemBuilder: (context, index) {
                final materia = materias[index];
                return Container(
                  decoration: BoxDecoration(
                    border: idSeleccionadas.contains(materia.id) ? Border.all(color: Colors.blue, width: 1) : null,
                    borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    onTap: ()=> {
                      if(idSeleccionadas.contains(materia.id)){
                        idSeleccionadas.remove(materia.id),
                        seleccionadas.removeWhere((item)=> item.id == materia.id ),
                        setState(() {
                          horas -= materia.horas;
                        })
                        }else{
                          idSeleccionadas.add(materia.id),
                          seleccionadas.add(materia),
                          setState(() {
                            horas += materia.horas;
                          })
                        }
                    },
                    title: Text(materia.nombre),
                    subtitle: Text('cuatrimestre: ${materia.periodo == 100 ? "Anual" : materia.periodo} |  carga horaria: ${materia.horas}'),
                  ),
                );
              },
            )
          ],
        ),
      )
    );
  }
}

class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tercera Pantalla'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Volver'),
        ),
      ),
    );
  }
}

class Aprovadas extends StatefulWidget {
  const Aprovadas({super.key, required this.carrera});
  final UserCarrera carrera;

  @override 
  State<Aprovadas> createState()=> _Aprovadas();
}

class _Aprovadas extends State<Aprovadas>{ 
  List<Materia> materiasA = [];
  @override
  Widget build(BuildContext context) {
    List<Materia> materiasA = widget.carrera.materiasA;
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias aprovadas'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
              itemBuilder: (context, index) {
                final materia = materiasA[index];
                return ListTile(
                  isThreeLine: true,
                  title: Text(materia.nombre),
                  subtitle: Text('cuatrimestre: ${materia.periodo == 100 ? "Anual" : materia.periodo} |  carga horaria: ${materia.horas}'),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert), // Icono de tres puntos
                    onSelected: (String value) {
                      // Acciones al seleccionar una opción
                      switch (value) {
                        case 'remove':
                          widget.carrera.delA(materia);
                          setState(() {
                            materiasA.remove(materia);
                          });
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Quitar de aprovadas'),
                      )
                    ],
                  ),
                );
              },
              itemCount:materiasA.length,
            ),
    );
  }
}