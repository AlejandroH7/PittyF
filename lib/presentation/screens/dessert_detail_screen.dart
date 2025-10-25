import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/dessert_model.dart';
import 'package:pittyf/data/services/desserts_api.dart';
import 'package:pittyf/presentation/screens/dessert_edit_screen.dart';

class DessertDetailScreen extends StatefulWidget {
  const DessertDetailScreen({super.key});

  static const String routeName = '/postres/detalle';

  @override
  State<DessertDetailScreen> createState() => _DessertDetailScreenState();
}

class _DessertDetailScreenState extends State<DessertDetailScreen> {
  late Future<DessertModel> _dessertDetailFuture;
  final DessertsApi _dessertsApi = DessertsApi();
  int? _dessertId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      _dessertId = arg;
      _dessertDetailFuture = _dessertsApi.getDessertById(_dessertId!);
    }
  }

  Future<void> _refreshDessertDetails() {
    setState(() {
      _dessertDetailFuture = _dessertsApi.getDessertById(_dessertId!);
    });
    return _dessertDetailFuture;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63);
    const Color backgroundColor = Color(0xFFFFF8E1);

    if (_dessertId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('ID de postre no proporcionado.')),
      );
    }

    return FutureBuilder<DessertModel>(
      future: _dessertDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text('Error al cargar el postre: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('No Encontrado'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('No se encontraron detalles del postre.'),
            ),
          );
        }

        final dessert = snapshot.data!;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    dessert.nombre,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: primaryColor.withAlpha(50)),
                      Positioned(
                        top: -50,
                        left: -50,
                        child: _Circle(
                          color: Colors.white.withAlpha(20),
                          size: 200,
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        right: -80,
                        child: _Circle(
                          color: Colors.white.withAlpha(25),
                          size: 300,
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.cake_outlined,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editDessert(dessert),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteDessert(dessert),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _InfoCard(
                        title: 'Detalles del Postre',
                        children: [
                          _DetailRow(
                            icon: Icons.attach_money,
                            label: 'Precio',
                            value: NumberFormat.simpleCurrency(
                              locale: 'es_MX',
                            ).format(dessert.precio),
                          ),
                          _DetailRow(
                            icon: Icons.pie_chart_outline,
                            label: 'Porciones',
                            value: '${dessert.porciones} porciones',
                          ),
                          _DetailRow(
                            icon:
                                dessert.activo
                                    ? Icons.toggle_on
                                    : Icons.toggle_off,
                            label: 'Estado',
                            value: dessert.activo ? 'Activo' : 'Inactivo',
                            valueColor:
                                dessert.activo ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Información del Sistema',
                        children: [
                          _DetailRow(
                            icon: Icons.fingerprint,
                            label: 'ID de Postre',
                            value: dessert.id.toString(),
                          ),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Fecha de Creación',
                            value: _formatDate(dessert.createdAt),
                          ),
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Última Actualización',
                            value: _formatDate(dessert.updatedAt),
                          ),
                        ],
                      ),
                    ],
                  ),
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
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void _editDessert(DessertModel dessert) async {
    final result = await Navigator.of(
      context,
    ).pushNamed(DessertEditScreen.routeName, arguments: dessert);
    if (result == true && mounted) {
      _refreshDessertDetails();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Postre actualizado'),
            backgroundColor: Colors.green,
          ),
        );
    }
  }

  void _deleteDessert(DessertModel dessert) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar ${dessert.nombre}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete == true && mounted) {
      try {
        await _dessertsApi.deleteDessert(dessert.id);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } on DioException catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        String errorMessage =
            e.response?.data?['message'] ?? 'Error al eliminar el postre.';
        messenger.showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Un error inesperado ocurrió: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
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
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
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
