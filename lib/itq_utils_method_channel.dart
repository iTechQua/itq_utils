import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'itq_utils_platform_interface.dart';

/// An implementation of [ItqUtilsPlatform] that uses method channels.
class MethodChannelItqUtils extends ItqUtilsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('itq_utils');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
