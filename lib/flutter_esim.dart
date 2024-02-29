import 'flutter_esim_platform_interface.dart';

class FlutterEsim {

  Future<bool> isSupportESim() async {
    return FlutterEsimPlatform.instance.isSupportESim();
  }

  Future<String> installEsimProfile(String profile) async {
    return FlutterEsimPlatform.instance.installEsimProfile(profile);
  }

  Future<String> instructions() async {
    return FlutterEsimPlatform.instance.instructions();
  }

  Stream<dynamic> get onEvent => FlutterEsimPlatform.instance.onEvent;


}
