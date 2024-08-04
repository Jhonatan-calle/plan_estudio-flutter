import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';
Usuario usuario = Usuario.instance;

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen ({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox (
            constraints: const BoxConstraints(maxWidth: 500),
            child:const  Text("El plan de estudio se genera teniendo en cuenta las materias correlativas y las horas disponibles que nos indicaste. Ten en cuenta que, aunque nos esforzamos por optimizar tu tiempo, el plan no considera los horarios específicos de cursada, por lo que algunas materias podrían superponerse")
          ),
        ),
        Expanded(
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
                      child: Hero(
                        tag: "carrera-info",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                onPressed: ()=>[], 
                                child: const Text('Personalizar')),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
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
