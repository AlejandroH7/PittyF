import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/pedido_completo_model.dart';
import 'package:pittyf/data/services/pedido_completo_api.dart';
import 'package:pittyf/presentation/screens/pedido_completo_form_screen.dart';

class PedidoCompletoListScreen extends StatefulWidget {
  const PedidoCompletoListScreen({super.key});

  static const String routeName = '/pedidos-completos';

  @override
  State<PedidoCompletoListScreen> createState() =>
      _PedidoCompletoListScreenState();
}

class _PedidoCompletoListScreenState extends State<PedidoCompletoListScreen> {
  late Future<List<PedidoCompletoModel>> _pedidosFuture;
  final PedidoCompletoApi _pedidosApi = PedidoCompletoApi();

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _refreshPedidos();
  }

  Future<List<PedidoCompletoModel>> _refreshPedidos() async {
    final fetchedPedidos = await _pedidosApi.getAllPedidosCompletos();
    setState(() {
      fetchedPedidos.sort((a, b) {
        final dateA = DateTime.tryParse(a.updatedAt ?? a.createdAt ?? '');
        final dateB = DateTime.tryParse(b.updatedAt ?? b.createdAt ?? '');
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
      _pedidosFuture = Future.value(fetchedPedidos);
    });
    return fetchedPedidos;
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
    const Color primaryColor = Color(0xFFE91E63);
    const Color accentColor = Color(0xFFFFC107);
    const Color backgroundColor = Color(0xFFFFF8E1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pedidos',
          style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _Circle(color: primaryColor.withAlpha(10), size: 300),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: _Circle(color: primaryColor.withAlpha(15), size: 400),
          ),
          FutureBuilder<List<PedidoCompletoModel>>(
            future: _pedidosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
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
                  color: primaryColor,
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
                          title: Text(
                            '${pedido.postreNombre} para ${pedido.clienteNombre}',
                          ),
                          subtitle: Text(
                            'Total: \$${pedido.total.toStringAsFixed(2)} - Cant: ${pedido.cantidad}',
                          ),
                          trailing: Text(_formatDate(pedido.fechaEntrega)),
                          onTap: () async {
                            final result = await Navigator.of(
                              context,
                            ).pushNamed(
                              '/pedidos-completos/detalle',
                              arguments: pedido.id,
                            );
                            if (result == true) {
                              await _refreshPedidos();
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).pushNamed(PedidoCompletoFormScreen.routeName);
          if (result == true) {
            await _refreshPedidos();
          }
        },
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final Color color;
  final double size;

  const _Circle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
