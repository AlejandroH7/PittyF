import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pittyf/data/models/dessert_model.dart';
import 'package:pittyf/data/models/dessert_request_model.dart';
import 'package:pittyf/data/services/desserts_api.dart';

class DessertEditScreen extends StatefulWidget {
  const DessertEditScreen({super.key});

  static const String routeName = '/postres/editar';

  @override
  State<DessertEditScreen> createState() => _DessertEditScreenState();
}

class _DessertEditScreenState extends State<DessertEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _porcionesController;
  late bool _activo;
  final DessertsApi _dessertsApi = DessertsApi();
  bool _isLoading = false;
  late DessertModel _initialDessert;

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in didChangeDependencies once arguments are available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments != null) {
      _initialDessert =
          ModalRoute.of(context)?.settings.arguments as DessertModel;
      _nombreController = TextEditingController(text: _initialDessert.nombre);
      _precioController = TextEditingController(
        text: _initialDessert.precio.toString(),
      );
      _porcionesController = TextEditingController(
        text: _initialDessert.porciones.toString(),
      );
      _activo = _initialDessert.activo;
    } else {
      // Handle error: no dessert data provided
      _nombreController = TextEditingController();
      _precioController = TextEditingController();
      _porcionesController = TextEditingController();
      _activo = true; // Default value if no initial data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: No se proporcionaron datos del postre para editar.',
            ),
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _porcionesController.dispose();
    super.dispose();
  }

  Future<void> _updateDessert() async {
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
      final messenger = ScaffoldMessenger.of(
        context,
      ); // Capture ScaffoldMessenger before async gap

      try {
        await _dessertsApi.updateDessert(_initialDessert.id, dessertRequest);
        if (!mounted) return; // Check mounted after async gap
        messenger.showSnackBar(
          const SnackBar(content: Text('Postre actualizado exitosamente!')),
        );
        success = true;
      } on DioException catch (e) {
        // Catch DioException specifically
        if (!mounted) return; // Check mounted after async gap
        // print('DioException caught: ${e.runtimeType}, Status Code: ${e.response?.statusCode}, Message: ${e.message}'); // Log details removed
        if (e.response?.statusCode == 409) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Este postre no se puede editar porque pertenece a un pedido.',
              ),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text('Error al actualizar postre: ${e.message}')),
          );
        }
      } catch (e) {
        if (!mounted) return; // Check mounted after async gap
        // print('Unexpected error caught: ${e.runtimeType}, Message: $e'); // Log details removed
        messenger.showSnackBar(
          SnackBar(content: Text('Error inesperado al actualizar postre: $e')),
        );
      } finally {
        if (!mounted) return; // Check mounted after async gap
        setState(() {
          _isLoading = false;
        });
        if (success) {
          nav.pop(
            true,
          ); // Pop with true to indicate success and trigger refresh
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Postre'),
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
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}$'),
                  ), // Allow decimal with 2 places
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
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
                      onPressed: _updateDessert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Guardar Cambios',
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
                    Navigator.of(
                      context,
                    ).pop(false); // Pop with false to indicate cancellation
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
