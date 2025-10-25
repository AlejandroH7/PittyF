import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/pedido_model.dart';
import 'package:pittyf/data/services/pedidos_api.dart';

class PedidoDetailScreen extends StatefulWidget {
  const PedidoDetailScreen({super.key});

  static const String routeName = '/pedidos/detalle';

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  late Future<PedidoModel> _pedidoDetailFuture;
  final PedidosApi _pedidosApi = PedidosApi();
  int? _pedidoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pedidoId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_pedidoId != null) {
      _pedidoDetailFuture = _pedidosApi.getPedidoById(_pedidoId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pedidoId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('ID de pedido no proporcionado.')),
      );
    }

    return FutureBuilder<PedidoModel>(
      future: _pedidoDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cargando...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('No encontrado'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('No se encontraron detalles del pedido.'),
            ),
          );
        } else {
          final pedido = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Pedido #${pedido.id}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    // TODO: Implement navigation to pedido edit screen
                    final nav = Navigator.of(
                      context,
                    ); // Capture Navigator before async gap
                    final result = await nav.pushNamed(
                      '/pedidos/editar', // New route for editing (will be created later)
                      arguments: pedido, // Pass the entire pedido object
                    );
                    if (!mounted) return; // Check mounted after async gap
                    if (result == true) {
                      setState(() {
                        _pedidoDetailFuture = _pedidosApi.getPedidoById(
                          _pedidoId!,
                        ); // Refresh data
                      });
                      nav.pop(true);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // TODO: Implement delete pedido
                    final nav = Navigator.of(
                      context,
                    ); // Capture Navigator before async gap
                    final bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirmar Eliminación'),
                            content: Text(
                              '¿Estás seguro de que quieres eliminar el pedido #${pedido.id}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => nav.pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => nav.pop(true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                    );

                    if (!mounted) return; // Check mounted after async gap
                    if (confirmDelete == true) {
                      final messenger = ScaffoldMessenger.of(
                        context,
                      ); // Capture ScaffoldMessenger before try-catch
                      try {
                        // await _pedidosApi.deletePedido(pedido.id); // Need to add deletePedido to PedidosApi
                        if (!mounted) return; // Check mounted after async gap
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pedido eliminado exitosamente! (Simulado)',
                            ),
                          ),
                        );
                        nav.pop(true);
                      } catch (e) {
                        if (!mounted) return; // Check mounted after async gap
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Error al eliminar pedido: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('ID Pedido:', pedido.id.toString()),
                  _buildDetailRow('Cliente:', pedido.clienteNombre),
                  _buildDetailRow(
                    'Fecha Entrega:',
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(pedido.fechaEntrega)),
                  ),
                  _buildDetailRow('Estado:', pedido.estado),
                  _buildDetailRow('Notas:', pedido.notas ?? 'N/A'),
                  _buildDetailRow(
                    'Total:',
                    '\$${pedido.total.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Items del Pedido',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...pedido.items.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text('${item.cantidad} x ${item.postreNombre}'),
                        subtitle: Text(
                          'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                        ),
                        trailing: Text('Postre ID: ${item.postreId}'),
                        // TODO: Display personalizaciones if needed
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
