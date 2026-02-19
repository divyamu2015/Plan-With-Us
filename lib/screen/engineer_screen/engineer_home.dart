import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key,required this.userId});
  final int userId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your main dashboard content goes here.
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Replace with your dashboard widgets, metrics, etc.
              _buildDashboard(),
            ],
          ),
          // Floating vertical menu (Conditional)
          if (showMenu)
            Positioned(
              right: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _FloatingMenuButton(
                    label: "View",
                    icon: Icons.remove_red_eye,
                    onTap: () {
                      // Navigate or show your view logic
                    },
                  ),
                  const SizedBox(height: 20),
                  _FloatingMenuButton(
                    label: "Home",
                    icon: Icons.home,
                    onTap: () {
                      // Navigate to home screen
                    },
                  ),
                  const SizedBox(height: 20),
                  _FloatingMenuButton(
                    label: "Logout",
                    icon: Icons.exit_to_app,
                    onTap: () {
                      // Implement logout logic
                    },
                  ),
                  const SizedBox(height: 18),
                  // Close Button
                  FloatingActionButton(
                    backgroundColor: Colors.teal[800],
                    onPressed: () => setState(() => showMenu = false),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: !showMenu
          ? FloatingActionButton(
              backgroundColor: Colors.teal[800],
              onPressed: () => setState(() => showMenu = true),
              child: const Icon(Icons.menu),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Your Progress Today",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // Add other widgets as needed
          ],
        ),
      ),
    );
  }
}

// Individual Floating Menu Option
class _FloatingMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingMenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Label bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Icon button
        Material(
          color: Colors.teal[600],
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}
