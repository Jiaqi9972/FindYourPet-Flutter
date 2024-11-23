import 'package:flutter/foundation.dart';
import 'package:find_your_pet/models/pet_status.dart';

class PetStatusProvider with ChangeNotifier {
  PetStatus _currentStatus = PetStatus.both;

  PetStatus get currentStatus => _currentStatus;

  void updateStatus(PetStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      notifyListeners();
    }
  }
}
