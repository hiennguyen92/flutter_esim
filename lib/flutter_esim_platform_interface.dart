import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_esim_method_channel.dart';

abstract class FlutterEsimPlatform extends PlatformInterface {
  /// Constructs a FlutterEsimPlatform.
  FlutterEsimPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterEsimPlatform _instance = MethodChannelFlutterEsim();

  /// The default instance of [FlutterEsimPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterEsim].
  static FlutterEsimPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterEsimPlatform] when
  /// they register themselves.
  static set instance(FlutterEsimPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isSupportESim() {
    throw UnimplementedError('isSupportESim() has not been implemented.');
  }

  Future<String> installEsimProfile(String profile) {
    throw UnimplementedError('installEsimProfile() has not been implemented.');
  }

  Future<String> instructions() {
    throw UnimplementedError('instructions() has not been implemented.');
  }


  Stream<dynamic> get onEvent => throw UnimplementedError('onEvent() has not been implemented.');


}
