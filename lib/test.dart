
import 'package:flutter/material.dart';
import 'package:plan_estudio/home.dart';
import 'package:plan_estudio/usuario.dart';

Usuario usuario = Usuario.instance;

class TestHomescreen extends StatefulWidget {
  const   TestHomescreen({super.key});

  @override
  State<TestHomescreen> createState() => _HomeScreen();
  
}

class _HomeScreen extends State<TestHomescreen>{ 
  UserCarrera carreraSelect = usuario.carrera.first;

  Future<void> _materiaAprovada(Materia materia, UserCarrera carrera) async{
    await carrera.addAprovada(materia);
    setState(() {
      carreraSelect = carrera;
    });
  }
  
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
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text(
                  'Tu plan de estudio personalizado',
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'Puedes modificar tu plan de estudio en las configuraciones de usuario ',
                    children: [
                      WidgetSpan(
                        child: Padding(
                          padding:EdgeInsets.symmetric(horizontal: 2.0),
                          child:Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<UserCarrera>(
            alignment: Alignment.topRight,
            value: carreraSelect,
            items: usuario.carrera.map<DropdownMenuItem<UserCarrera>>((UserCarrera carrera){
              return DropdownMenuItem<UserCarrera>(
                value: carrera,
                child:  Text(carrera.nombre)
                );
            }).toList(),  
            onChanged: (UserCarrera? carrera){
              setState(() {
                carreraSelect = carrera!;

              });
            },
            focusColor: Colors.transparent,
            ),
            
        ],
      ),
    );
  }


}

