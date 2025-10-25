import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/client_model.dart';
import 'package:pittyf/data/models/dessert_model.dart';
import 'package:pittyf/data/models/pedido_completo_create_request_model.dart';
import 'package:pittyf/data/services/clients_api.dart';
import 'package:pittyf/data/services/desserts_api.dart';
import 'package:pittyf/data/services/pedido_completo_api.dart';

// Helper class to hold data for dropdowns
class _FormData {
  final List<ClientModel> clients;
  final List<DessertModel> desserts;
  _FormData(this.clients, this.desserts);
}

class PedidoCompletoFormScreen extends StatefulWidget {
  const PedidoCompletoFormScreen({super.key});

  static const String routeName = '/pedidos-completos/nuevo';

  @override
  State<PedidoCompletoFormScreen> createState() => _PedidoCompletoFormScreenState();
}

class _PedidoCompletoFormScreenState extends State<PedidoCompletoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  Future<_FormData> _loadFormData() async {
    final results = await Future.wait([
      ClientsApi().getAllClients(),
      DessertsApi().getAllDesserts(),
    ]);
    return _FormData(results[0] as List<ClientModel>, results[1] as List<DessertModel>);
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
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _savePedido() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione una fecha de entrega.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final requestModel = PedidoCompletoCreateRequestModel(
      clienteId: _selectedClientId!,
      postreId: _selectedPostre!.id,
      nota: _notaController.text.isNotEmpty ? _notaController.text : null,
      cantidad: int.parse(_cantidadController.text),
      total: double.parse(_totalController.text),
      fechaEntrega: _selectedDate!.toUtc().toIso8601String(),
    );

    try {
      await PedidoCompletoApi().createPedidoCompleto(requestModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido creado exitosamente!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el pedido: $e')), 
        );
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
      appBar: AppBar(
        title: const Text('Crear Pedido'),
      ),
      body: FutureBuilder<_FormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se pudieron cargar los datos.'));
          }

          final formData = snapshot.data!;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _selectedClientId,
                  decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder()),
                  items: formData.clients.map((client) {
                    return DropdownMenuItem<int>(value: client.id, child: Text(client.nombre));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedClientId = value),
                  validator: (value) => value == null ? 'Seleccione un cliente' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DessertModel>(
                  initialValue: _selectedPostre,
                  decoration: const InputDecoration(labelText: 'Postre', border: OutlineInputBorder()),
                  items: formData.desserts.map((dessert) {
                    return DropdownMenuItem<DessertModel>(value: dessert, child: Text(dessert.nombre));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPostre = value;
                      _calculateTotal();
                      // Re-validate the quantity field when the dessert changes
                      _formKey.currentState?.validate();
                    });
                  },
                  validator: (value) => value == null ? 'Seleccione un postre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese una cantidad';
                    final cantidad = int.tryParse(value);
                    if (cantidad == null || cantidad <= 0) return 'Debe ser un número positivo';
                    if (_selectedPostre != null && cantidad > _selectedPostre!.porciones) {
                      return 'Stock insuficiente. Disponibles: ${_selectedPostre!.porciones}';
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
                  decoration: const InputDecoration(labelText: 'Nota (Opcional)', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.grey)),
                  title: Text(_selectedDate == null ? 'Seleccionar Fecha y Hora de Entrega' : DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _savePedido,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Guardar Pedido'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
