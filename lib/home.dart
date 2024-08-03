
import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';

Usuario usuario = Usuario.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>{ 
  Icon myicon = const Icon(Icons.person);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            usuario.nombre,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text(
                'Tu plan de estudio personalizado',
                style: TextStyle(fontSize: 18),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Puedes modificar tu plan de estudio en las configuraciones de usuario ',
                  style: TextStyle(fontSize: 16),
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
          )
        ),
        const Expanded(
          child: PlanEstudioController()
        ),
      ]
    );
  }
}


class PlanEstudioController extends StatelessWidget {
  const PlanEstudioController( {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Materia>?>(
        future: usuario.planEstudio(usuario.carrera[0]),
        builder: (BuildContext context, AsyncSnapshot<List<Materia>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return PlanEstudio(planEstudio: snapshot.data as List<Materia>);
          }
        },
      ),
    );
  }
}

class PlanEstudio extends StatelessWidget{
  const PlanEstudio({super.key, required this.planEstudio});
  final List<Materia> planEstudio;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: planEstudio.length,
      itemBuilder: (context, index) {
        final materia = planEstudio[index];
        return ListTile(
          title: Text(materia.nombre),
          subtitle: Text(materia.nombre),
        );
      },
    );
  }
}