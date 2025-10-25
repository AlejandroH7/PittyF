import 'package:flutter/material.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  static const String routeName = '/inicio';

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63); // A lovely pink
    const Color backgroundColor = Color(0xFFFFF8E1); // A warm cream color

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            left: -100,
            child: Circle(color: primaryColor.withOpacity(0.1), size: 300),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Circle(color: primaryColor.withOpacity(0.15), size: 400),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo with a subtle shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/pitty_logo.png',
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Welcome Text
                    Text(
                      'Bienvenido a Pitty',
                      style: TextStyle(
                        fontFamily: 'Georgia', // A more elegant, classic font
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFAD1457), // Darker pink shade
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tu pastelería de confianza',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/menu');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0), // More rounded
                          ),
                          elevation: 8,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: const Text(
                          'Iniciar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for decorative circles
class Circle extends StatelessWidget {
  final Color color;
  final double size;

  const Circle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}