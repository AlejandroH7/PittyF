import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/event_model.dart';
import 'package:pittyf/data/services/events_api.dart';
import 'package:pittyf/presentation/screens/event_form_screen.dart';

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
    _eventsFuture = _getSortedEvents();
  }

  Future<List<EventModel>> _getSortedEvents() async {
    final events = await _eventsApi.getAllEvents();
    events.sort((a, b) {
      final dateA = DateTime.tryParse(a.fecha);
      final dateB = DateTime.tryParse(b.fecha);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // Sort by event date, most recent first
    });
    return events;
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _eventsFuture = _getSortedEvents();
    });
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
          'Eventos',
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
          FutureBuilder<List<EventModel>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (snapshot.hasError) {
                return _ErrorState(
                  errorMessage: snapshot.error.toString(),
                  onRetry: _refreshEvents,
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _EmptyState(onRefresh: _navigateAndRefresh);
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshEvents,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final event = snapshot.data![index];
                      return _EventCard(
                        event: event,
                        onTapped: () => _navigateToDetail(event.id),
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
        onPressed: _navigateAndRefresh,
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _navigateToDetail(int eventId) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/eventos/detalle', arguments: eventId);
    if (result == true) {
      _refreshEvents();
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(EventFormScreen.routeName);
    if (result == true) {
      _refreshEvents();
    }
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTapped;

  const _EventCard({required this.event, required this.onTapped});

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a', 'es_MX').format(dateTime);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTapped,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE91E63).withAlpha(30),
                    child: const Icon(
                      Icons.celebration_outlined,
                      color: Color(0xFFE91E63),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              _InfoRow(
                icon: Icons.person_outline,
                title: 'Solicitado por:',
                value: event.nombre,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                title: 'Fecha:',
                value: _formatDate(event.fecha),
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.location_on_outlined,
                title: 'Ubicación:',
                value: event.ubicacion ?? 'No especificada',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text('$title ', style: TextStyle(color: Colors.grey[700])),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Color(0xFF333333),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorState({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Ocurrió un error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay eventos registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Evento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
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
