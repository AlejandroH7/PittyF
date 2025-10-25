import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const String routeName = '/menu';

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFE91E63); // Pink
    const Color backgroundColor = Color(0xFFFFF8E1); // Cream

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Menú Principal',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Stack(
        children: [
          // Decorative background
          Positioned(
            top: -100,
            right: -100,
            child: Circle(color: primaryColor.withAlpha(10), size: 300),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Circle(color: primaryColor.withAlpha(15), size: 400),
          ),
          // Grid Menu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: <Widget>[
                _MenuCard(
                  title: 'Clientes',
                  icon: Icons.people_outline,
                  onTap: () => Navigator.of(context).pushNamed('/clientes'),
                  color: primaryColor,
                ),
                _MenuCard(
                  title: 'Postres',
                  icon: Icons.cake_outlined,
                  onTap: () => Navigator.of(context).pushNamed('/postres'),
                  color: primaryColor,
                ),
                _MenuCard(
                  title: 'Pedidos',
                  icon: Icons.receipt_long_outlined,
                  onTap:
                      () =>
                          Navigator.of(context).pushNamed('/pedidos-completos'),
                  color: primaryColor,
                ),
                _MenuCard(
                  title: 'Eventos',
                  icon: Icons.celebration_outlined,
                  onTap: () => Navigator.of(context).pushNamed('/eventos'),
                  color: primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper for the menu cards
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: color.withAlpha(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF880E4F), // Darkest pink
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper for decorative circles
class Circle extends StatelessWidget {
  final Color color;
  final double size;

  const Circle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
