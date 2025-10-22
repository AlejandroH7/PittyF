import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/event_model.dart';
import 'package:pittyf/data/services/events_api.dart';
import 'package:pittyf/presentation/screens/event_edit_screen.dart'
    show EventEditScreen;

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  static const String routeName = '/eventos/detalle';

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<EventModel> _eventDetailFuture;
  final EventsApi _eventsApi = EventsApi();
  int? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_eventId != null) {
      _eventDetailFuture = _eventsApi.getEventById(_eventId!);
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
    if (_eventId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('ID de evento no proporcionado.')),
      );
    }

    return FutureBuilder<EventModel>(
      future: _eventDetailFuture,
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
              child: Text('No se encontraron detalles del evento.'),
            ),
          );
        } else {
          final event = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Detalle del Evento #${event.id}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.of(
                      context,
                    ).pushNamed(EventEditScreen.routeName, arguments: event);
                    if (result == true) {
                      // Refresh the details if the edit was successful
                      setState(() {
                        _eventDetailFuture = _eventsApi.getEventById(_eventId!);
                      });
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
                              '¿Estás seguro de que quieres eliminar este evento?',
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
                        await _eventsApi.deleteEvent(_eventId!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Evento eliminado exitosamente'),
                            ),
                          );
                          Navigator.of(
                            context,
                          ).pop(true); // Go back to list and signal refresh
                        }
                      } on DioException catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar: $e')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error inesperado al eliminar: $e'),
                            ),
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
                  _buildDetailRow('Título:', event.titulo),
                  _buildDetailRow('Nombre:', event.nombre),
                  _buildDetailRow('Fecha:', _formatDate(event.fecha)),
                  _buildDetailRow('Ubicación:', event.ubicacion ?? 'N/A'),
                  _buildDetailRow('Descripción:', event.descripcion ?? 'N/A'),
                  _buildDetailRow(
                    'Creado el:',
                    _formatDate(event.createdAt ?? ''),
                  ),
                  _buildDetailRow(
                    'Actualizado el:',
                    _formatDate(event.updatedAt ?? ''),
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
