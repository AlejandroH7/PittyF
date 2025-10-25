import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pittyf/data/models/event_model.dart';
import 'package:pittyf/data/models/event_update_request_model.dart';
import 'package:pittyf/data/services/events_api.dart';

class EventEditScreen extends StatefulWidget {
  const EventEditScreen({super.key});

  static const String routeName = '/eventos/editar';

  @override
  State<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  EventModel? _event;

  final _nombreController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_event == null) {
      final event = ModalRoute.of(context)?.settings.arguments as EventModel?;
      if (event != null) {
        _event = event;
        _populateForm(event);
      }
    }
  }

  void _populateForm(EventModel event) {
    _nombreController.text = event.nombre;
    _tituloController.text = event.titulo;
    _descripcionController.text = event.descripcion ?? '';
    _ubicacionController.text = event.ubicacion ?? '';
    _selectedDate = DateTime.tryParse(event.fecha)?.toLocal();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
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

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione una fecha y hora para el evento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final requestModel = EventUpdateRequestModel(
      nombre: _nombreController.text,
      titulo: _tituloController.text,
      fecha: _selectedDate!.toUtc().toIso8601String(),
      descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
      ubicacion: _ubicacionController.text.isNotEmpty ? _ubicacionController.text : null,
    );

    try {
      await EventsApi().updateEvent(_event!.id, requestModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento actualizado exitosamente!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el evento: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('Editar Evento', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: _Circle(color: primaryColor.withAlpha(10), size: 300)),
          Positioned(bottom: -150, left: -150, child: _Circle(color: primaryColor.withAlpha(15), size: 400)),
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _tituloController,
                  label: 'Título del Evento',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el título del evento';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _nombreController,
                  label: 'Evento solicitado por',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el nombre del cliente';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildDatePickerField(),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _ubicacionController,
                  label: 'Ubicación (Opcional)',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _descripcionController,
                  label: 'Descripción (Opcional)',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
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
                          onPressed: _updateEvent,
                          label: const Text('Guardar Cambios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            elevation: 8,
                          ),
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
      ),
    );
  }

  Widget _buildDatePickerField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha y Hora del Evento',
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
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
        fillColor: Colors.white,
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