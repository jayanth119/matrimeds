import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineScannerPage extends StatefulWidget {
  const MedicineScannerPage({super.key});

  @override
  _MedicineScannerPageState createState() => _MedicineScannerPageState();
}

class _MedicineScannerPageState extends State<MedicineScannerPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Map<String, dynamic>? _medicineInfo;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _medicineInfo = null;
          _errorMessage = null;
        });
        _analyzeMedicine();
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _analyzeMedicine() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://silver-octo-winner.onrender.com/api/medicine'),
      );

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _image!.path,
        ),
      );

      // Add language parameter
      request.fields['language'] = 'en'; // or 'te' for Telugu

      // Send request
      var response = await request.send();

      // Get response
      var responseString = await response.stream.bytesToString();
      var responseData = json.decode(responseString);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success' && responseData['data'] != null && responseData['data'].isNotEmpty) {
          setState(() {
            _medicineInfo = _formatMedicineData(responseData['data'][0]);
          });
        } else {
          setState(() {
            _errorMessage = 'No medicine information found';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to analyze medicine: ${responseData['message'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      print('Error analyzing medicine: $e');
      setState(() {
        _errorMessage = 'Failed to analyze medicine: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _formatMedicineData(Map<String, dynamic> apiData) {
    return {
      'name': apiData['medicine_name'] ?? 'Unknown Medicine',
      'generic_name': apiData['medicine_name'] ?? 'Unknown', // Adjust based on actual API response
      'brand_names': [], // Not available in current API response
      'usage': (apiData['uses_and_benefits'] as List<dynamic>?)?.join(', ') ?? 'Unknown',
      'dosage': apiData['dosage'] ?? 'Consult your doctor',
      'side_effects': (apiData['side_effects'] as List<dynamic>?)?.cast<String>() ?? ['None reported'],
      'precautions': (apiData['precautions'] as List<dynamic>?)?.cast<String>() ?? ['None specified'],
      'contraindications': [], // Not available in current API response
      'interactions': [], // Not available in current API response
      'storage': 'Store in cool, dry place', // Not available in current API response
      'expiry_check': 'Always check expiry date before use', // Not available in current API response
      'conditions_treated': (apiData['conditions_treated'] as List<dynamic>?)?.cast<String>() ?? [],
      'diseases': (apiData['diseases'] as List<dynamic>?)?.cast<String>() ?? [],
      'time_to_improve': apiData['time_to_improve'] is Map ? 
        (apiData['time_to_improve'] as Map<String, dynamic>).entries.map((e) => '${e.key}: ${e.value}').join('\n') : 
        'Varies by condition',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Medicine Scanner'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildImageSection(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingWidget(),
            if (_errorMessage != null) _buildErrorWidget(),
            if (_medicineInfo != null) _buildMedicineReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 300,
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
      child: _image == null
          ? _buildImagePlaceholder()
          : _buildImagePreview(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.camera_alt,
          size: 80,
          color: Color(0xFF4CAF50),
        ),
        const SizedBox(height: 20),
        const Text(
          'Take a photo of your medicine',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _image!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _image = null;
                  _medicineInfo = null;
                  _errorMessage = null;
                });
              },
            ),
          ),
        ),
      ],
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 20),
          Text(
            'Analyzing medicine...',
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

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF5252), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error,
            color: Color(0xFFD32F2F),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineReport() {
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
            'Medicine Report',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoSection('Medicine Name', _medicineInfo!['name']),
          if (_medicineInfo!['generic_name'].isNotEmpty)
            _buildInfoSection('Generic Name', _medicineInfo!['generic_name']),
          if (_medicineInfo!['conditions_treated'].isNotEmpty)
            _buildListSection('Conditions Treated', _medicineInfo!['conditions_treated']),
          if (_medicineInfo!['diseases'].isNotEmpty)
            _buildListSection('Diseases', _medicineInfo!['diseases']),
          _buildInfoSection('Usage', _medicineInfo!['usage']),
          _buildInfoSection('Dosage', _medicineInfo!['dosage']),
          if (_medicineInfo!['time_to_improve'].isNotEmpty)
            _buildInfoSection('Time to Improve', _medicineInfo!['time_to_improve']),
          _buildListSection('Side Effects', _medicineInfo!['side_effects']),
          _buildListSection('Precautions', _medicineInfo!['precautions']),
          if (_medicineInfo!['contraindications'].isNotEmpty)
            _buildListSection('Contraindications', _medicineInfo!['contraindications']),
          if (_medicineInfo!['interactions'].isNotEmpty)
            _buildListSection('Interactions', _medicineInfo!['interactions']),
          _buildInfoSection('Storage', _medicineInfo!['storage']),
          _buildWarningSection(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
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
              color: Color(0xFF4CAF50),
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

  Widget _buildListSection(String title, List<String> items) {
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
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 5),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 2),
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

  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF5252), width: 1),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.warning,
            color: Color(0xFFFF5252),
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Always consult a healthcare professional before taking any medication. This information is for educational purposes only.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}