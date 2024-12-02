import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'itq_utils_method_channel.dart';

abstract class ItqUtilsPlatform extends PlatformInterface {
  /// Constructs a ItqUtilsPlatform.
  ItqUtilsPlatform() : super(token: _token);

  static final Object _token = Object();

  static ItqUtilsPlatform _instance = MethodChannelItqUtils();

  /// The default instance of [ItqUtilsPlatform] to use.
  ///
  /// Defaults to [MethodChannelItqUtils].
  static ItqUtilsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ItqUtilsPlatform] when
  /// they register themselves.
  static set instance(ItqUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
