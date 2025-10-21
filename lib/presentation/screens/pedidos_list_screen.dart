import 'package:flutter/material.dart';
import 'package:pittyf/data/models/pedido_model.dart';
import 'package:pittyf/data/services/pedidos_api.dart';
import 'package:pittyf/presentation/screens/pedidos_form_screen.dart';
import 'package:pittyf/presentation/screens/pedido_detail_screen.dart';

class PedidosListScreen extends StatefulWidget {
  const PedidosListScreen({super.key});

  static const String routeName = '/pedidos';

  @override
  State<PedidosListScreen> createState() => _PedidosListScreenState();
}

class _PedidosListScreenState extends State<PedidosListScreen> {
  late Future<List<PedidoModel>> _pedidosFuture;
  final PedidosApi _pedidosApi = PedidosApi();

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _pedidosApi.getAllPedidos();
  }

  Future<void> _refreshPedidos() async {
    setState(() {
      _pedidosFuture = _pedidosApi.getAllPedidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pedidos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<PedidoModel>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refreshPedidos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay pedidos disponibles.'),
                  ElevatedButton(
                    onPressed: _refreshPedidos,
                    child: const Text('Recargar'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshPedidos,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final pedido = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    elevation: 2,
                    child: ListTile(
                      title: Text('Pedido #${pedido.id} - ${pedido.clienteNombre}'),
                      subtitle: Text('Total: \$${pedido.total.toStringAsFixed(2)} - Estado: ${pedido.estado}'),
                      trailing: Text('Fecha: ${pedido.fechaEntrega.split('T')[0]}'), // Display only date part
                      onTap: () async {
                        final nav = Navigator.of(context); // Capture Navigator before async gap
                        final result = await nav.pushNamed(
                          PedidoDetailScreen.routeName,
                          arguments: pedido.id, // Pass the pedido ID
                        );
                        if (!mounted) return; // Check mounted after async gap
                        if (result == true) {
                          _refreshPedidos(); // Refresh pedidos if a change was made
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement navigation to add pedido screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Botón para agregar pedido presionado')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}