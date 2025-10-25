import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/client_model.dart';
import 'package:pittyf/data/models/dessert_model.dart';
import 'package:pittyf/data/models/pedido_completo_model.dart';
import 'package:pittyf/data/models/pedido_completo_update_request_model.dart';
import 'package:pittyf/data/services/clients_api.dart';
import 'package:pittyf/data/services/desserts_api.dart';
import 'package:pittyf/data/services/pedido_completo_api.dart';

class _FormData {
  final List<ClientModel> clients;
  final List<DessertModel> desserts;
  _FormData(this.clients, this.desserts);
}

class PedidoCompletoEditScreen extends StatefulWidget {
  const PedidoCompletoEditScreen({super.key});

  static const String routeName = '/pedidos-completos/editar';

  @override
  State<PedidoCompletoEditScreen> createState() =>
      _PedidoCompletoEditScreenState();
}

class _PedidoCompletoEditScreenState extends State<PedidoCompletoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  PedidoCompletoModel? _pedido;

  // Form field values
  int? _selectedClientId;
  DessertModel? _selectedPostre;
  DateTime? _selectedDate;
  final _notaController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _totalController = TextEditingController();

  late Future<_FormData> _formDataFuture;

  @override
  void initState() {
    super.initState();
    _formDataFuture = _loadFormData();
    _cantidadController.addListener(_calculateTotal);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pedido == null) {
      _pedido =
          ModalRoute.of(context)?.settings.arguments as PedidoCompletoModel?;
      if (_pedido != null) {
        _populateForm(_pedido!);
      }
    }
  }

  void _populateForm(PedidoCompletoModel pedido) {
    _selectedClientId = pedido.clienteId;
    // Note: We need to find the full DessertModel object from the list later
    _notaController.text = pedido.nota ?? '';
    _cantidadController.text = pedido.cantidad.toString();
    _totalController.text = pedido.total.toStringAsFixed(2);
    _selectedDate = DateTime.tryParse(pedido.fechaEntrega)?.toLocal();
  }

  Future<_FormData> _loadFormData() async {
    final results = await Future.wait([
      ClientsApi().getAllClients(),
      DessertsApi().getAllDesserts(),
    ]);
    return _FormData(
      results[0] as List<ClientModel>,
      results[1] as List<DessertModel>,
    );
  }

  @override
  void dispose() {
    _notaController.dispose();
    _cantidadController.removeListener(_calculateTotal);
    _cantidadController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_selectedPostre != null && _cantidadController.text.isNotEmpty) {
      final cantidad = int.tryParse(_cantidadController.text);
      if (cantidad != null && cantidad > 0) {
        final total = cantidad * _selectedPostre!.precio;
        _totalController.text = total.toStringAsFixed(2);
      } else {
        _totalController.text = '0.00';
      }
    } else {
      _totalController.text = '0.00';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // ... (same as form screen)
  }

  Future<void> _updatePedido() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una fecha')));
      return;
    }

    setState(() => _isLoading = true);

    final requestModel = PedidoCompletoUpdateRequestModel(
      clienteId: _selectedClientId!,
      postreId: _selectedPostre!.id,
      nota: _notaController.text.isNotEmpty ? _notaController.text : null,
      cantidad: int.parse(_cantidadController.text),
      total: double.parse(_totalController.text),
      fechaEntrega: _selectedDate!.toUtc().toIso8601String(),
    );

    try {
      await PedidoCompletoApi().updatePedidoCompleto(_pedido!.id, requestModel);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pedido actualizado!')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Pedido')),
      body: FutureBuilder<_FormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final formData = snapshot.data!;
          // Find the initial selected postre object
          if (_selectedPostre == null && _pedido != null) {
            _selectedPostre = formData.desserts.firstWhere(
              (d) => d.id == _pedido!.postreId,
              orElse: () => formData.desserts.first,
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedClientId,
                  items:
                      formData.clients
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.nombre),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedClientId = v),
                  validator: (v) => v == null ? 'Seleccione un cliente' : null,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DessertModel>(
                  value: _selectedPostre,
                  items:
                      formData.desserts
                          .map(
                            (d) => DropdownMenuItem<DessertModel>(
                              value: d,
                              child: Text(d.nombre),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedPostre = v;
                      _calculateTotal();
                      _formKey.currentState?.validate();
                    });
                  },
                  validator: (v) => v == null ? 'Seleccione un postre' : null,
                  decoration: const InputDecoration(
                    labelText: 'Postre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Ingrese una cantidad';
                    final cantidad = int.tryParse(value);
                    if (cantidad == null || cantidad <= 0)
                      return 'Debe ser un número positivo';

                    if (_selectedPostre != null && _pedido != null) {
                      // Calculate effective available stock: current stock + quantity of this specific pedido
                      final effectiveAvailableStock =
                          _selectedPostre!.porciones + _pedido!.cantidad;
                      if (cantidad > effectiveAvailableStock) {
                        return 'Stock insuficiente. Disponibles: ${effectiveAvailableStock}';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    border: OutlineInputBorder(),
                    fillColor: Colors.black12,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notaController,
                  decoration: const InputDecoration(
                    labelText: 'Nota',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  title: Text(
                    _selectedDate == null
                        ? 'Seleccionar Fecha'
                        : DateFormat(
                          'dd/MM/yyyy hh:mm a',
                        ).format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _updatePedido,
                      child: const Text('Actualizar Pedido'),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
