import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdg_solution/utils/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmerProfile extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigation code will go here
    // Navigate to login screen after logout
    // Replace LoginScreen with your actual login screen widget
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Farmer Profile',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onPrimary),
            onPressed: () {
              // Add edit profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(colorScheme),
            SizedBox(height: 24),
            _buildProfileSection(
              context,
              title: 'Personal Information',
              children: [
                _buildProfileItem(
                  context,
                  icon: Icons.person,
                  label: 'Name',
                  value: 'Rahul Sharma',
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.phone,
                  label: 'Phone',
                  value: '+91 98765 43210',
                  isClickable: true,
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.location_on,
                  label: 'Location',
                  value: 'Nashik, Maharashtra',
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.fingerprint,
                  label: 'Aadhaar Linked',
                  value: '✅ Verified',
                ),
              ],
            ),
            _buildProfileSection(
              context,
              title: 'Farm Details',
              children: [
                _buildProfileItem(
                  context,
                  icon: Icons.agriculture,
                  label: 'Farm Size',
                  value: '5.2 Hectares',
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.grass,
                  label: 'Main Crops',
                  value: 'Grapes, Pomegranate',
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.water_drop,
                  label: 'Irrigation Type',
                  value: 'Drip Irrigation',
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.assignment,
                  label: 'Soil Health Card',
                  value: 'View Card',
                  isClickable: true,
                ),
              ],
            ),
            _buildProfileSection(
              context,
              title: 'Settings',
              children: [
                SwitchListTile(
                  title: Text('Dark Mode'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // Add theme switching logic
                  },
                  secondary: Icon(
                    Icons.brightness_6,
                    color: colorScheme.tertiary,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.language, color: colorScheme.tertiary),
                  title: Text('Language'),
                  trailing: Text('English'),
                  onTap: () {
                    // Add language selection
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: colorScheme.tertiary,
                  ),
                  title: Text('Notifications'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Add notification settings
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildLogoutButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.tertiary, colorScheme.tertiary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: colorScheme.onTertiary.withOpacity(0.2),
            child: Icon(Icons.person, size: 40, color: colorScheme.onTertiary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rahul Sharma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Registered Farmer since 2018',
                  style: TextStyle(
                    color: colorScheme.onTertiary.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 8),
                Chip(
                  backgroundColor: colorScheme.onTertiary.withOpacity(0.2),
                  label: Text(
                    'Verified Farmer',
                    style: TextStyle(color: Colors.black.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: Border.all(color: Colors.transparent, width: 0),
        initiallyExpanded: true,
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.tertiary),
      title: Text(label),
      subtitle: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.8),
          fontWeight: isClickable ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isClickable ? Icon(Icons.content_copy, size: 20) : null,
      onTap:
          isClickable
              ? () {
                // Add copy to clipboard functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard: $value')),
                );
              }
              : null,
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      icon: Icon(Icons.logout, size: 20),
      label: Text('Logout'),
      onPressed: () => _logout(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
