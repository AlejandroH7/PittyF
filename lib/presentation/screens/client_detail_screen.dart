import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:pittyf/data/models/client_model.dart';
import 'package:pittyf/data/services/clients_api.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key});

  static const String routeName = '/clientes/detalle';

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  late Future<ClientModel> _clientDetailFuture;
  final ClientsApi _clientsApi = ClientsApi();
  int? _clientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clientId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_clientId != null) {
      _clientDetailFuture = _clientsApi.getClientById(_clientId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_clientId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('ID de cliente no proporcionado.')),
      );
    }

    return FutureBuilder<ClientModel>(
      future: _clientDetailFuture,
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
              child: Text('No se encontraron detalles del cliente.'),
            ),
          );
        } else {
          final client = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle del Cliente'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final nav = Navigator.of(
                      context,
                    ); // Capture Navigator before async gap
                    final result = await nav.pushNamed(
                      '/clientes/editar', // New route for editing
                      arguments: client, // Pass the entire client object
                    );
                    if (!mounted) return; // Check mounted after async gap
                    if (result == true) {
                      // If editing was successful, refresh the detail screen
                      setState(() {
                        _clientDetailFuture = _clientsApi.getClientById(
                          _clientId!,
                        ); // Refresh data
                      });
                      // Also pop this screen with true to indicate a change to the previous screen
                      nav.pop(true);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final nav = Navigator.of(
                      context,
                    ); // Capture Navigator before async gap
                    final bool? confirmDelete = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirmar Eliminación'),
                            content: Text(
                              '¿Estás seguro de que quieres eliminar a ${client.nombre}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => nav.pop(false), // Use captured nav
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed:
                                    () => nav.pop(true), // Use captured nav
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                    );

                    if (!mounted) return; // Check mounted after async gap
                    if (confirmDelete == true) {
                      final messenger = ScaffoldMessenger.of(
                        context,
                      ); // Capture messenger before try-catch
                      try {
                        await _clientsApi.deleteClient(client.id);
                        if (!mounted) return; // Check mounted after async gap
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Cliente eliminado exitosamente!'),
                          ),
                        );
                        // Pop this screen with true to indicate a change to the previous screen (ClientsListScreen)
                        nav.pop(true);
                      } on DioException catch (e) {
                        // Catch DioException specifically
                        if (!mounted) return; // Check mounted after async gap
                        if (e.response?.statusCode == 409) {
                          String errorMessage = 'Error desconocido';
                          if (e.response?.data is Map<String, dynamic> &&
                              e.response?.data['message'] != null) {
                            errorMessage = e.response!.data['message'];
                          }
                          messenger.showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error al eliminar cliente: ${e.message}',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return; // Check mounted after async gap
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error inesperado al eliminar cliente: $e',
                            ),
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
                  _buildDetailRow('ID:', client.id.toString()),
                  _buildDetailRow('Nombre:', client.nombre),
                  _buildDetailRow('Teléfono:', client.telefono ?? 'N/A'),
                  _buildDetailRow('Notas:', client.notas ?? 'N/A'),
                  _buildDetailRow(
                    'Fecha de Creación:',
                    client.createdAt ?? 'N/A',
                  ),
                  _buildDetailRow('Creado por:', client.createdBy ?? 'N/A'),
                  _buildDetailRow(
                    'Última Actualización:',
                    client.updatedAt ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Actualizado por:',
                    client.updatedBy ?? 'N/A',
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
