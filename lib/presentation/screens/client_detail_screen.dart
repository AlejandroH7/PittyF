import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      _clientId = arg;
      _clientDetailFuture = _clientsApi.getClientById(_clientId!);
    } else if (arg is ClientModel) {
      _clientId = arg.id;
      _clientDetailFuture = Future.value(arg);
    }
  }

  Future<void> _refreshClientDetails() {
    setState(() {
      _clientDetailFuture = _clientsApi.getClientById(_clientId!);
    });
    return _clientDetailFuture;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63);
    const Color backgroundColor = Color(0xFFFFF8E1);

    if (_clientId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('ID de cliente no proporcionado.')),
      );
    }

    return FutureBuilder<ClientModel>(
      future: _clientDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text('Error al cargar el cliente: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('No Encontrado'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('No se encontraron detalles del cliente.'),
            ),
          );
        }

        final client = snapshot.data!;

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
                  title: Text(
                    client.nombre,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: primaryColor.withAlpha(50)),
                      Positioned(
                        top: -50,
                        left: -50,
                        child: _Circle(
                          color: Colors.white.withAlpha(20),
                          size: 200,
                        ),
                      ),
                      Positioned(
                        bottom: -80,
                        right: -80,
                        child: _Circle(
                          color: Colors.white.withAlpha(25),
                          size: 300,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                client.nombre.isNotEmpty
                                    ? client.nombre[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 50,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editClient(client),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteClient(client),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _InfoCard(
                        title: 'Información de Contacto',
                        children: [
                          _DetailRow(
                            icon: Icons.phone,
                            label: 'Teléfono',
                            value: client.telefono ?? 'N/A',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Notas',
                        children: [
                          _DetailRow(
                            icon: Icons.notes,
                            label: 'Notas',
                            value: client.notas ?? 'Sin notas',
                            isSingle: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Información del Sistema',
                        children: [
                          _DetailRow(
                            icon: Icons.fingerprint,
                            label: 'ID de Cliente',
                            value: client.id.toString(),
                          ),
                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Creado por',
                            value: client.createdBy ?? 'N/A',
                          ),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Fecha de Creación',
                            value: _formatDate(client.createdAt),
                          ),
                          _DetailRow(
                            icon: Icons.person,
                            label: 'Actualizado por',
                            value: client.updatedBy ?? 'N/A',
                          ),
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Última Actualización',
                            value: _formatDate(client.updatedAt),
                          ),
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
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  void _editClient(ClientModel client) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/clientes/editar', arguments: client);
    if (result == true && mounted) {
      _refreshClientDetails();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Cliente actualizado'),
            backgroundColor: Colors.green,
          ),
        );
    }
  }

  void _deleteClient(ClientModel client) async {
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
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete == true && mounted) {
      try {
        await _clientsApi.deleteClient(client.id);
        if (mounted) {
          Navigator.of(
            context,
          ).pop(true); // Pop back to list and indicate success
        }
      } on DioException catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        String errorMessage =
            e.response?.data?['message'] ?? 'Error al eliminar cliente.';
        messenger.showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } catch (e) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Un error inesperado ocurrió: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
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

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isSingle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
            isSingle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSingle)
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                if (!isSingle) const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
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
