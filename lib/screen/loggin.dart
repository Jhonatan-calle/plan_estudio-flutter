import 'package:flutter/material.dart';
import 'package:plan_estudio/screen/home.dart';
import 'package:plan_estudio/screen/sing_up.dart';
import 'package:plan_estudio/data/usuario.dart';
import 'package:plan_estudio/screen/usuario_screen.dart';
import 'package:plan_estudio/utils/info.dart';

class Loggin extends StatefulWidget {
  const Loggin({super.key});

  @override
  State<Loggin> createState() => _Loggin();
}

class _Loggin extends State<Loggin>{ 
  late TextEditingController _documentoController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _documentoController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Card(
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox (
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Text(descripcion,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    )),
                  const SizedBox(height: 60),
                  ConstrainedBox (
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
                  )
              ],),
            ),
          ),
        ),
    );
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
              return SingUp(documento: documento);
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