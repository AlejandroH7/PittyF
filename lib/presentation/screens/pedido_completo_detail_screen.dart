import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/pedido_completo_model.dart';
import 'package:pittyf/data/services/pedido_completo_api.dart';
import 'package:pittyf/presentation/screens/pedido_completo_edit_screen.dart'
    show PedidoCompletoEditScreen;

class PedidoCompletoDetailScreen extends StatefulWidget {
  const PedidoCompletoDetailScreen({super.key});

  static const String routeName = '/pedidos-completos/detalle';

  @override
  State<PedidoCompletoDetailScreen> createState() =>
      _PedidoCompletoDetailScreenState();
}

class _PedidoCompletoDetailScreenState
    extends State<PedidoCompletoDetailScreen> {
  late Future<PedidoCompletoModel> _pedidoDetailFuture;
  final PedidoCompletoApi _pedidosApi = PedidoCompletoApi();
  int? _pedidoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pedidoId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_pedidoId != null) {
      _pedidoDetailFuture = _pedidosApi.getPedidoCompletoById(_pedidoId!);
    }
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
    if (_pedidoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('ID de pedido no proporcionado.')),
      );
    }

    return FutureBuilder<PedidoCompletoModel>(
      future: _pedidoDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cargando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('No encontrado')),
            body: const Center(
              child: Text('No se encontraron detalles del pedido.'),
            ),
          );
        } else {
          final pedido = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Detalle del Pedido #${pedido.id}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.of(context).pushNamed(
                      PedidoCompletoEditScreen.routeName,
                      arguments: pedido,
                    );
                    if (result == true) {
                      // Refresh the details if the edit was successful
                      setState(() {
                        _pedidoDetailFuture = _pedidosApi.getPedidoCompletoById(
                          _pedidoId!,
                        );
                      });
                      Navigator.of(context).pop(true); // Signal list screen to refresh
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirmar Eliminación'),
                            content: const Text(
                              '¿Estás seguro de que quieres eliminar este pedido?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      try {
                        await _pedidosApi.deletePedidoCompleto(_pedidoId!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pedido eliminado exitosamente'),
                            ),
                          );
                          Navigator.of(
                            context,
                          ).pop(true); // Go back to list and signal refresh
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar: $e')),
                          );
                        }
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
                  _buildDetailRow('Cliente:', pedido.clienteNombre),
                  _buildDetailRow('Postre:', pedido.postreNombre),
                  _buildDetailRow('Cantidad:', pedido.cantidad.toString()),
                  _buildDetailRow(
                    'Total:',
                    '\$${pedido.total.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Nota:', pedido.nota ?? 'N/A'),
                  _buildDetailRow(
                    'Fecha de Entrega:',
                    _formatDate(pedido.fechaEntrega),
                  ),
                  _buildDetailRow(
                    'Fecha de Creación:',
                    _formatDate(pedido.createdAt),
                  ),
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
