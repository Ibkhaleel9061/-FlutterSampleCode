import 'package:flutter/foundation.dart';

class CountProvider with ChangeNotifier {
  int _count = 2;
  int get count => _count;

  var studentModelx;

  CountProvider(this.studentModelx);

  void toggleCount() {
    if (_count == studentModelx?.response?.length) {
      _count = 2;
    } else {
      _count = studentModelx?.response?.length ?? 2;
    }
    notifyListeners();
  }
}
  }
}