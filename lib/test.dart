import 'package:flutter/material.dart';




class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Styled Modal Bottom Sheet')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                ),
                backgroundColor: Colors.white.withOpacity(0.9),
                builder: (BuildContext context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Navigator(
                    onGenerateRoute: (RouteSettings settings) {
                      return MaterialPageRoute(
                        builder: (BuildContext context) => Center(child: FirstScreen()),
                      );
                    },
                  ),
                );
              },
              );
            },
            child: const Text('Show Modal Bottom Sheet'),
          ),
        ),
      ),
    );
  }

  

  

}


class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('primera pantalla'),
      ),
      body: Column( 
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Screen 1'),
                        onTap: () {
                          _navigateToScreen(context, SecondScreen());
                        },
                      ),
                      ListTile(
                        title: Text('Screen 2'),
                        onTap: () {
                          _navigateToScreen(context, ThirdScreen());
                        },
                      ),
                      ListTile(
                        title: Text('Screen 3'),
                        onTap: () {
                          _navigateToScreen(context, FourthScreen());
                        },
                      ),
                    ],
                  ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}


class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Segunda Pantalla'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Volver'),
        ),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tercera Pantalla'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Volver'),
        ),
      ),
    );
  }
}

class FourthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuarta Pantalla'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Volver'),
        ),
      ),
    );
  }
}