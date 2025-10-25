import 'package:flutter/material.dart';
import 'package:pittyf/data/models/dessert_model.dart';
import 'package:pittyf/data/services/desserts_api.dart';

class DessertsListScreen extends StatefulWidget {
  const DessertsListScreen({super.key});

  static const String routeName = '/postres';

  @override
  State<DessertsListScreen> createState() => _DessertsListScreenState();
}

class _DessertsListScreenState extends State<DessertsListScreen> {
  late Future<List<DessertModel>> _dessertsFuture;
  final DessertsApi _dessertsApi = DessertsApi();

  @override
  void initState() {
    super.initState();
    _dessertsFuture = _dessertsApi.getAllDesserts();
  }

  Future<void> _refreshDesserts() async {
    setState(() {
      _dessertsFuture = _dessertsApi.getAllDesserts().then((desserts) {
        desserts.sort((a, b) {
          // Prioritize updatedAt, then createdAt
          final dateA = DateTime.tryParse(a.updatedAt ?? a.createdAt ?? '');
          final dateB = DateTime.tryParse(b.updatedAt ?? b.createdAt ?? '');

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // Null dates come last
          if (dateB == null) return -1; // Null dates come last

          return dateB.compareTo(dateA); // Descending order (most recent first)
        });
        return desserts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Postres'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DessertModel>>(
        future: _dessertsFuture,
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
                    onPressed: _refreshDesserts,
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
                  const Text('No hay postres disponibles.'),
                  ElevatedButton(
                    onPressed: _refreshDesserts,
                    child: const Text('Recargar'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshDesserts,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final dessert = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    elevation: 2,
                    child: ListTile(
                      title: Text(dessert.nombre),
                      subtitle: Text('Precio: \$${dessert.precio.toStringAsFixed(2)} - Porciones: ${dessert.porciones}'),
                      trailing: Text('ID: ${dessert.id}'),
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          '/postres/detalle',
                          arguments: dessert.id, // Pass the dessert ID
                        );
                        if (result == true) {
                          _refreshDesserts(); // Refresh desserts if an edit was successful
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
          final result = await Navigator.of(context).pushNamed('/postres/nuevo');
          if (result == true) {
            _refreshDesserts(); // Refresh desserts if a new one was added
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
