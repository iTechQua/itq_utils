import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itq_utils/src/upgrade/itq_app_cast.dart';
import 'package:itq_utils/src/upgrade/itq_itunes_search_api.dart';
import 'package:itq_utils/src/upgrade/itq_play_store_search_api.dart';
import 'package:itq_utils/src/upgrade/itq_upgrade_new_version_messages.dart';
import 'package:itq_utils/src/upgrade/itq_upgrade_new_version_os.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';


/// Signature of callbacks that have no arguments and return bool.
typedef BoolCallback = bool Function();

/// Signature of callbacks that have a bool argument and no return.
typedef VoidBoolCallback = void Function(bool value);

/// Signature of callback for willDisplayUpgrade. Includes display,
/// minAppVersion, installedVersion, and appStoreVersion.
typedef WillDisplayUpgradeCallback = void Function(
    {required bool display,
    String? minAppVersion,
    String? installedVersion,
    String? appStoreVersion});

/// The type of data in the stream.
typedef ItqUpgradeEvaluateNeed = bool;

/// A class to define the configuration for the appcast. The configuration
/// contains two parts: a URL to the appcast, and a list of supported OS
/// names, such as "android", "fuchsia", "ios", "linux" "macos", "web", "windows".
class ItqAppCastConfiguration {
  final List<String>? supportedOS;
  final String? url;

  ItqAppCastConfiguration({
    this.supportedOS,
    this.url,
  });
}

/// Creates a shared instance of [ItqUpgradeNewVersion].
ItqUpgradeNewVersion _sharedInstance = ItqUpgradeNewVersion();

/// A class to configure the upgrade dialog.
class ItqUpgradeNewVersion with WidgetsBindingObserver {
  ItqUpgradeNewVersion({
    this.appCastConfig,
    this.appcast,
    this.messages,
    this.debugDisplayAlways = false,
    this.debugDisplayOnce = false,
    this.debugLogging = false,
    this.durationUntilAlertAgain = const Duration(days: 3),
    this.willDisplayUpgrade,
    http.Client? client,
    this.countryCode,
    this.languageCode,
    this.minAppVersion,
    ItqUpgradeOS? upgradeOS,
  })  : client = client ?? http.Client(),
        upgradeOS = upgradeOS ?? ItqUpgradeOS() {
    if (debugLogging){ if (kDebugMode) {
      print("itqUpgrade: instantiated.");
    }}
  }

  /// Provide an Appcast that can be replaced for mock testing.
  final ItqAppCast? appcast;

  /// The appcast configuration ([ItqAppCastConfiguration]) used by [ItqAppCast].
  /// When an appcast is configured for iOS, the iTunes lookup is not used.
  final ItqAppCastConfiguration? appCastConfig;

  /// Provide an HTTP Client that can be replaced for mock testing.
  final http.Client client;

  /// The country code that will override the system locale. Optional.
  final String? countryCode;

  /// The country code that will override the system locale. Optional. Used only for Android.
  final String? languageCode;

  /// For debugging, always force the upgrade to be available.
  bool debugDisplayAlways;

  /// For debugging, display the upgrade at least once once.
  bool debugDisplayOnce;

  /// Enable print statements for debugging.
  bool debugLogging;

  /// Duration until alerting user again
  final Duration durationUntilAlertAgain;

  /// The localized messages used for display in upgrade.
  ItqUpgradeMessages? messages;

  /// The minimum app version supported by this app. Earlier versions of this app
  /// will be forced to update to the current version. Optional.
  String? minAppVersion;

  /// Provides information on which OS this code is running on.
  final ItqUpgradeOS upgradeOS;

  /// Called when [ItqUpgradeNewVersion] determines that an upgrade may or may not be
  /// displayed. The [value] parameter will be true when it should be displayed,
  /// and false when it should not be displayed. One good use for this callback
  /// is logging metrics for your app.
  WillDisplayUpgradeCallback? willDisplayUpgrade;

  bool _initCalled = false;
  PackageInfo? _packageInfo;

  String? _installedVersion;
  String? _appStoreVersion;
  String? _appStoreListingURL;
  String? _releaseNotes;
  String? _updateAvailable;
  DateTime? _lastTimeAlerted;
  String? _lastVersionAlerted;
  String? _userIgnoredVersion;
  bool _hasAlerted = false;
  bool _isCriticalUpdate = false;

  /// Track the initialization future so that [initialize] can be called multiple times.
  Future<bool>? _futureInit;

  /// A stream that provides a new value each time an evaluation should be performed.
  /// The values will always be null or true.
  Stream<ItqUpgradeEvaluateNeed> get evaluationStream => _streamController.stream;
  final _streamController = StreamController<ItqUpgradeEvaluateNeed>.broadcast();

  /// An evaluation should be performed.
  bool get evaluationReady => _evaluationReady;
  bool _evaluationReady = false;

  /// A shared instance of [ItqUpgradeNewVersion].
  static ItqUpgradeNewVersion get sharedInstance => _sharedInstance;

  static const notInitializedExceptionMessage =
      'itqUpgrade: initialize() not called. Must be called first.';

  String? get currentAppStoreListingURL => _appStoreListingURL;

  String? get currentAppStoreVersion => _appStoreVersion;

  String? get currentInstalledVersion => _installedVersion;

  String? get releaseNotes => _releaseNotes;

  void installPackageInfo({PackageInfo? packageInfo}) {
    _packageInfo = packageInfo;
    _initCalled = false;
  }

  void installAppStoreVersion(String version) => _appStoreVersion = version;

  void installAppStoreListingURL(String url) => _appStoreListingURL = url;

  /// Initialize [ItqUpgradeNewVersion] by getting saved preferences, getting platform package info, and getting
  /// released version info.
  Future<bool> initialize() async {
    if (debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: initialize called');
      }
    }
    if (_futureInit != null) return _futureInit!;

    _futureInit = Future(() async {
      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: initializing');
        }
      }
      if (_initCalled) {
        assert(false, 'This should never happen.');
        return true;
      }
      _initCalled = true;

      await getSavedPrefs();

      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: default operatingSystem: '
            '${upgradeOS.operatingSystem} ${upgradeOS.operatingSystemVersion}');
          print('itqUpgrade: operatingSystem: ${upgradeOS.operatingSystem}');
          print('itqUpgrade: '
            'isAndroid: ${upgradeOS.isAndroid}, '
            'isIOS: ${upgradeOS.isIOS}, '
            'isLinux: ${upgradeOS.isLinux}, '
            'isMacOS: ${upgradeOS.isMacOS}, '
            'isWindows: ${upgradeOS.isWindows}, '
            'isFuchsia: ${upgradeOS.isFuchsia}, '
            'isWeb: ${upgradeOS.isWeb}');
        }
      }

      if (_packageInfo == null) {
        _packageInfo = await PackageInfo.fromPlatform();
        if (debugLogging) {
          if (kDebugMode) {
            print(
              'itqUpgrade: package info packageName: ${_packageInfo!.packageName}');
            print('itqUpgrade: package info appName: ${_packageInfo!.appName}');
            print('itqUpgrade: package info version: ${_packageInfo!.version}');
          }
        }
      }

      _installedVersion = _packageInfo!.version;

      await updateVersionInfo();

      // Add an observer of application events.
      WidgetsBinding.instance.addObserver(this);

      _evaluationReady = true;

      /// Trigger the stream to indicate an evaluation should be performed.
      /// The value will always be true.
      _streamController.add(true);

      return true;
    });
    return _futureInit!;
  }

  /// Remove any resources allocated.
  void dispose() {
    // Remove the observer of application events.
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Handle application events.
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // When app has resumed from background.
    if (state == AppLifecycleState.resumed) {
      await updateVersionInfo();

      /// Trigger the stream to indicate another evaluation should be performed.
      /// The value will always be true.
      _streamController.add(true);
    }
  }

  Future<bool> updateVersionInfo() async {
    // If there is an appcast for this platform
    if (isAppcastThisPlatform()) {
      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: appcast is available for this platform');
        }
      }

      final appcast = this.appcast ?? ItqAppCast(client: client);
      await appcast.parseAppCastItemsFromUri(appCastConfig!.url!);
      if (debugLogging) {
        var count = appcast.items == null ? 0 : appcast.items!.length;
        if (kDebugMode) {
          print('itqUpgrade: appcast item count: $count');
        }
      }
      final criticalUpdateItem = appcast.bestCriticalItem();
      final criticalVersion = criticalUpdateItem?.versionString ?? '';

      final bestItem = appcast.bestItem();
      if (bestItem != null &&
          bestItem.versionString != null &&
          bestItem.versionString!.isNotEmpty) {
        if (debugLogging) {
          if (kDebugMode) {
            print(
              'itqUpgrade: appcast best item version: ${bestItem.versionString}');
            print(
                'itqUpgrade: appcast critical update item version: ${criticalUpdateItem?.versionString}');
          }
        }

        try {
          if (criticalVersion.isNotEmpty &&
              Version.parse(_installedVersion!) <
                  Version.parse(criticalVersion)) {
            _isCriticalUpdate = true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('itqUpgrade: updateVersionInfo could not parse version info $e');
          }
          _isCriticalUpdate = false;
        }

        _appStoreVersion = bestItem.versionString;
        _appStoreListingURL = bestItem.fileURL;
        _releaseNotes = bestItem.itemDescription;
      }
    } else {
      if (_packageInfo == null || _packageInfo!.packageName.isEmpty) {
        return false;
      }

      // The  country code of the locale, defaulting to `US`.
      final country = countryCode ?? findCountryCode();
      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: countryCode: $country');
        }
      }

      // The  language code of the locale, defaulting to `en`.
      final language = languageCode ?? findLanguageCode();
      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: languageCode: $language');
        }
      }

      // Get Android version from Google Play Store, or
      // get iOS version from iTunes Store.
      if (upgradeOS.isAndroid) {
        await getAndroidStoreVersion(country: country, language: language);
      } else if (upgradeOS.isIOS) {
        final iTunes = ITunesSearchAPI();
        iTunes.debugLogging = debugLogging;
        iTunes.client = client;
        final response = await (iTunes
            .lookupByBundleId(_packageInfo!.packageName, country: country));

        if (response != null) {
          _appStoreVersion = iTunes.version(response);
          _appStoreListingURL = iTunes.trackViewUrl(response);
          _releaseNotes ??= iTunes.releaseNotes(response);
          final mav = iTunes.minAppVersion(response);
          if (mav != null) {
            minAppVersion = mav.toString();
            if (debugLogging) {
              if (kDebugMode) {
                print('itqUpgrade: ITunesResults.minAppVersion: $minAppVersion');
              }
            }
          }
        }
      }
    }

    return true;
  }

  /// Android info is fetched by parsing the html of the app store page.
  Future<bool?> getAndroidStoreVersion(
      {String? country, String? language}) async {
    final id = _packageInfo!.packageName;
    final playStore = ItqPlayStoreSearchAPI(client: client);
    playStore.debugLogging = debugLogging;
    final response =
        await (playStore.lookupById(id, country: country, language: language));
    if (response != null) {
      _appStoreVersion ??= playStore.version(response);
      _appStoreListingURL ??=
          playStore.lookupURLById(id, language: language, country: country);
      _releaseNotes ??= playStore.releaseNotes(response);
      final mav = playStore.minAppVersion(response);
      if (mav != null) {
        minAppVersion = mav.toString();
        if (debugLogging) {
          if (kDebugMode) {
            print('itqUpgrade: PlayStoreResults.minAppVersion: $minAppVersion');
          }
        }
      }
    }

    return true;
  }

  bool isAppcastThisPlatform() {
    if (appCastConfig == null ||
        appCastConfig!.url == null ||
        appCastConfig!.url!.isEmpty) {
      return false;
    }

    // Since this appcast config contains a URL, this appcast is valid.
    // However, if the supported OS is not listed, it is not supported.
    // When there are no supported OSes listed, they are all supported.
    var supported = true;
    if (appCastConfig!.supportedOS != null) {
      supported =
          appCastConfig!.supportedOS!.contains(upgradeOS.operatingSystem);
    }
    return supported;
  }

  bool verifyInit() {
    if (!_initCalled) {
      throw ('itqUpgrade: initialize() not called. Must be called first.');
    }
    return true;
  }

  String appName() {
    verifyInit();
    return _packageInfo?.appName ?? '';
  }

  String body(ItqUpgradeMessages messages) {
    var msg = messages.message(ItqUpgradeMessage.body)!;
    msg = msg.replaceAll('{{appName}}', appName());
    msg = msg.replaceAll(
        '{{currentAppStoreVersion}}', currentAppStoreVersion ?? '');
    msg = msg.replaceAll(
        '{{currentInstalledVersion}}', currentInstalledVersion ?? '');
    return msg;
  }

  /// Determine which [ItqUpgradeMessages] object to use. It will be either the one passed
  /// to [ItqUpgradeNewVersion], or one based on the app locale.
  ItqUpgradeMessages determineMessages(BuildContext context) {
    {
      late ItqUpgradeMessages appMessages;
      if (messages != null) {
        appMessages = messages!;
      } else {
        String? languageCode;
        try {
          // Get the current locale in the app.
          final locale = Localizations.localeOf(context);
          // Get the current language code in the app.
          languageCode = locale.languageCode;
          if (debugLogging) {
            if (kDebugMode) {
              print('itqUpgrade: current locale: $locale');
            }
          }
        } catch (e) {
          // ignored, really.
        }

        appMessages = ItqUpgradeMessages(code: languageCode);
      }

      if (appMessages.languageCode.isEmpty) {
        if (kDebugMode) {
          print('itqUpgrade: error -> languageCode is empty');
        }
      } else if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: languageCode: ${appMessages.languageCode}');
        }
      }

      return appMessages;
    }
  }

  bool blocked() {
    return belowMinAppVersion() || _isCriticalUpdate;
  }

  bool shouldDisplayUpgrade() {
    final isBlocked = blocked();

    if (debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: blocked: $isBlocked');
        print('itqUpgrade: debugDisplayAlways: $debugDisplayAlways');
        print('itqUpgrade: debugDisplayOnce: $debugDisplayOnce');
        print('itqUpgrade: hasAlerted: $_hasAlerted');
      }
    }

    bool rv = true;
    if (debugDisplayAlways || (debugDisplayOnce && !_hasAlerted)) {
      rv = true;
    } else if (!isUpdateAvailable()) {
      rv = false;
    } else if (isBlocked) {
      rv = true;
    } else if (isTooSoon() || alreadyIgnoredThisVersion()) {
      rv = false;
    }
    if (debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: shouldDisplayUpgrade: $rv');
      }
    }

    // Call the [willDisplayUpgrade] callback when available.
    if (willDisplayUpgrade != null) {
      willDisplayUpgrade!(
          display: rv,
          minAppVersion: minAppVersion,
          installedVersion: _installedVersion,
          appStoreVersion: _appStoreVersion);
    }

    return rv;
  }

  /// Is installed version below minimum app version?
  bool belowMinAppVersion() {
    var rv = false;
    if (minAppVersion != null) {
      try {
        final minVersion = Version.parse(minAppVersion!);
        final installedVersion = Version.parse(_installedVersion!);
        rv = installedVersion < minVersion;
      } catch (e) {
        if (debugLogging) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }
    return rv;
  }

  bool isTooSoon() {
    if (_lastTimeAlerted == null) {
      return false;
    }

    final lastAlertedDuration = DateTime.now().difference(_lastTimeAlerted!);
    final rv = lastAlertedDuration < durationUntilAlertAgain;
    if (rv && debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: isTooSoon: true');
      }
    }
    return rv;
  }

  bool alreadyIgnoredThisVersion() {
    final rv =
        _userIgnoredVersion != null && _userIgnoredVersion == _appStoreVersion;
    if (rv && debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: alreadyIgnoredThisVersion: true');
      }
    }
    return rv;
  }

  bool isUpdateAvailable() {
    if (debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: appStoreVersion: $_appStoreVersion');
        print('itqUpgrade: installedVersion: $_installedVersion');
        print('itqUpgrade: minAppVersion: $minAppVersion');
      }
    }
    if (_appStoreVersion == null || _installedVersion == null) {
      if (debugLogging){ if (kDebugMode) {
        print('itqUpgrade: isUpdateAvailable: false');
      }}
      return false;
    }

    try {
      final appStoreVersion = Version.parse(_appStoreVersion!);
      final installedVersion = Version.parse(_installedVersion!);

      final available = appStoreVersion > installedVersion;
      _updateAvailable = available ? _appStoreVersion : null;
    } on Exception catch (e) {
      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: isUpdateAvailable: $e');
        }
      }
    }
    final isAvailable = _updateAvailable != null;
    if (debugLogging){ if (kDebugMode) {
      print('itqUpgrade: isUpdateAvailable: $isAvailable');
    }}
    return isAvailable;
  }

  /// Determine the current country code, either from the context, or
  /// from the system-reported default locale of the device. The default
  /// is `US`.
  String? findCountryCode({BuildContext? context}) {
    Locale? locale;
    if (context != null) {
      locale = Localizations.maybeLocaleOf(context);
    } else {
      // Get the system locale
      locale = PlatformDispatcher.instance.locale;
    }
    final code = locale == null || locale.countryCode == null
        ? 'US'
        : locale.countryCode;
    return code;
  }

  /// Determine the current language code, either from the context, or
  /// from the system-reported default locale of the device. The default
  /// is `en`.
  String? findLanguageCode({BuildContext? context}) {
    Locale? locale;
    if (context != null) {
      locale = Localizations.maybeLocaleOf(context);
    } else {
      // Get the system locale
      locale = PlatformDispatcher.instance.locale;
    }
    final code = locale == null ? 'en' : locale.languageCode;
    return code;
  }

  static Future<void> clearSavedSettings() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('userIgnoredVersion');
    await prefs.remove('lastTimeAlerted');
    await prefs.remove('lastVersionAlerted');

    return;
  }

  Future<bool> saveIgnored() async {
    var prefs = await SharedPreferences.getInstance();

    _userIgnoredVersion = _appStoreVersion;
    await prefs.setString('userIgnoredVersion', _userIgnoredVersion ?? '');
    return true;
  }

  Future<bool> saveLastAlerted() async {
    var prefs = await SharedPreferences.getInstance();
    _lastTimeAlerted = DateTime.now();
    await prefs.setString('lastTimeAlerted', _lastTimeAlerted.toString());

    _lastVersionAlerted = _appStoreVersion;
    await prefs.setString('lastVersionAlerted', _lastVersionAlerted ?? '');

    _hasAlerted = true;
    return true;
  }

  Future<bool> getSavedPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    final lastTimeAlerted = prefs.getString('lastTimeAlerted');
    if (lastTimeAlerted != null) {
      _lastTimeAlerted = DateTime.parse(lastTimeAlerted);
    }

    _lastVersionAlerted = prefs.getString('lastVersionAlerted');

    _userIgnoredVersion = prefs.getString('userIgnoredVersion');

    return true;
  }

  void sendUserToAppStore() async {
    if (_appStoreListingURL == null || _appStoreListingURL!.isEmpty) {
      if (debugLogging) {
        if (kDebugMode) {
          print('itqUpgrade: empty _appStoreListingURL');
        }
      }
      return;
    }

    if (debugLogging) {
      if (kDebugMode) {
        print('itqUpgrade: launching: $_appStoreListingURL');
      }
    }

    if (await canLaunchUrl(Uri.parse(_appStoreListingURL!))) {
      try {
        await launchUrl(Uri.parse(_appStoreListingURL!),
            mode: upgradeOS.isAndroid
                ? LaunchMode.externalNonBrowserApplication
                : LaunchMode.platformDefault);
      } catch (e) {
        if (debugLogging) {
          if (kDebugMode) {
            print('itqUpgrade: launch to app store failed: $e');
          }
        }
      }
    } else {}
  }
}
