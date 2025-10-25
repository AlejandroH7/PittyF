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
      _event = ModalRoute.of(context)?.settings.arguments as EventModel?;
      if (_event != null) {
        _populateForm(_event!);
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
          content: Text(
            'Por favor, seleccione una fecha y hora para el evento.',
          ),
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
      descripcion:
          _descripcionController.text.isNotEmpty
              ? _descripcionController.text
              : null,
      ubicacion:
          _ubicacionController.text.isNotEmpty
              ? _ubicacionController.text
              : null,
    );

    try {
      await EventsApi().updateEvent(_event!.id, requestModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento actualizado exitosamente!')),
        );
        Navigator.of(context).pop(true); // Indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el evento: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese el título del evento';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese el nombre del evento';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
                title: Text(
                  _selectedDate == null
                      ? 'Seleccionar Fecha y Hora'
                      : DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _updateEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Actualizar Evento'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
