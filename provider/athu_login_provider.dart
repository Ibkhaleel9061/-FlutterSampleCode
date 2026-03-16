class AuthProvider with ChangeNotifier {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Login method
  Future<void> login(BuildContext context) async {
    debugPrint('Login method called...............');

    // Reset error message
    _errorMessage = '';

    // Validate inputs
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      showMessage(_errorMessage, context);
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final apiurl = Uri.parse(ApiUrls.authlogin);
      final body = json.encode({
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });

      final response = await http.post(
        apiurl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final responseData = json.decode(response.body);
      debugPrint('Response data: $responseData');

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          // Save token and user ID
          final token = responseData['token'] as String;
          final userId = responseData['user']['_id'] as String;
          final userName = responseData['user']['userDisplayName'] as String;
          final userEmail = responseData['user']['email'] as String;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('authUserId', userId);
          await prefs.setString('authUserName', userName);
          await prefs.setString('authUserEmail', userEmail);

          // Navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Streams()),
          );
        } else {
          _errorMessage = responseData['message'] ?? 'Login failed';
          showMessage(_errorMessage, context);
        }
      } else {
        _errorMessage =
            responseData['message'] ?? 'Login failed. Please try again.';
        showMessage(_errorMessage, context);
      }
    } catch (error) {
      _errorMessage = 'Login failed. Please check your credentials: $error';
      showMessage(_errorMessage, context);
      debugPrint('Login error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Show error message
  void showMessage(String content, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sorry!"),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
