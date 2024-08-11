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
          itemCount: usuario.carrera.length,
          itemBuilder: (context, index) {
            final carrera = usuario.carrera[index];
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
          title: Text('Carga Horaria'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            _navigateToScreen(context, SecondScreen());
          },
        ),
        ListTile(
          title: Text('Materias optativas'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            _navigateToScreen(context, ThirdScreen());
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


class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back)),
            const Center(child: Text('segunda pantalla'),)
          ],
        )
      ],
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
        title: Text('Cuarta Pantalla'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                        case 'opcion2':
                          print('Opción 2 seleccionada para el elemento $index');
                          break;
                        case 'opcion3':
                          print('Opción 3 seleccionada para el elemento $index');
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