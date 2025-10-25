
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/pedido_completo_model.dart';
import 'package:pittyf/data/services/pedido_completo_api.dart';
import 'package:pittyf/presentation/screens/pedido_completo_edit_screen.dart';

class PedidoCompletoDetailScreen extends StatefulWidget {
  const PedidoCompletoDetailScreen({super.key});

  static const String routeName = '/pedidos-completos/detalle';

  @override
  State<PedidoCompletoDetailScreen> createState() => _PedidoCompletoDetailScreenState();
}

class _PedidoCompletoDetailScreenState extends State<PedidoCompletoDetailScreen> {
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

  Future<void> _refreshPedidoDetails() {
    setState(() {
      _pedidoDetailFuture = _pedidosApi.getPedidoCompletoById(_pedidoId!);
    });
    return _pedidoDetailFuture;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63);
    const Color backgroundColor = Color(0xFFFFF8E1);

    if (_pedidoId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(title: const Text('Error'), backgroundColor: primaryColor, foregroundColor: Colors.white),
        body: const Center(child: Text('ID de pedido no proporcionado.')),
      );
    }

    return FutureBuilder<PedidoCompletoModel>(
      future: _pedidoDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text('Cargando...'), backgroundColor: primaryColor, foregroundColor: Colors.white),
            body: const Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text('Error'), backgroundColor: primaryColor, foregroundColor: Colors.white),
            body: Center(child: Text('Error al cargar el pedido: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text('No Encontrado'), backgroundColor: primaryColor, foregroundColor: Colors.white),
            body: const Center(child: Text('No se encontraron detalles del pedido.')),
          );
        }

        final pedido = snapshot.data!;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('Pedido #${pedido.id}', style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _editPedido(pedido)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deletePedido(pedido)),
            ],
          ),
          body: Stack(
            children: [
              Positioned(top: -100, right: -100, child: _Circle(color: primaryColor.withAlpha(10), size: 300)),
              Positioned(bottom: -150, left: -150, child: _Circle(color: primaryColor.withAlpha(15), size: 400)),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _InfoCard(
                      title: 'Resumen del Pedido',
                      children: [
                        _DetailRow(icon: Icons.person_outline, label: 'Cliente', value: pedido.clienteNombre),
                        _DetailRow(icon: Icons.cake_outlined, label: 'Postre', value: pedido.postreNombre),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Detalles de Entrega',
                      children: [
                        _DetailRow(icon: Icons.calendar_today, label: 'Fecha de Entrega', value: _formatDate(pedido.fechaEntrega)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Costo y Cantidad',
                      children: [
                        _DetailRow(icon: Icons.shopping_bag_outlined, label: 'Cantidad', value: pedido.cantidad.toString()),
                        _DetailRow(icon: Icons.attach_money, label: 'Total', value: NumberFormat.simpleCurrency(locale: 'es_MX').format(pedido.total), isValueBold: true),
                      ],
                    ),
                    if (pedido.nota != null && pedido.nota!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _InfoCard(
                          title: 'Notas Adicionales',
                          children: [_DetailRow(icon: Icons.notes_outlined, label: 'Nota', value: pedido.nota!, isSingle: true)],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('EEEE, dd MMMM yyyy, hh:mm a', 'es_MX').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void _editPedido(PedidoCompletoModel pedido) async {
    final result = await Navigator.of(context).pushNamed(PedidoCompletoEditScreen.routeName, arguments: pedido);
    if (result == true && mounted) {
      _refreshPedidoDetails();
      ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('Pedido actualizado'), backgroundColor: Colors.green));
    }
  }

  void _deletePedido(PedidoCompletoModel pedido) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el pedido #${pedido.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      try {
        await _pedidosApi.deletePedidoCompleto(pedido.id);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } on DioException catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        String errorMessage = e.response?.data?['message'] ?? 'Error al eliminar el pedido.';
        messenger.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      } catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(SnackBar(content: Text('Un error inesperado ocurrió: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isValueBold;
  final bool isSingle;

  const _DetailRow({required this.icon, required this.label, required this.value, this.isValueBold = false, this.isSingle = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: isSingle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSingle) Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                if (!isSingle) const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, color: isValueBold ? const Color(0xFF333333) : Colors.black87, fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        ],
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
