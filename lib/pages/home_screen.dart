import 'package:flutter/material.dart';
import 'package:matrimeds/pages/aichart_screen.dart';
import 'package:matrimeds/pages/diseases_screen.dart';
import 'package:matrimeds/pages/login_screen.dart';
import 'package:matrimeds/pages/medicine_scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Matrimeds",
          style: TextStyle(color: Color(0xFF2C3E50)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildQuickActions(),
                      const SizedBox(height: 30),
                      _buildFeatureCards(),
                      const SizedBox(height: 30),
                      _buildHealthTips(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 35, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(width: 15),
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  const [
                Text('Hello, User!',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('How can I help you today?',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.notifications, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.camera_alt,
                label: 'Scan Medicine',
                color: const Color(0xFF4CAF50),
                onTap: _navigateToMedicineScanner,
              ),
              _buildQuickActionButton(
                icon: Icons.search,
                label: 'Search Disease',
                color: const Color(0xFFFF9800),
                onTap: _navigateToDiseaseSearch,
              ),
              _buildQuickActionButton(
                icon: Icons.chat,
                label: 'AI Chat',
                color: const Color(0xFF9C27B0),
                onTap: _navigateToAIChat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Features',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 15),
        _buildFeatureCard(
          title: 'Medicine Analysis',
          description:
              'Take a photo of your medicine and get detailed information about usage, side effects, and precautions.',
          icon: Icons.medication,
          color: const Color(0xFF4CAF50),
          onTap: _navigateToMedicineScanner,
        ),
        const SizedBox(height: 15),
        _buildFeatureCard(
          title: 'Disease Information',
          description:
              'Search for any disease and get comprehensive information about symptoms, causes, and treatments.',
          icon: Icons.healing,
          color: const Color(0xFFFF9800),
          onTap: _navigateToDiseaseSearch,
        ),
        const SizedBox(height: 15),
        _buildFeatureCard(
          title: 'AI Health Assistant',
          description:
              'Chat with our AI assistant for personalized health advice and medical guidance.',
          icon: Icons.smart_toy,
          color: const Color(0xFF9C27B0),
          onTap: _navigateToAIChat,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration:
                  BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50))),
                  const SizedBox(height: 5),
                  Text(description,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF7F8C8D)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const  [
          Text('Health Tip of the Day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          Text(
            'Drink at least 8 glasses of water daily to stay hydrated and maintain optimal health.',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _navigateToMedicineScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MedicineScannerPage()),
    );
  }

  void _navigateToDiseaseSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiseaseSearchPage()),
    );
  }

  void _navigateToAIChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIChatPage()),
    );
  }
}
