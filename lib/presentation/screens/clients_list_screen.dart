import 'package:flutter/material.dart';
import 'package:pittyf/data/models/client_model.dart';
import 'package:pittyf/data/services/clients_api.dart';
import 'package:pittyf/presentation/screens/client_form_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  static const String routeName = '/clientes';

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  late Future<List<ClientModel>> _clientsFuture;
  final ClientsApi _clientsApi = ClientsApi();

  @override
  void initState() {
    super.initState();
    _clientsFuture = _getSortedClients();
  }

  Future<List<ClientModel>> _getSortedClients() async {
    final clients = await _clientsApi.getAllClients();
    clients.sort((a, b) {
      final dateA = DateTime.tryParse(a.updatedAt ?? a.createdAt ?? '');
      final dateB = DateTime.tryParse(b.updatedAt ?? b.createdAt ?? '');
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return clients;
  }

  Future<void> _refreshClients() async {
    setState(() {
      _clientsFuture = _getSortedClients();
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
          'Clientes',
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
          FutureBuilder<List<ClientModel>>(
            future: _clientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (snapshot.hasError) {
                return _ErrorState(
                  errorMessage: snapshot.error.toString(),
                  onRetry: _refreshClients,
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _EmptyState(onRefresh: _refreshClients);
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshClients,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final client = snapshot.data![index];
                      return _ClientCard(
                        client: client,
                        onTapped: () => _navigateToDetail(client.id),
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

  void _navigateToDetail(int clientId) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/clientes/detalle', arguments: clientId);
    if (result == true) {
      _refreshClients();
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(ClientFormScreen.routeName);
    if (result == true) {
      _refreshClients();
    }
  }
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onTapped;

  const _ClientCard({required this.client, required this.onTapped});

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
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE91E63).withAlpha(30),
                child: Text(
                  client.nombre.isNotEmpty
                      ? client.nombre[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          client.telefono ?? 'Sin teléfono',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
            ],
          ),
        ),
      ),
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
          const Icon(Icons.people_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay clientes registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Cliente'),
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
