import 'flutter_esim_platform_interface.dart';

class FlutterEsim {

  Future<bool> isSupportESim(List<String>? newer) async {
    return FlutterEsimPlatform.instance.isSupportESim(newer);
  }

  Future<String> installEsimProfile(String profile) async {
    return FlutterEsimPlatform.instance.installEsimProfile(profile);
  }

  Future<String> instructions() async {
    return FlutterEsimPlatform.instance.instructions();
  }

  Stream<dynamic> get onEvent => FlutterEsimPlatform.instance.onEvent;
}
