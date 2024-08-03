import 'package:flutter/material.dart';
import 'package:plan_estudio/home.dart';


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
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.accessibility_new),
        title: const Text('Tus estudios'),
        
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(),
          Placeholder(),
        ],
      ),
      bottomNavigationBar: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.person), text: 'Perfil'),
          ],
        ),
    );
  }
}


