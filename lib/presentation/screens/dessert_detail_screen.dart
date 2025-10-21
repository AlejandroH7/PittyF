import 'package:flutter/material.dart';
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
    _dessertId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_dessertId != null) {
      _dessertDetailFuture = _dessertsApi.getDessertById(_dessertId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dessertId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('ID de postre no proporcionado.'),
        ),
      );
    }

    return FutureBuilder<DessertModel>(
      future: _dessertDetailFuture,
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
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('No encontrado'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('No se encontraron detalles del postre.'),
            ),
          );
        } else {
          final dessert = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle del Postre'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final nav = Navigator.of(context); // Capture Navigator before async gap
                    final result = await nav.pushNamed(
                      DessertEditScreen.routeName, // Navigate to the actual edit screen
                      arguments: dessert, // Pass the entire dessert object
                    );
                    if (!mounted) return; // Check mounted after async gap
                    if (result == true) {
                      // If editing was successful, refresh the detail screen
                      setState(() {
                        _dessertDetailFuture = _dessertsApi.getDessertById(_dessertId!); // Refresh data
                      });
                      // Also pop this screen with true to indicate a change to the previous screen
                      nav.pop(true);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final nav = Navigator.of(context); // Capture Navigator before async gap
                    final bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar Eliminación'),
                        content: Text('¿Estás seguro de que quieres eliminar a ${dessert.nombre}?'),
                        actions: [
                          TextButton(
                            onPressed: () => nav.pop(false), // Use captured nav
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => nav.pop(true), // Use captured nav
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );

                    if (!mounted) return; // Check mounted after async gap
                    if (confirmDelete == true) {
                      try {
                        await _dessertsApi.deleteDessert(dessert.id); // Need to add deleteDessert to DessertsApi
                        if (!mounted) return; // Check mounted after async gap
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Postre eliminado exitosamente!')),
                        );
                        // Pop this screen with true to indicate a change to the previous screen (DessertsListScreen)
                        nav.pop(true);
                      } catch (e) {
                        if (!mounted) return; // Check mounted after async gap
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al eliminar postre: $e')),
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
                  _buildDetailRow('ID:', dessert.id.toString()),
                  _buildDetailRow('Nombre:', dessert.nombre),
                  _buildDetailRow('Precio:', '\$${dessert.precio.toStringAsFixed(2)}'),
                  _buildDetailRow('Porciones:', dessert.porciones.toString()),
                  _buildDetailRow('Activo:', dessert.activo ? 'Sí' : 'No'),
                  _buildDetailRow('Fecha de Creación:', dessert.createdAt ?? 'N/A'),
                  _buildDetailRow('Última Actualización:', dessert.updatedAt ?? 'N/A'),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}