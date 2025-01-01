
import 'package:flutter/material.dart';
import 'package:plan_estudio/data/carrera.dart';
import 'package:plan_estudio/data/usuario.dart';
import 'package:plan_estudio/screen/loggin.dart';

class SingUp extends StatelessWidget{
  const SingUp({super.key, required this.documento});
  final String documento;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          child:Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const MyText(),
              const SizedBox(height: 40),
              SingUpForm(documeno: documento,)
            ],
          ),
        ),
          
      )
    );
  }
}

class MyText extends StatelessWidget{
  const MyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Crea tu Usuario"),
        const SizedBox(height: 30),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const Text("Crea un usuario para guardar tu informacion y asi modificar y cosultar tus datos cuantas veces quieras de manera mas sencilla",textAlign: TextAlign.center,))
      ],
    );
  }
}

class SingUpForm extends StatefulWidget{
  const SingUpForm({super.key, required this.documeno});
  
  final String documeno;
  @override
  State<StatefulWidget> createState() => _SingUpForm();
}

class _SingUpForm extends State<SingUpForm>{

  final GlobalKey<FormState> _formkey = GlobalKey();
  final TextEditingController _nombreUsuario = TextEditingController();
  final TextEditingController _documento2 = TextEditingController();
  late TextEditingController _documento;
  String? _selectedOption;
  late Iterable<String> _lastOptions = <String>[];
  String _carrera = '';

  @override
  void initState() {
    super.initState();
    _documento = TextEditingController(text: widget.documeno);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            TextFormField(
              controller: _nombreUsuario,
              decoration: const InputDecoration(
                label: Text("Elije tu nombre de usuario"),
                hintText: 'Usuario',
                border: OutlineInputBorder(),
                hintMaxLines: 20,
              ),
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Ingrese un nombre de usuario';
                }else if ( value.length > 20){
                  return '20 cararcteres';
                }
                return null;
                },
            ),
            const SizedBox(height: 10),
            Autocomplete(
              fieldViewBuilder: (BuildContext context,
              TextEditingController controller,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted){
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Carrera',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if(value == null || value.isEmpty){
                      return 'Ingrese una carrera, despues podra modificarla';
                    }
                    if (_selectedOption == null || value != _selectedOption) {
                      return 'Por favor seleccione una carrera válida de las opciones';
                    }
                    return null; 
                  },
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) async {
                _carrera = textEditingValue.text;
                final Iterable<String> options = await Carrera.opciones(_carrera);
                if( _carrera != textEditingValue.text){
                  return _lastOptions; 
                }
                _lastOptions = options;
                return options;
              },
              onSelected: (String selection){ 
              setState(() {
                _selectedOption = selection; // Guardar la opción seleccionada
              });
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                      child: ListView.separated(
                        separatorBuilder: (_, e)=> const Divider(),
                        padding: const EdgeInsets.all(10),
                        itemCount: options.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                );
              }
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _documento,
              decoration: const InputDecoration(
                hintText: 'Número de documento',
                border: OutlineInputBorder(),
                hintMaxLines: 20,
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
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _documento2,
              decoration: const InputDecoration(
                hintText: 'Confirma tu numero de documento',
                border: OutlineInputBorder(),
                hintMaxLines: 20,
              ),
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Ingrese un nombre de usuario';
                }else if ( value != _documento.text){
                  return 'El documento no coincide';
                }
                return null;
              },
              onFieldSubmitted: (value){
                if (_formkey.currentState!.validate()){
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context)=> UserLogic(nombre:_nombreUsuario.text, documento:_documento.text, carrera: _carrera)));
                }
              }
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: (){
                if (_formkey.currentState!.validate()){
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context)=> UserLogic(nombre:_nombreUsuario.text, documento:_documento.text, carrera: _carrera)));
                }
              },
              child: const Text('Crear Usuario'))
          ],
        )),
    );
  }
}

class UserLogic extends StatelessWidget {
  const UserLogic( {super.key, required this.nombre, required this.documento ,required this.carrera});
  final String documento;
  final String nombre;
  final String carrera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool?>(
        future: Usuario.crear(nombre, documento, carrera),
        builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            bool exists = snapshot.data ?? false; 
            
            if (!exists) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ScreenController(); 
            }
          }
        },
      ),
    );
  }
}