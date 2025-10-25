import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    _dessertsFuture = _getSortedDesserts();
  }

  Future<List<DessertModel>> _getSortedDesserts() async {
    final desserts = await _dessertsApi.getAllDesserts();
    desserts.sort((a, b) {
      final dateA = DateTime.tryParse(a.updatedAt ?? a.createdAt ?? '');
      final dateB = DateTime.tryParse(b.updatedAt ?? b.createdAt ?? '');
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return desserts;
  }

  Future<void> _refreshDesserts() async {
    setState(() {
      _dessertsFuture = _getSortedDesserts();
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
          'Postres',
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
          FutureBuilder<List<DessertModel>>(
            future: _dessertsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (snapshot.hasError) {
                return _ErrorState(
                  errorMessage: snapshot.error.toString(),
                  onRetry: _refreshDesserts,
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _EmptyState(onRefresh: _refreshDesserts);
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshDesserts,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final dessert = snapshot.data![index];
                      return _DessertCard(
                        dessert: dessert,
                        onTapped: () => _navigateToDetail(dessert.id),
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

  void _navigateToDetail(int dessertId) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/postres/detalle', arguments: dessertId);
    if (result == true) {
      _refreshDesserts();
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.of(context).pushNamed('/postres/nuevo');
    if (result == true) {
      _refreshDesserts();
    }
  }
}

class _DessertCard extends StatelessWidget {
  final DessertModel dessert;
  final VoidCallback onTapped;

  const _DessertCard({required this.dessert, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'es_MX',
      decimalDigits: 2,
    );

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
                child: const Icon(
                  Icons.cake_outlined,
                  color: Color(0xFFE91E63),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dessert.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatCurrency.format(dessert.precio),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.pie_chart_outline,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${dessert.porciones} porciones',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[800],
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
          const Icon(Icons.cake_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay postres registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Postre'),
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
