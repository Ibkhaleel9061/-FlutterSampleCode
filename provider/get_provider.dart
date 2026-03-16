import 'package:http/http.dart' as http;

class ExamResultProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  ExamResultModel? studentModelx; // Initialize as null

  Future<void> fetchExamResults() async {
    studentModelx = null;
    _isLoading = true;

    try {
      final response = await http.get(Uri.parse(ApiUrls.examResult));
      if (response.statusCode == 200) {
        // Convert the JSON response body into a StudentModel object
        studentModelx = ExamResultModelFromJson(response.body);
        //
        if (studentModelx?.response != null) {
          // debugPrint('GET : -----------------------------------');
          // debugPrint(studentModelx!.response![1].id);
          // debugPrint(studentModelx!.response![0].topic!.subject!.stream!.title);
          // debugPrint(studentModelx!.response![0].topic!.title);
          notifyListeners();
        } else {
          debugPrint('Response is null');
        }
      } else {
        debugPrint(
          'Failed to load data. HTTP Status Code: ${response.statusCode}',
        ); //404 or 500
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
