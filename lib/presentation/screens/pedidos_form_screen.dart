import 'package:flutter/material.dart';

class PedidoFormScreen extends StatelessWidget {
  const PedidoFormScreen({super.key});

  static const String routeName = '/pedidos/nuevo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Pedido'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Formulario para crear pedidos (próximamente)'),
      ),
    );
  }
}