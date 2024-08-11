
import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';

Usuario usuario = Usuario.instance;

class HomeScreen extends StatefulWidget {
  const   HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
  
}

class _HomeScreen extends State<HomeScreen>{ 
  UserCarrera dropdownValue = usuario.carrera.first;

  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView (
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              usuario.nombre,
              textAlign: TextAlign.center,
              ),
            ),
          _textoExpliativo(),
          const SizedBox(height: 8),
          DropdownButton<UserCarrera>(
            alignment: Alignment.topRight,
            value: dropdownValue,
            items: usuario.carrera.map<DropdownMenuItem<UserCarrera>>((UserCarrera carrera){
              return DropdownMenuItem<UserCarrera>(
                value: carrera,
                child:  Text(carrera.nombre)
                );
            }).toList(),  
            onChanged: (UserCarrera? carrera){
              setState(() {
                dropdownValue = carrera!;
      
              });
            },
            focusColor: Colors.transparent,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    // Acción para refrescar la página
                    setState(() {
                      dropdownValue = dropdownValue;
                    });
                  },
                ),
              ),
            ),
      
            PlanEstudioController(
              carrera:  dropdownValue,
            )
        ],
      ),
    );
  }

  Container _textoExpliativo() {
    Icon myicon = const Icon(Icons.person);
    return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text(
                  'Tu plan de estudio personalizado',
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Puedes modificar tu plan de estudio en las configuraciones de usuario ',
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: myicon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class PlanEstudioController extends StatelessWidget {
  const PlanEstudioController( {super.key, required this.carrera});
  final UserCarrera carrera;

  void _myAprovada(Materia materia){
    carrera.addAprovada(materia);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Materia>?>(
        future: carrera.planEstudio(),
        builder: (BuildContext context, AsyncSnapshot<List<Materia>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            ));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Vuelve a llamar al FutureBuilder para reintentar
                         Navigator.pop(context);
                      },
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return PlanEstudio(
              materias: snapshot.data as List<Materia>,
              aprovada: _myAprovada
              );
          }
        },
      );
  }
}

class PlanEstudio extends StatefulWidget{
  const PlanEstudio({super.key, required this.materias, this.aprovada,});
  final List<Materia> materias;
  final aprovada;

  @override 
  State<PlanEstudio> createState() => _PlanEstudio();

}

class _PlanEstudio extends State<PlanEstudio>{


  @override
  Widget build(BuildContext context) {
    List<Materia> planEstudio = widget.materias;
    return Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final materia = planEstudio[index];
                return ListTile(
                  isThreeLine: true,
                  tileColor: materia.periodo == 1 || materia.periodo == 100 ? Colors.green[100] : Colors.red[100],
                  title: Text(materia.nombre),
                  subtitle: Text('cuatrimestre: ${materia.periodo == 100 ? "Anual" : materia.periodo} |  carga horaria: ${materia.horas} |  año: ${materia.year}'),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert), // Icono de tres puntos
                    onSelected: (String value) {
                      // Acciones al seleccionar una opción
                      switch (value) {
                        case 'aprovada':
                          widget.aprovada(materia);
                          setState(() {
                            planEstudio.remove(materia);
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
                        value: 'aprovada',
                        child: Text('Marcar como aprovada'),
                      )
                    ],
                  ),
                );
              },
              itemCount:planEstudio.length,
            ),
          ),
      );
  }
}