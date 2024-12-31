import 'package:flutter/material.dart';
import 'package:plan_estudio/main.dart';
import 'package:plan_estudio/screen/home.dart';
import 'package:plan_estudio/screen/sing_up.dart';
import 'package:plan_estudio/data/usuario.dart';
import 'package:plan_estudio/screen/usuario_screen.dart';

class Loggin extends StatelessWidget {
  const Loggin({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
              decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MyText(),
                  SizedBox(height: 60),
                  MyForm()
              ],),
            ),
        ),
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyForm();
}

class  _MyForm extends State<MyForm>{
  final TextEditingController _documentoController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ConstrainedBox (
      constraints: const BoxConstraints(maxWidth: 300),
      child:Form(
        key: _formkey,
        child: Column(
          children: [
            TextFormField(
              controller: _documentoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Número de documento',
                border: OutlineInputBorder()
              ),
              validator: (value){
                if (value == null || value.isEmpty ){
                  return 'Ingrese su documento';
                }else if ( value.length != 8){
                  return 'El valor debe de tener 8 dijitos';
                }else if (int.tryParse(value)==null){
                  return 'El valor debe de ser numerico';
                }
                return null;
              },
              onFieldSubmitted: (value){
                if (_formkey.currentState!.validate()){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLogic(documento :_documentoController.text)),
                );
              }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: (){
              if (_formkey.currentState!.validate()){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLogic(documento :_documentoController.text)),
                );
              }
            }, child: const Text('Iniciar'))
          ],
        ),
      )
    );
  }
}
  

class MyText extends StatelessWidget {
  const MyText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox (
      constraints: const BoxConstraints(maxWidth: 500),
      child:const  Text("En PlanEstudio, calcula tu plan de estudio hecho a medida."
      " Ingresa tus datos y recibe una ruta académica adaptada a tu disponibilidad y "
      "progreso actual. Ideal para quienes tienen trabajos o compromisos que dificultan "
      "seguir el plan de estudio tradicional, nuestra plataforma te permite avanzar en"
      " tu carrera de manera flexible y efectiva."));
  }
}


class UserLogic extends StatelessWidget {
  const UserLogic({super.key, required this.documento});
  final String documento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool?>(
        future: Usuario.exists(documento),
        builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            bool exists = snapshot.data ?? false; 
            if (!exists) {
              return SingUpScreen(documento: documento);
            } else {
              return ScreenController(); 
            }
          }
        },
      ),
    );
  }
}

class ScreenController extends StatefulWidget {
  const ScreenController({super.key});
  @override
  State<ScreenController> createState() => _ScreenController();
}

class _ScreenController extends State<ScreenController> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.accessibility_new),
            title: const Text('Tus estudios'),
            
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              HomeScreen(),
              UsuarioScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.home), text: 'Home'),
                  Tab(icon: Icon(Icons.person), text: 'Perfil'),
                ],
              ),
          ),
        ),
      ),
    );
  }
}