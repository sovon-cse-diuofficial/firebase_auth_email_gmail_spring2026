import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF5F6368))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
            child: const Text("Sign Out", style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // AppBar - Google Drive style
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF5F6368)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cloud, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "Drive",
              style: TextStyle(
                color: Color(0xFF202124),
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        actions: [
          // Search button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: isWide ? 360 : 44,
            child: isWide
                ? TextField(
                    decoration: InputDecoration(
                      hintText: "Search in Drive",
                      hintStyle: const TextStyle(color: Color(0xFF5F6368), fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF5F6368), size: 22),
                      filled: true,
                      fillColor: const Color(0xFFF1F3F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF5F6368)),
                    onPressed: () {},
                  ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF5F6368)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          // User avatar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _showLogoutDialog,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFF1A73E8),
                child: Text(
                  (user?.email?.isNotEmpty == true) ? user!.email![0].toUpperCase() : "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
        ),
      ),

      // Drawer - Google Drive sidebar
      drawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.cloud, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Drive",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF202124),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFE0E0E0)),
              const SizedBox(height: 4),

              _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
              _buildNavItem(Icons.star_border, Icons.star, "Starred", 1),
              _buildNavItem(Icons.access_time, Icons.access_time_filled, "Recent", 2),
              _buildNavItem(Icons.offline_pin_outlined, Icons.offline_pin, "Offline", 3),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(color: Color(0xFFE0E0E0)),
              ),

              _buildNavItem(Icons.delete_outline, Icons.delete, "Trash", 4),
              _buildNavItem(Icons.cloud_outlined, Icons.cloud, "Storage", 5),

              const Spacer(),

              // Storage indicator
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRoundedRect(
                      child: LinearProgressIndicator(
                        value: 0.15,
                        backgroundColor: const Color(0xFFE8EAED),
                        valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "2.3 GB of 15 GB used",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Body
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 20,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                "Welcome, ${_getDisplayName(user)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 24),

              // Quick access section
              const Text(
                "Quick Access",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 16),

              // Quick access cards
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildQuickAccessCard(Icons.description, "Documents", Colors.blue, "12 files"),
                    _buildQuickAccessCard(Icons.image, "Photos", Colors.red, "48 files"),
                    _buildQuickAccessCard(Icons.videocam, "Videos", Colors.orange, "7 files"),
                    _buildQuickAccessCard(Icons.music_note, "Music", Colors.purple, "23 files"),
                    _buildQuickAccessCard(Icons.archive, "Archives", Colors.teal, "3 files"),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Files section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Files",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202124),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.view_list, size: 20, color: Color(0xFF5F6368)),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.grid_view, size: 20, color: Color(0xFF1A73E8)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // File grid
              GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: isWide ? 1.3 : 1.1,
                children: const [
                  FileCard(icon: Icons.folder, title: "Projects", subtitle: "8 items", color: Color(0xFF5F6368)),
                  FileCard(icon: Icons.folder, title: "Work", subtitle: "15 items", color: Color(0xFF5F6368)),
                  FileCard(icon: Icons.folder, title: "Personal", subtitle: "22 items", color: Color(0xFF5F6368)),
                  FileCard(icon: Icons.description, title: "Notes.pdf", subtitle: "2.3 MB", color: Color(0xFF4285F4)),
                  FileCard(icon: Icons.image, title: "Photo.jpg", subtitle: "4.1 MB", color: Color(0xFFEA4335)),
                  FileCard(icon: Icons.table_chart, title: "Data.xlsx", subtitle: "1.2 MB", color: Color(0xFF34A853)),
                ],
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3C4043),
        elevation: 3,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        icon: const Icon(Icons.add, color: Color(0xFF1A73E8), size: 26),
        label: const Text(
          "New",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getDisplayName(User? user) {
    if (user == null) return "User";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return user.email?.split('@').first ?? "User";
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String title, int index) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => setState(() => _selectedNavIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD3E3FD) : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF3C4043),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(IconData icon, String title, Color color, String subtitle) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5F6368)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom clip widget for LinearProgressIndicator
class ClipRoundedRect extends StatelessWidget {
  final Widget child;
  const ClipRoundedRect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: child,
    );
  }
}

// File card widget
class FileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const FileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}