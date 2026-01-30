import 'dart:io';

import 'package:flutter/material.dart';

import 'setting_screen.dart';
import '../models/user_model.dart';

const double kDefaultPadding = 20.0;
const double kGridSpacing = 16.0;

const Color primaryBlue = Color(0xFF2563EB);
const Color lightBlue = Color(0xFFEFF6FF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ======================================================
// STATE
// ======================================================
class _HomeScreenState extends State<HomeScreen> {
  late AppUser currentUser;

  @override
  void initState() {
    super.initState();

    // Default user
    currentUser = AppUser(
      name: 'User',
      role: 'Employer',
      imagePath: null,
    );
  }

  // =======================
  // OPEN SETTINGS
  // =======================
  Future<void> _openSettings() async {
    final result = await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingScreen(
          user: currentUser,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        currentUser = result;
      });
    }
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: lightBlue,

        title: const Text(
          'QR Tools',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: primaryBlue,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileHeader(user: currentUser),

            const SizedBox(height: 32),

            const Text(
              'Welcome back 👋',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'QR Scanner & Generator',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),

            const SizedBox(height: 36),

            // =======================
            // PRINT
            // =======================
            SizedBox(
              height: 160,
              child: _BigMenuCard(
                icon: Icons.print_rounded,
                title: 'Print QR Code',
                subtitle: 'Print your generated QR easily',
                route: '/print',
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF60A5FA),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kGridSpacing),

            // =======================
            // CREATE & SCAN
            // =======================
            Row(
              children: const [
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: _MenuButton(
                      icon: Icons.qr_code_2_rounded,
                      label: 'Create QR',
                      route: '/create',
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1D4ED8),
                          Color(0xFF3B82F6),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: kGridSpacing),

                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: _MenuButton(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan QR',
                      route: '/scan',
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0284C7),
                          Color(0xFF38BDF8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// PROFILE HEADER
// ======================================================
class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: primaryBlue,

            child: CircleAvatar(
              radius: 32,

              backgroundImage: user.imagePath != null
                  ? FileImage(File(user.imagePath!))
                  : const AssetImage(
                      'assets/images/profile.jpg',
                    ) as ImageProvider,
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${user.name}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user.role,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================
// BIG CARD
// ======================================================
class _BigMenuCard extends StatelessWidget {
  const _BigMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.gradient,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),

      child: Container(
        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),

          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(18),

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                size: 40,
                color: primaryBlue,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// MENU BUTTON
// ======================================================
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.route,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final String route;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),

      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),

          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              padding: const EdgeInsets.all(18),

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: primaryBlue,
                size: 36,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
