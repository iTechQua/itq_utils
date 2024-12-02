import 'package:flutter_test/flutter_test.dart';
import 'package:itq_utils/itq_utils.dart';
import 'package:itq_utils/itq_utils_platform_interface.dart';
import 'package:itq_utils/itq_utils_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockItqUtilsPlatform
    with MockPlatformInterfaceMixin
    implements ItqUtilsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ItqUtilsPlatform initialPlatform = ItqUtilsPlatform.instance;

  test('$MethodChannelItqUtils is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelItqUtils>());
  });

  test('getPlatformVersion', () async {
    ItqUtils itqUtilsPlugin = ItqUtils();
    MockItqUtilsPlatform fakePlatform = MockItqUtilsPlatform();
    ItqUtilsPlatform.instance = fakePlatform;

    expect(await itqUtilsPlugin.getPlatformVersion(), '42');
  });
}
