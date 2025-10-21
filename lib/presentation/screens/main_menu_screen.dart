import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const String routeName = '/menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Clientes'),
            onTap: () {
              Navigator.of(context).pushNamed('/clientes');
            },
          ),
          ListTile(
            title: const Text('Postres'),
            onTap: () {
              Navigator.of(context).pushNamed('/postres');
            },
          ),
          ListTile(
            title: const Text('Ingredientes'),
            onTap: () {
              Navigator.of(context).pushNamed('/ingredientes');
            },
          ),
          ListTile(
            title: const Text('Pedidos'),
            onTap: () {
              Navigator.of(context).pushNamed('/pedidos');
            },
          ),
          ListTile(
            title: const Text('Eventos'),
            onTap: () {
              Navigator.of(context).pushNamed('/eventos');
            },
          ),
        ],
      ),
    );
  }
}