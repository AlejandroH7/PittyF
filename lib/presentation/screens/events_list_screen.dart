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
    _eventsFuture = _refreshEvents(); // Initialize by calling refresh
  }

  Future<List<EventModel>> _refreshEvents() async {
    final fetchedEvents = await _eventsApi.getAllEvents();
    setState(() {
      fetchedEvents.sort((a, b) {
        // Prioritize updatedAt, then createdAt
        final dateA = DateTime.tryParse(a.updatedAt ?? a.createdAt ?? '');
        final dateB = DateTime.tryParse(b.updatedAt ?? b.createdAt ?? '');

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // Null dates come last
        if (dateB == null) return -1; // Null dates come last

        return dateB.compareTo(dateA); // Descending order (most recent first)
      });
      _eventsFuture = Future.value(
        fetchedEvents,
      ); // Update the future with the fetched data
    });
    return fetchedEvents;
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
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          EventDetailScreen.routeName,
                          arguments: event.id,
                        );
                        if (result == true) {
                          await _refreshEvents(); // Await the refresh
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).pushNamed('/eventos/nuevo');
          if (result == true) {
            await _refreshEvents(); // Await the refresh
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
