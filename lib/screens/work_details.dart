import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkDetails {
  bool isAudioMuted = true;

  // Private constructor - prevents direct instantiation from outside the class
  bool isMuted = false;
  WorkDetails._();

  // Singleton instance
  static final WorkDetails _instance = WorkDetails._();

  // Getter to access the instance
  factory WorkDetails() => _instance;

  // Properties of the singleton class
  String workName = '';
  String workCode = '';
  int workId = 0;
  // bool isMuted = false;
}

final workDetailsProvider = Provider<WorkDetails>((ref) {
  return WorkDetails();
});
