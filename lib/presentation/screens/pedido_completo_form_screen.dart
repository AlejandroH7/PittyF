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

  int? _selectedClientId;
  DessertModel? _selectedDessert;
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
    final results = await Future.wait([ClientsApi().getAllClients(), DessertsApi().getAllDesserts()]);
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
    if (_selectedDessert != null && _cantidadController.text.isNotEmpty) {
      final cantidad = int.tryParse(_cantidadController.text);
      if (cantidad != null && cantidad > 0) {
        _totalController.text = (cantidad * _selectedDessert!.precio).toStringAsFixed(2);
      } else {
        _totalController.text = '0.00';
      }
    } else {
      _totalController.text = '0.00';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Future<void> _savePedido() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, seleccione una fecha de entrega.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final requestModel = PedidoCompletoCreateRequestModel(
      clienteId: _selectedClientId!,
      postreId: _selectedDessert!.id,
      nota: _notaController.text.isNotEmpty ? _notaController.text : null,
      cantidad: int.parse(_cantidadController.text),
      total: double.parse(_totalController.text),
      fechaEntrega: _selectedDate!.toUtc().toIso8601String(),
    );

    try {
      await PedidoCompletoApi().createPedidoCompleto(requestModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido creado exitosamente!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear el pedido: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63);
    const Color backgroundColor = Color(0xFFFFF8E1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Nuevo Pedido', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<_FormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se pudieron cargar los datos.'));
          }

          final formData = snapshot.data!;

          return Stack(
            children: [
              Positioned(top: -100, right: -100, child: _Circle(color: primaryColor.withAlpha(10), size: 300)),
              Positioned(bottom: -150, left: -150, child: _Circle(color: primaryColor.withAlpha(15), size: 400)),
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildDropdownFormField<int>(
                      value: _selectedClientId,
                      items: formData.clients.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.nombre))).toList(),
                      onChanged: (v) => setState(() => _selectedClientId = v),
                      label: 'Cliente',
                      icon: Icons.person_outline,
                      validator: (v) => v == null ? 'Seleccione un cliente' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownFormField<DessertModel>(
                      value: _selectedDessert,
                      items: formData.desserts.map((p) => DropdownMenuItem<DessertModel>(value: p, child: Text(p.nombre))).toList(),
                      onChanged: (v) => setState(() {
                        _selectedDessert = v;
                        _calculateTotal();
                        _formKey.currentState?.validate();
                      }),
                      label: 'Postre',
                      icon: Icons.cake_outlined,
                      validator: (v) => v == null ? 'Seleccione un postre' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _cantidadController,
                      label: 'Cantidad',
                      icon: Icons.shopping_bag_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese una cantidad';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Debe ser > 0';
                        if (_selectedDessert != null && n > _selectedDessert!.porciones) return 'Stock: ${_selectedDessert!.porciones}';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _totalController,
                      label: 'Total',
                      icon: Icons.attach_money,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _notaController,
                      label: 'Notas (Opcional)',
                      icon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePickerField(),
                    const SizedBox(height: 32),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: primaryColor))
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save_alt_outlined),
                              onPressed: _savePedido,
                              label: const Text('Guardar Pedido'),
                              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Entrega',
          prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFE91E63)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate == null ? 'Toca para seleccionar' : DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate!),
          style: TextStyle(fontSize: 16, color: _selectedDate == null ? Colors.grey[600] : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String label,
    required IconData icon,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2.0),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
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