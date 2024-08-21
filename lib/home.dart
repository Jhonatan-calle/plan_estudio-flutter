
import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';

Usuario usuario = Usuario.instance;

class HomeScreen extends StatefulWidget {
  const   HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
  
}

class _HomeScreen extends State<HomeScreen>{ 
  UserCarrera dropdownValue = usuario.carreras.first;

  
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
            items: usuario.carreras.map<DropdownMenuItem<UserCarrera>>((UserCarrera carrera){
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
                        case 'info':
                          List<int> rCursarIds = materia.rCursar.map((item)=> item.id).toList();
                          List<int> rRendirIds = materia.rRendir.map((item)=> item.id).toList();
                          List<Materia> rCursar = usuario.carreras[0].materias.where((item)=> rCursarIds.contains(item.id)).toList();
                          List<Materia> rRendir = usuario.carreras[0].materias.where((item)=> rRendirIds.contains(item.id)).toList();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                content: Container(
                                  height: 200.0,
                                  width: double.maxFinite,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(materia.nombre),
                                        Text('Tipo: ${materia.tipo}'),
                                        SizedBox(height: 10),
                                        Text('Necesario para cursar:'),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: rCursar.length,
                                          itemBuilder: (context, index) {
                                            final item = rCursar[index];
                                            return ListTile(
                                              title: Text(item.nombre),
                                            );
                                          }
                                        ),
                                        SizedBox(height: 10),
                                        Text('Necesario para Rendir:',
                                          style: TextStyle(
                                          ),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: rRendir.length,
                                          itemBuilder: (context, index) {
                                            final item = rRendir[index];
                                            return ListTile(
                                              title: Text(item.nombre),
                                            );
                                          }
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                              );
                            },
                          );
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'aprovada',
                        child: Text('Marcar como aprovada'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'info',
                        child: Text('info '),
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