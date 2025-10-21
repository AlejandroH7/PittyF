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
    _clientsFuture = _clientsApi.getAllClients();
  }

  Future<void> _refreshClients() async {
    setState(() {
      _clientsFuture = _clientsApi.getAllClients().then((clients) {
        clients.sort((a, b) {
          // Prioritize updatedAt, then createdAt
          final dateA = DateTime.tryParse(a.updatedAt ?? a.createdAt ?? '');
          final dateB = DateTime.tryParse(b.updatedAt ?? b.createdAt ?? '');

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // Null dates come last
          if (dateB == null) return -1; // Null dates come last

          return dateB.compareTo(dateA); // Descending order (most recent first)
        });
        return clients;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ClientModel>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _refreshClients,
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
                  const Text('No hay clientes disponibles.'),
                  ElevatedButton(
                    onPressed: _refreshClients,
                    child: const Text('Recargar'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshClients,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final client = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        client.nombre,
                      ), // Assuming nombre is always non-null as per backend @NotBlank
                      subtitle: Text(
                        client.telefono ?? 'N/A',
                      ), // Handle nullable telefono
                      trailing: Text('ID: ${client.id}'),
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          '/clientes/detalle',
                          arguments: client.id, // Pass the client ID
                        );
                        if (result == true) {
                          _refreshClients(); // Refresh clients if an edit was successful
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
          ).pushNamed(ClientFormScreen.routeName);
          if (result == true) {
            _refreshClients(); // Refresh clients if a new one was added
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
