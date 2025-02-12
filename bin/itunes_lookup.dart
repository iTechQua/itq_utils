import 'package:itq_utils/src/upgrade/itunes_search_api.dart';

void main(List<String> arguments) async {
  const defaultLookupBundleId = 'com.google.Maps';
  var lookupBundleId = defaultLookupBundleId;
  String? lookupAppId;

  if (arguments.length == 1) {
    final arg0 = arguments[0].split('=');
    if (arg0.length == 2) {
      final argName = arg0[0];
      final argValue = arg0[1];

      if (argName == 'bundleid') {
        lookupBundleId = argValue;
      } else if (argName == 'appid') {
        lookupAppId = argValue;
      }
    }
  }

  final iTunes = ITunesSearchAPI();
  iTunes.debugLogging = true;
  const countryCode = 'US';

  Map? results;
  if (lookupAppId != null) {
    results = await iTunes.lookupById(
      lookupAppId,
      country: countryCode,
    );
  } else {
    results = await iTunes.lookupByBundleId(
      lookupBundleId,
      country: countryCode,
    );
  }

  if (results == null) {
    print('itunes_lookup there are no results');
    return;
  }

  final bundleId = iTunes.bundleId(results);
  final description = iTunes.description(results);
  final minAppVersion = iTunes.minAppVersion(results);
  final releaseNotes = iTunes.releaseNotes(results);
  final trackViewUrl = iTunes.trackViewUrl(results);
  final version = iTunes.version(results);

  print('itunes_lookup bundleId: $bundleId');
  print('itunes_lookup description: $description');
  print('itunes_lookup minAppVersion: $minAppVersion');
  print('itunes_lookup releaseNotes: $releaseNotes');
  print('itunes_lookup trackViewUrl: $trackViewUrl');
  print('itunes_lookup version: $version');

  print('itunes_lookup all results:\n$results');
  return;
}
