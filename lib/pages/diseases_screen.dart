import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiseaseSearchPage extends StatefulWidget {
  const DiseaseSearchPage({super.key});

  @override
  _DiseaseSearchPageState createState() => _DiseaseSearchPageState();
}

class _DiseaseSearchPageState extends State<DiseaseSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _diseaseInfo;
  String _loadingMessage = 'Searching for disease information...';
  bool _isRetrying = false;

  // Helper method to safely convert dynamic list to List<String>
  List<String> _safeListConversion(dynamic data) {
    debugPrint("Converting data to List<String>: $data (Type: ${data.runtimeType})");
    if (data == null) return [];
    if (data is List) {
      final result = data.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
      debugPrint("Conversion result: $result");
      return result;
    }
    debugPrint("Data is not a list, returning empty list");
    return [];
  }

  void _updateLoadingMessage(int attempt, bool isRetry) {
    setState(() {
      if (attempt == 1 && !isRetry) {
        _loadingMessage = 'Searching for disease information...\n(Server may take 30-60s to wake up)';
      } else if (attempt == 1 && isRetry) {
        _loadingMessage = 'Server is waking up...\nThis may take up to 60 seconds.';
      } else {
        _loadingMessage = 'Retry attempt $attempt...\nPlease wait...';
      }
    });
  }

Future<void> _searchDisease({bool isRetry = false}) async {
  if (_searchController.text.isEmpty) return;

  setState(() {
    _isLoading = true;
    _diseaseInfo = null;
    _isRetrying = isRetry;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('disease_name', _searchController.text);

  const String url = "https://silver-octo-winner.onrender.com/api/diseases";
  final Map<String, String> headers = {
    "Content-Type": "application/x-www-form-urlencoded"
  };
  final Map<String, String> body = {
    "disease_name": _searchController.text.trim(),
    // get language  from shared preferences 
    "language": prefs.getString('app_language') ?? 'english',
  
  };

  debugPrint("Sending request to: $url");
  debugPrint("Request body (form): $body");

  Map<String, dynamic>? apiResponse;
  int retryCount = 0;
  const int maxRetries = 3;
  const int baseTimeoutSeconds = 90;

  while (apiResponse == null && retryCount < maxRetries) {
    try {
      _updateLoadingMessage(retryCount + 1, isRetry);
      debugPrint("Attempt ${retryCount + 1}/$maxRetries");

      int timeoutSeconds = baseTimeoutSeconds + (retryCount * 30);

      final response = await http.post(
        Uri.parse(url),
        
        headers: headers,
        body: body, // ✅ Important: No jsonEncode
      ).timeout(Duration(seconds: timeoutSeconds));

      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("Response headers: ${response.headers}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          debugPrint("Parsed JSON data: $jsonData");

          if (jsonData is Map<String, dynamic>) {
            if (jsonData['status'] == 'success' && jsonData['data'] != null) {
              apiResponse = jsonData['data'];
              break;
            } else {
              _showErrorMessage("API Error: ${jsonData['message'] ?? 'Unknown error'}");
              break;
            }
          }
        } catch (jsonError) {
          debugPrint("JSON parsing error: $jsonError");
          debugPrint("Response body might not be JSON.");
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        debugPrint("Client error ${response.statusCode}: ${response.reasonPhrase}");
        _showErrorMessage("Request error: ${response.statusCode} ${response.reasonPhrase}");
        break;
      } else {
        debugPrint("Server error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("Exception on attempt ${retryCount + 1}: $e");
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        debugPrint("Request timed out - server might be sleeping");
      }
    }

    retryCount++;
    if (retryCount < maxRetries) {
      int delaySeconds = 5 + (retryCount * 2);
      debugPrint("Waiting ${delaySeconds}s before retry...");
      setState(() {
        _loadingMessage = 'Waiting ${delaySeconds}s before retry ${retryCount + 1}...';
      });
      await Future.delayed(Duration(seconds: delaySeconds));
    }
  }

  setState(() {
    _isLoading = false;
    _isRetrying = false;

    if (apiResponse != null) {
      _diseaseInfo = {
        'name': apiResponse['disease_name']?.toString() ?? 'Unknown',
        'overview': apiResponse['description']?.toString() ?? 'No description available',
        'symptoms': _safeListConversion(apiResponse['symptoms']),
        'causes': _safeListConversion(apiResponse['causes']),
        'risk_factors': _safeListConversion(apiResponse['risk_factors']),
        'complications': _safeListConversion(apiResponse['complications']),
        'treatments': _safeListConversion(apiResponse['treatments']),
        'prevention': _safeListConversion(apiResponse['prevention']),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Disease information loaded successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _diseaseInfo = {
        'name': 'Connection Failed',
        'overview': 'Unable to connect to the server after multiple attempts.\n\n'
            'This commonly happens with free hosting services that:\n'
            '• Go to sleep after 15 minutes of inactivity\n'
            '• Take 30-90 seconds to wake up\n'
            '• May experience high traffic\n\n'
            'Try again in a few minutes or check your internet connection.',
        'symptoms': <String>[],
        'causes': <String>[],
        'risk_factors': <String>[],
        'complications': <String>[],
        'treatments': <String>[],
        'prevention': <String>[]
      };

      _showRetrySnackBar();
    }
  });
}

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showRetrySnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Server connection failed. The server may be sleeping."),
        backgroundColor: Colors.orangeAccent,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Retry Now',
          textColor: Colors.white,
          onPressed: () => _searchDisease(isRetry: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Disease Search'),
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        actions: [
          if (_isLoading)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                setState(() {
                  _isLoading = false;
                  _loadingMessage = 'Search cancelled';
                });
              },
              tooltip: 'Cancel Search',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchSection(),
            const SizedBox(height: 20),
            if (_isLoading) _buildLoadingWidget(),
            if (_diseaseInfo != null && !_isLoading) _buildDiseaseReport(),
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
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Enter disease name (e.g., diabetes, covid-19)...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9800)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
            ),
            onSubmitted: (value) => _searchDisease(),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _searchDisease(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey : const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading 
                ? const Text('Searching...')
                : const Text('Search Disease'),
            ),
          ),
          if (!_isLoading) ...[
            const SizedBox(height: 10),
            Text(
              'Note: First search may take 30-60 seconds while server wakes up',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                  strokeWidth: 4,
                ),
              ),
              if (_isRetrying)
                const Icon(
                  Icons.refresh,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _loadingMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
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
          Row(
            children: [
              const Icon(Icons.medical_information, 
                color: Color(0xFFFF9800), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Disease Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDiseaseInfoSection('Disease Name', _diseaseInfo!['name']),
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
              height: 1.4,
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800))),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 28),
              child: Text("No data available",
                  style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 3),
                  child: Text('• $item',
                      style: const TextStyle(
                        fontSize: 14, 
                        color: Color(0xFF2C3E50),
                        height: 1.3,
                      )),
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
      child:  Row(
        children: [
          Icon(Icons.info, color: Color(0xFF2196F3), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This information is for educational purposes only. Always consult with a healthcare professional for proper diagnosis and treatment.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}