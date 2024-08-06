import 'dart:async';
import 'package:flutter/material.dart';

// Definimos los posibles estados de una tarea
enum TaskState { pending, inProgress, completed }

// Clase para representar una tarea
class Task {
  String title;
  TaskState state;

  Task(this.title, this.state);
}

void main() {
  runApp(MaterialApp(home: TaskScreen()));
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Controlador del stream para simular la actualización de la lista
  final StreamController<List<Task>> _taskController = StreamController();

  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    // Cargar la lista inicial
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.close();
    super.dispose();
  }

  // Método para cargar las tareas (simula una solicitud de datos)
  Future<void> _loadTasks() async {
    // Simula una carga de datos
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _tasks = [
        Task("Tarea 1", TaskState.pending),
        Task("Tarea 2", TaskState.inProgress),
        Task("Tarea 3", TaskState.completed),
      ];
      _taskController.add(_tasks);
    });
  }

  // Método para actualizar el estado de una tarea
  void _updateTaskState(int index, TaskState newState) {
    setState(() {
      _tasks[index].state = newState;
      // Recargar la lista en el stream después de actualizar
      _taskController.add(_tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tareas')),
      body: StreamBuilder<List<Task>>(
        stream: _taskController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tareas disponibles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final task = snapshot.data![index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.state.toString().split('.').last),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert), // Icono de tres puntos
                    onSelected: (String value) {
                      // Acciones al seleccionar una opción
                      switch (value) {
                        case 'opcion1':
                          print('Opción 1 seleccionada para el elemento $index');
                          break;
                        case 'opcion2':
                          print('Opción 2 seleccionada para el elemento $index');
                          break;
                        case 'opcion3':
                          print('Opción 3 seleccionada para el elemento $index');
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'opcion1',
                        child: Text('Opción 1'),
                      ),
                      PopupMenuItem<String>(
                        value: 'opcion2',
                        child: Text('Opción 2'),
                      ),
                      PopupMenuItem<String>(
                        value: 'opcion3',
                        child: Text('Opción 3'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
