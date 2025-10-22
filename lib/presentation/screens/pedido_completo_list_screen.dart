import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/pedido_completo_model.dart';
import 'package:pittyf/data/services/pedido_completo_api.dart';

class PedidoCompletoListScreen extends StatefulWidget {
  const PedidoCompletoListScreen({super.key});

  static const String routeName = '/pedidos-completos';

  @override
  State<PedidoCompletoListScreen> createState() => _PedidoCompletoListScreenState();
}

class _PedidoCompletoListScreenState extends State<PedidoCompletoListScreen> {
  late Future<List<PedidoCompletoModel>> _pedidosFuture;
  final PedidoCompletoApi _pedidosApi = PedidoCompletoApi();

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _pedidosApi.getAllPedidosCompletos();
  }

  Future<void> _refreshPedidos() async {
    setState(() {
      _pedidosFuture = _pedidosApi.getAllPedidosCompletos();
    });
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pedidos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<PedidoCompletoModel>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  ),
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
            final pedidos = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshPedidos,
              child: ListView.builder(
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text('${pedido.postreNombre} para ${pedido.clienteNombre}'),
                      subtitle: Text('Total: \$${pedido.total.toStringAsFixed(2)} - Cant: ${pedido.cantidad}'),
                      trailing: Text(_formatDate(pedido.fechaEntrega)),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/pedidos-completos/detalle',
                          arguments: pedido.id,
                        );
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
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/pedidos-completos/nuevo');
          if (result == true) {
            _refreshPedidos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}