// GET - POST - PUT - DELETE

class AuthProfileProvider extends ChangeNotifier {
  UserProfile? _profile; // User profile data model
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String apiUrl =
      "https://backend-endpoint.eventhex.ai/api/v1/mobile/profile"; // Replace with your actual API URL

  final String userId = "6778f7447fc6f415e56910d5";

  // Fetch user profile data from the server using GET request

  Future<void> getProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse("$apiUrl?id=$userId");
    debugPrint('url-- $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          _profile = UserProfile.fromJson(data);
        } else {
          _error = 'No user data found';
        }
      } else {
        _error = 'Failed to load profile: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Error loading profile: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile name using PUT request

  Future<void> updateProfileName(String newName) async {
    if (_profile == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse("$apiUrl?id=${_profile!.id}");
    debugPrint('Upload URL: $url');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fullName': newName, 'id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profile = UserProfile.fromJson(data);
        _error = null;
      } else {
        _error = 'Failed to update profile: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Error updating profile: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile image using multipart/form-data PUT request

  Future<void> updateProfileImage(File imageFile) async {
    if (_profile == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse("$apiUrl?id=${_profile!.id}");
    debugPrint('Upload URL: $url');

    try {
      final request = http.MultipartRequest('PUT', url);

      // Add headers
      request.headers.addAll({'Accept': 'application/json'});

      // Add fields
      request.fields['id'] = _profile!.id;

      // Get MIME type for the image
      final mimeType = lookupMimeType(imageFile.path);
      debugPrint("Image MIME type: $mimeType");

      // Add the image file with correct field name
      final multipartFile = await http.MultipartFile.fromPath(
        'keyImage', // Changed to match the working implementation
        imageFile.path,
        contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
      );
      request.files.add(multipartFile);

      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files: ${request.files}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profile = UserProfile.fromJson(data);
        _error = null;
      } else {
        final responseData = jsonDecode(response.body);
        _error =
            responseData['customMessage'] ??
            'Failed to update profile image: ${response.statusCode}';
      }
    } on TimeoutException {
      _error = 'Request timed out. Please try again.';
      debugPrint('Error: Request timed out');
    } catch (error) {
      _error = 'Error updating profile image: $error';
      debugPrint('Error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
