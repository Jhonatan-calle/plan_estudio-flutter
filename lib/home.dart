
import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';

Usuario usuario = Usuario.instance;

class HomeScreen extends StatefulWidget {
  const   HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>{ 
  Icon myicon = const Icon(Icons.person);
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              usuario.nombre,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
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
          ),
        ),
        PlanEstudioController()
      ],
    );
  }
}

class PlanEstudioController extends StatelessWidget {
  const PlanEstudioController( {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Materia>?>(
        future: usuario.planEstudio(usuario.carrera[0]),
        builder: (BuildContext context, AsyncSnapshot<List<Materia>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(10.0),
                child: CircularProgressIndicator(),
              )),
            );
          } else if (snapshot.hasError) {
            return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
          } else {
            return PlanEstudio(planEstudio: snapshot.data as List<Materia>);
          }
        },
      );
  }
}

class PlanEstudio extends StatelessWidget{
  const PlanEstudio({super.key, required this.planEstudio});
  final List<Materia> planEstudio;

  @override
  Widget build(BuildContext context) {
    return  SliverPadding(
      padding: EdgeInsets.all(8),
      sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final materia = planEstudio[index];
                return ListTile(
                  isThreeLine: true,
                  title: Text(materia.nombre),
                  subtitle: Text('cuatrimestre: ${materia.periodo == 100 ? 1 : materia.periodo} |  carga horaria: ${materia.horas}'),
                );
              },
              childCount: planEstudio.length,
            ),
          ),
    );
  }
}