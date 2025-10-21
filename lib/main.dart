import 'package:flutter/material.dart';
import 'package:pittyf/presentation/screens/inicio_screen.dart';
import 'package:pittyf/presentation/screens/main_menu_screen.dart';
import 'package:pittyf/presentation/screens/clients_list_screen.dart';
import 'package:pittyf/presentation/screens/client_form_screen.dart';
import 'package:pittyf/presentation/screens/client_detail_screen.dart';
import 'package:pittyf/presentation/screens/client_edit_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitty App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)), // Wine color
        useMaterial3: true,
      ),
      initialRoute: InicioScreen.routeName,
      routes: {
        InicioScreen.routeName: (context) => const InicioScreen(),
        '/home': (context) => const Center(child: Text('Home Screen Placeholder')), // Placeholder for home screen
        MainMenuScreen.routeName: (context) => const MainMenuScreen(),
        ClientsListScreen.routeName: (context) => const ClientsListScreen(),
        '/postres': (context) => const Center(child: Text('Postres Screen Placeholder')),
        '/ingredientes': (context) => const Center(child: Text('Ingredientes Screen Placeholder')),
        '/pedidos': (context) => const Center(child: Text('Pedidos Screen Placeholder')),
        '/eventos': (context) => const Center(child: Text('Eventos Screen Placeholder')),
        ClientFormScreen.routeName: (context) => const ClientFormScreen(),
        ClientDetailScreen.routeName: (context) => const ClientDetailScreen(),
        ClientEditScreen.routeName: (context) => const ClientEditScreen(),
      },
    );
  }
}

