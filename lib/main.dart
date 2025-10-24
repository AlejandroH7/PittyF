import 'package:flutter/material.dart';
import 'package:pittyf/presentation/screens/inicio_screen.dart';
import 'package:pittyf/presentation/screens/main_menu_screen.dart';
import 'package:pittyf/presentation/screens/clients_list_screen.dart';
import 'package:pittyf/presentation/screens/client_form_screen.dart';
import 'package:pittyf/presentation/screens/client_detail_screen.dart';
import 'package:pittyf/presentation/screens/client_edit_screen.dart';
import 'package:pittyf/presentation/screens/desserts_list_screen.dart';
import 'package:pittyf/presentation/screens/dessert_detail_screen.dart';
import 'package:pittyf/presentation/screens/dessert_form_screen.dart';
import 'package:pittyf/presentation/screens/dessert_edit_screen.dart';
import 'package:pittyf/presentation/screens/pedidos_list_screen.dart';
import 'package:pittyf/presentation/screens/pedido_detail_screen.dart'; // Import PedidoDetailScreen
import 'package:pittyf/presentation/screens/pedido_completo_list_screen.dart';
import 'package:pittyf/presentation/screens/pedido_completo_detail_screen.dart';
import 'package:pittyf/presentation/screens/pedido_completo_form_screen.dart';
import 'package:pittyf/presentation/screens/pedido_completo_edit_screen.dart';
import 'package:pittyf/presentation/screens/events_list_screen.dart';
import 'package:pittyf/presentation/screens/event_form_screen.dart';
import 'package:pittyf/presentation/screens/event_edit_screen.dart';
import 'package:pittyf/presentation/screens/event_detail_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF66001F), // Burgundy
          primary: const Color(0xFF66001F), // Burgundy
          secondary: const Color(0xFFFEFCEF), // Cream
          background: const Color(0xFFFEFCEF), // Cream
        ),
        scaffoldBackgroundColor: const Color(0xFFFEFCEF), // Cream
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF66001F), // Burgundy
          foregroundColor: Color(0xFFFEFCEF), // Cream for text/icons
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF66001F)),
          bodyMedium: TextStyle(color: Color(0xFF66001F)),
          displayLarge: TextStyle(color: Color(0xFF66001F)),
          displayMedium: TextStyle(color: Color(0xFF66001F)),
          displaySmall: TextStyle(color: Color(0xFF66001F)),
          headlineMedium: TextStyle(color: Color(0xFF66001F)),
          headlineSmall: TextStyle(color: Color(0xFF66001F)),
          titleLarge: TextStyle(color: Color(0xFF66001F)),
        ),
        useMaterial3: true,
      ),
      initialRoute: InicioScreen.routeName,
      routes: {
        InicioScreen.routeName: (context) => const InicioScreen(),
        '/home': (context) => const Center(child: Text('Home Screen Placeholder')), // Placeholder for home screen
        MainMenuScreen.routeName: (context) => const MainMenuScreen(),
        ClientsListScreen.routeName: (context) => const ClientsListScreen(),
        DessertsListScreen.routeName: (context) => const DessertsListScreen(),
        PedidosListScreen.routeName: (context) => const PedidosListScreen(),
        PedidoCompletoListScreen.routeName: (context) => const PedidoCompletoListScreen(),
        PedidoCompletoDetailScreen.routeName: (context) => const PedidoCompletoDetailScreen(),
        PedidoCompletoFormScreen.routeName: (context) => const PedidoCompletoFormScreen(),
        PedidoCompletoEditScreen.routeName: (context) => const PedidoCompletoEditScreen(),
        EventsListScreen.routeName: (context) => const EventsListScreen(),
        EventFormScreen.routeName: (context) => const EventFormScreen(),
        EventEditScreen.routeName: (context) => const EventEditScreen(),
        EventDetailScreen.routeName: (context) => const EventDetailScreen(),
        ClientFormScreen.routeName: (context) => const ClientFormScreen(),
        ClientDetailScreen.routeName: (context) => const ClientDetailScreen(),
        ClientEditScreen.routeName: (context) => const ClientEditScreen(),
        DessertDetailScreen.routeName: (context) => const DessertDetailScreen(),
        DessertFormScreen.routeName: (context) => const DessertFormScreen(),
        DessertEditScreen.routeName: (context) => const DessertEditScreen(),
        PedidoDetailScreen.routeName: (context) => const PedidoDetailScreen(), // Add PedidoDetailScreen route
      },
    );
  }
}