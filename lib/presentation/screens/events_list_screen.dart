import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/event_model.dart';
import 'package:pittyf/data/services/events_api.dart';
import 'package:pittyf/presentation/screens/event_detail_screen.dart'
    show EventDetailScreen;

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  static const String routeName = '/eventos';

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  late Future<List<EventModel>> _eventsFuture;
  final EventsApi _eventsApi = EventsApi();

  @override
  void initState() {
    super.initState();
    _eventsFuture = _eventsApi.getAllEvents();
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _eventsFuture = _eventsApi.getAllEvents();
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
        title: const Text('Lista de Eventos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _eventsFuture,
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
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _refreshEvents,
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
                  const Text('No hay eventos disponibles.'),
                  ElevatedButton(
                    onPressed: _refreshEvents,
                    child: const Text('Recargar'),
                  ),
                ],
              ),
            );
          } else {
            final events = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshEvents,
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(event.titulo),
                      subtitle: Text(
                        '${event.nombre} - ${_formatDate(event.fecha)} - ${event.ubicacion ?? 'N/A'}',
                      ),
                      trailing: Text('ID: ${event.id}'),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          EventDetailScreen.routeName,
                          arguments: event.id,
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
          final result = await Navigator.of(
            context,
          ).pushNamed('/eventos/nuevo');
          if (result == true) {
            _refreshEvents();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
