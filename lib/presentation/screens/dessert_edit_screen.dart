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
    _nombreController = TextEditingController();
    _precioController = TextEditingController();
    _porcionesController = TextEditingController();
    _activo = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dessert = ModalRoute.of(context)?.settings.arguments as DessertModel?;
    if (dessert != null) {
      _initialDessert = dessert;
      _nombreController.text = _initialDessert.nombre;
      _precioController.text = _initialDessert.precio.toString();
      _porcionesController.text = _initialDessert.porciones.toString();
      _activo = _initialDessert.activo;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se proporcionaron datos del postre.'), backgroundColor: Colors.red),
          );
          Navigator.of(context).pop();
        }
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
      setState(() => _isLoading = true);

      final dessertRequest = DessertRequestModel(
        nombre: _nombreController.text,
        precio: double.parse(_precioController.text),
        porciones: int.parse(_porcionesController.text),
        activo: _activo,
      );

      try {
        await _dessertsApi.updateDessert(_initialDessert.id, dessertRequest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Postre actualizado exitosamente!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        }
      } on DioException catch (e) {
        if (mounted) {
          String errorMessage = 'Error al actualizar el postre.';
          if (e.response?.statusCode == 409) {
            errorMessage = 'Este postre no se puede editar porque pertenece a un pedido.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.red),
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
        title: const Text('Editar Postre', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
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
                  label: 'Nombre del Postre',
                  icon: Icons.cake_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa el nombre';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _precioController,
                  label: 'Precio',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa el precio';
                    if (double.tryParse(value) == null || double.parse(value) <= 0) return 'El precio debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _porcionesController,
                  label: 'Porciones',
                  icon: Icons.pie_chart_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa las porciones';
                    if (int.tryParse(value) == null || int.parse(value) < 1) return 'Las porciones deben ser al menos 1';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSwitchTile(),
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
                          onPressed: _updateDessert,
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

  Widget _buildSwitchTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: SwitchListTile(
        title: const Text('Postre Activo', style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(_activo ? 'Visible para pedidos' : 'Oculto para pedidos', style: const TextStyle(color: Colors.grey)),
        value: _activo,
        onChanged: (bool value) => setState(() => _activo = value),
        activeColor: const Color(0xFFE91E63),
        secondary: const Icon(Icons.visibility_outlined, color: Color(0xFFE91E63)),
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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