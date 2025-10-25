import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pittyf/data/models/client_request_model.dart';
import 'package:pittyf/data/services/clients_api.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key});

  static const String routeName = '/clientes/nuevo';

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _notasController = TextEditingController();
  final ClientsApi _clientsApi = ClientsApi();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final clientRequest = ClientRequestModel(
        nombre: _nombreController.text,
        telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
        notas: _notasController.text.isNotEmpty ? _notasController.text : null,
      );

      try {
        await _clientsApi.createClient(clientRequest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente creado exitosamente!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear cliente: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
        title: const Text('Nuevo Cliente', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
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
                  controller: _nombreController,
                  label: 'Nombre',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
                    if (value.length > 120) return 'El nombre no debe exceder 120 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(30)],
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _notasController,
                  label: 'Notas',
                  icon: Icons.notes_outlined,
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
                          onPressed: _saveClient,
                          label: const Text('Guardar'),
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