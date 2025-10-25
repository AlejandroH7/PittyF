import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pittyf/data/models/client_model.dart';
import 'package:pittyf/data/models/client_request_model.dart';
import 'package:pittyf/data/services/clients_api.dart';

class ClientEditScreen extends StatefulWidget {
  const ClientEditScreen({super.key});

  static const String routeName = '/clientes/editar';

  @override
  State<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _notasController;
  final ClientsApi _clientsApi = ClientsApi();
  bool _isLoading = false;
  late ClientModel _initialClient;

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in didChangeDependencies once arguments are available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments != null) {
      _initialClient =
          ModalRoute.of(context)?.settings.arguments as ClientModel;
      _nombreController = TextEditingController(text: _initialClient.nombre);
      _telefonoController = TextEditingController(
        text: _initialClient.telefono,
      );
      _notasController = TextEditingController(text: _initialClient.notas);
    } else {
      // Handle error: no client data provided
      _nombreController = TextEditingController();
      _telefonoController = TextEditingController();
      _notasController = TextEditingController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: No se proporcionaron datos del cliente para editar.',
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
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _updateClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final clientRequest = ClientRequestModel(
        nombre: _nombreController.text,
        telefono:
            _telefonoController.text.isNotEmpty
                ? _telefonoController.text
                : null,
        notas: _notasController.text.isNotEmpty ? _notasController.text : null,
      );

      try {
        await _clientsApi.updateClient(_initialClient.id, clientRequest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente actualizado exitosamente!')),
          );
          Navigator.of(
            context,
          ).pop(true); // Pop with true to indicate success and trigger refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar cliente: $e')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
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
                  if (value.length > 120) {
                    return 'El nombre no debe exceder 120 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  LengthLimitingTextInputFormatter(
                    30,
                  ), // Limit length to 30 characters
                ],
                validator: (value) {
                  if (value != null && value.length > 30) {
                    return 'El teléfono no debe exceder 30 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateClient,
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
