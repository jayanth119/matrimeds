import 'package:flutter/material.dart';

class DiseaseSearchPage extends StatefulWidget {
  const DiseaseSearchPage({super.key});

  @override
  _DiseaseSearchPageState createState() => _DiseaseSearchPageState();
}

class _DiseaseSearchPageState extends State<DiseaseSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _diseaseInfo;

  Future<void> _searchDisease() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock disease data
    setState(() {
      _diseaseInfo = {
        'name': 'Diabetes Mellitus',
        'type': 'Metabolic Disorder',
        'overview': 'A group of metabolic disorders characterized by high blood sugar levels over a prolonged period.',
        'symptoms': [
          'Frequent urination',
          'Excessive thirst',
          'Unexplained weight loss',
          'Fatigue',
          'Blurred vision',
          'Slow healing wounds'
        ],
        'causes': [
          'Genetics',
          'Lifestyle factors',
          'Obesity',
          'Physical inactivity',
          'Age',
          'Ethnicity'
        ],
        'risk_factors': [
          'Family history',
          'Overweight',
          'Sedentary lifestyle',
          'Age over 45',
          'High blood pressure',
          'Previous gestational diabetes'
        ],
        'complications': [
          'Heart disease',
          'Stroke',
          'Kidney damage',
          'Eye damage',
          'Nerve damage',
          'Foot problems'
        ],
        'treatments': [
          'Lifestyle changes',
          'Medication',
          'Insulin therapy',
          'Blood sugar monitoring',
          'Regular exercise',
          'Healthy diet'
        ],
        'prevention': [
          'Maintain healthy weight',
          'Regular physical activity',
          'Eat a balanced diet',
          'Limit processed foods',
          'Regular health checkups',
          'Manage stress'
        ]
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Disease Search'),
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchSection(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingWidget(),
            if (_diseaseInfo != null) _buildDiseaseReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search for Disease Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter disease name...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9800)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
              ),
            ),
            onSubmitted: (value) => _searchDisease(),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _searchDisease,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Search Disease'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
          ),
          SizedBox(height: 20),
          Text(
            'Searching for disease information...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseReport() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disease Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          _buildDiseaseInfoSection('Disease Name', _diseaseInfo!['name']),
          _buildDiseaseInfoSection('Type', _diseaseInfo!['type']),
          _buildDiseaseInfoSection('Overview', _diseaseInfo!['overview']),
          _buildDiseaseListSection('Symptoms', _diseaseInfo!['symptoms'], Icons.healing),
          _buildDiseaseListSection('Causes', _diseaseInfo!['causes'], Icons.warning),
          _buildDiseaseListSection('Risk Factors', _diseaseInfo!['risk_factors'], Icons.info),
          _buildDiseaseListSection('Complications', _diseaseInfo!['complications'], Icons.error),
          _buildDiseaseListSection('Treatments', _diseaseInfo!['treatments'], Icons.local_hospital),
          _buildDiseaseListSection('Prevention', _diseaseInfo!['prevention'], Icons.shield),
          _buildDisclaimerSection(),
        ],
      ),
    );
  }

  Widget _buildDiseaseInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseListSection(String title, List<String> items, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF9800), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 3),
            child: Text(
              '• $item',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2196F3), width: 1),
      ),
      child: Row(
        children:  const [
           Icon(
            Icons.info,
            color: Color(0xFF2196F3),
            size: 24,
          ),
           SizedBox(width: 10),
           Expanded(
            child: Text(
              'This information is for educational purposes only. Always consult with a healthcare professional for proper diagnosis and treatment.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}