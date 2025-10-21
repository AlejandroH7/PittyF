import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pittyf/data/models/dessert_request_model.dart';
import 'package:pittyf/data/services/desserts_api.dart';

class DessertFormScreen extends StatefulWidget {
  const DessertFormScreen({super.key});

  static const String routeName = '/postres/nuevo';

  @override
  State<DessertFormScreen> createState() => _DessertFormScreenState();
}

class _DessertFormScreenState extends State<DessertFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _porcionesController = TextEditingController();
  bool _activo = true; // Default to true as per backend @NotNull
  final DessertsApi _dessertsApi = DessertsApi();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _porcionesController.dispose();
    super.dispose();
  }

  Future<void> _saveDessert() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final dessertRequest = DessertRequestModel(
        nombre: _nombreController.text,
        precio: double.parse(_precioController.text),
        porciones: int.parse(_porcionesController.text),
        activo: _activo,
      );

      bool success = false;
      final nav = Navigator.of(context); // Capture Navigator before async gap
      final messenger = ScaffoldMessenger.of(context); // Capture ScaffoldMessenger before async gap

      try {
        await _dessertsApi.createDessert(dessertRequest);
        if (!mounted) return; // Check mounted after async gap
        messenger.showSnackBar(
          const SnackBar(content: Text('Postre creado exitosamente!')),
        );
        success = true;
      } catch (e) {
        if (!mounted) return; // Check mounted after async gap
        messenger.showSnackBar(
          SnackBar(content: Text('Error al crear postre: $e')),
        );
      } finally {
        if (!mounted) return; // Check mounted after async gap
        setState(() {
          _isLoading = false;
        });
        if (success) {
          nav.pop(true); // Pop with true to indicate success and trigger refresh
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Postre'),
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
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')), // Allow decimal with 2 places
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'El precio debe ser un número mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _porcionesController,
                decoration: const InputDecoration(
                  labelText: 'Porciones',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa las porciones';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Las porciones deben ser al menos 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (bool value) {
                  setState(() {
                    _activo = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDessert,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Guardar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Pop with false to indicate cancellation
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}