import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/event_model.dart';
import 'package:pittyf/data/services/events_api.dart';
import 'package:pittyf/presentation/screens/event_edit_screen.dart';

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

  Future<void> _refreshEventDetails() {
    setState(() {
      _eventDetailFuture = _eventsApi.getEventById(_eventId!);
    });
    return _eventDetailFuture;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63);
    const Color backgroundColor = Color(0xFFFFF8E1);

    if (_eventId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(title: const Text('Error'), backgroundColor: primaryColor, foregroundColor: Colors.white),
        body: const Center(child: Text('ID de evento no proporcionado.')),
      );
    }

    return FutureBuilder<EventModel>(
      future: _eventDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(backgroundColor: primaryColor, foregroundColor: Colors.white),
            body: const Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text('Error'), backgroundColor: primaryColor, foregroundColor: Colors.white),
            body: Center(child: Text('Error al cargar el evento: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(title: const Text('No Encontrado'), backgroundColor: primaryColor, foregroundColor: Colors.white),
            body: const Center(child: Text('No se encontraron detalles del evento.')),
          );
        }

        final event = snapshot.data!;

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
                  title: Text(event.titulo, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: primaryColor.withAlpha(50)),
                      Positioned(top: -50, left: -50, child: _Circle(color: Colors.white.withAlpha(20), size: 200)),
                      Positioned(bottom: -80, right: -80, child: _Circle(color: Colors.white.withAlpha(25), size: 300)),
                      const Center(
                        child: Icon(Icons.celebration_outlined, color: Colors.white, size: 100),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editEvent(event)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteEvent(event)),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _InfoCard(
                        title: 'Información del Evento',
                        children: [
                          _DetailRow(icon: Icons.person_outline, label: 'Solicitado por', value: event.nombre),
                          _DetailRow(icon: Icons.calendar_today, label: 'Fecha', value: _formatDate(event.fecha)),
                          _DetailRow(icon: Icons.location_on_outlined, label: 'Ubicación', value: event.ubicacion ?? 'N/A'),
                        ],
                      ),
                      if (event.descripcion != null && event.descripcion!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _InfoCard(
                            title: 'Descripción',
                            children: [_DetailRow(icon: Icons.notes_outlined, label: 'Descripción', value: event.descripcion!, isSingle: true)],
                          ),
                        ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Información del Sistema',
                        children: [
                          _DetailRow(icon: Icons.fingerprint, label: 'ID de Evento', value: event.id.toString()),
                          _DetailRow(icon: Icons.calendar_today_outlined, label: 'Fecha de Creación', value: _formatDate(event.createdAt)),
                          _DetailRow(icon: Icons.calendar_today, label: 'Última Actualización', value: _formatDate(event.updatedAt)),
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
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('EEEE, dd MMMM yyyy, hh:mm a', 'es_MX').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void _editEvent(EventModel event) async {
    final result = await Navigator.of(context).pushNamed(EventEditScreen.routeName, arguments: event);
    if (result == true && mounted) {
      _refreshEventDetails();
      ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('Evento actualizado'), backgroundColor: Colors.green));
    }
  }

  void _deleteEvent(EventModel event) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el evento "${event.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      try {
        await _eventsApi.deleteEvent(event.id);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } on DioException catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        String errorMessage = e.response?.data?['message'] ?? 'Error al eliminar el evento.';
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
  final bool isSingle;

  const _DetailRow({required this.icon, required this.label, required this.value, this.isSingle = false});

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
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
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