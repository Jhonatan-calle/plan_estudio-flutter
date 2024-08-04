import 'package:flutter/material.dart';
import 'package:plan_estudio/usuario.dart';
Usuario usuario = Usuario.instance;

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen ({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Text(usuario.nombre),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: ()=>{},
              child: Text('Añadir carrera'))
          ],),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ConstrainedBox(
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
                          children: [
                            Text('Carrera: ${carrera.nombre}'),
                            const SizedBox(height: 8),
                            Text('Institución: ${carrera.institucion}'),
                            const SizedBox(height: 8),
                            Text('Cantidad de materias aprobadas: ${carrera.materiasA.length}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}