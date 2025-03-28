import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:itq_utils/itq_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

String dirPath = "/storage/emulated/0/Documents";

/// Make any variable nullable
T? makeNullable<T>(T? value) => value;

/// Enum for page route
enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

/// has match return bool for pattern matching
bool hasMatch(String? s, String p) {
  return (s == null) ? false : RegExp(p).hasMatch(s);
}

/// Toast for default time
void toast(
  String? value, {
  ToastGravity? gravity,
  length = Toast.LENGTH_SHORT,
  Color? bgColor,
  Color? textColor,
  bool print = false,
}) {
  if (value.validate().isEmpty || isLinux) {
    log(value);
  } else {
    Fluttertoast.showToast(
      msg: value.validate(),
      gravity: gravity,
      toastLength: length,
      backgroundColor: bgColor ?? defaultToastBackgroundColor,
      textColor: textColor ?? defaultToastTextColor,
    );
    if (print) log(value);
  }
}

/// Toast with Context
void toasty(
  BuildContext context,
  String? text, {
  ToastGravity? gravity,
  length = Toast.LENGTH_SHORT,
  Color? bgColor,
  Color? textColor,
  bool print = false,
  bool removeQueue = false,
  Duration duration = const Duration(seconds: 2),
  BorderRadius? borderRadius,
  EdgeInsets? padding,
}) {
  FToast().init(context);
  if (removeQueue) FToast().removeCustomToast();

  FToast().showToast(
    child: Container(
      child: Text(text.validate(),
          style: boldTextStyle(color: textColor ?? defaultToastTextColor)),
      decoration: BoxDecoration(
        color: bgColor ?? defaultToastBackgroundColor,
        boxShadow: defaultBoxShadow(),
        borderRadius: borderRadius ?? defaultToastBorderRadiusGlobal,
      ),
      padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 30),
    ),
    gravity: gravity ?? defaultToastGravityGlobal,
    toastDuration: duration,
  );
  if (print) log(text);
}

/// Toast for long period of time
void toastLong(
  String? value, {
  BuildContext? context,
  ToastGravity gravity = ToastGravity.BOTTOM,
  length = Toast.LENGTH_LONG,
  Color? bgColor,
  Color? textColor,
  bool print = false,
}) {
  toast(
    value,
    gravity: gravity,
    bgColor: bgColor,
    textColor: textColor,
    length: length,
    print: print,
  );
}

/// Show SnackBar
void snackBar(
  BuildContext context, {
  String title = '',
  Widget? content,
  SnackBarAction? snackBarAction,
  Function? onVisible,
  Color? textColor,
  Color? backgroundColor,
  EdgeInsets? margin,
  EdgeInsets? padding,
  Animation<double>? animation,
  double? width,
  ShapeBorder? shape,
  Duration? duration,
  SnackBarBehavior? behavior,
  double? elevation,
}) {
  if (title.isEmpty && content == null) {
    log('SnackBar message is empty');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        action: snackBarAction,
        margin: margin,
        animation: animation,
        width: width,
        shape: shape,
        duration: duration ?? 4.seconds,
        behavior: margin != null ? SnackBarBehavior.floating : behavior,
        elevation: elevation,
        onVisible: onVisible?.call(),
        content: content ??
            Padding(
              padding: padding ?? EdgeInsets.symmetric(vertical: 4),
              child: Text(
                title,
                style: primaryTextStyle(color: textColor ?? Colors.white),
              ),
            ),
      ),
    );
  }
}

/// Hide soft keyboard
void hideKeyboard(context) => FocusScope.of(context).requestFocus(FocusNode());

/// Returns a string from Clipboard
Future<String> paste() async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data?.text?.toString() ?? "";
}

/// Returns a string from Clipboard
Future<dynamic> pasteObject() async {
  ClipboardData? data = await Clipboard.getData('text/plain');
  return data;
}

/// Enum for Link Provider
enum LinkProvider {
  PLAY_STORE,
  APPSTORE,
  FACEBOOK,
  INSTAGRAM,
  LINKEDIN,
  TWITTER,
  YOUTUBE,
  REDDIT,
  TELEGRAM,
  WHATSAPP,
  FB_MESSENGER,
  GOOGLE_DRIVE
}

/// Use getSocialMediaLink function to build social media links
String getSocialMediaLink(LinkProvider linkProvider, {String url = ''}) {
  switch (linkProvider) {
    case LinkProvider.PLAY_STORE:
      return "$playStoreBaseURL$url";
    case LinkProvider.APPSTORE:
      return "$appStoreBaseURL$url";
    case LinkProvider.FACEBOOK:
      return "$facebookBaseURL$url";
    case LinkProvider.INSTAGRAM:
      return "$instagramBaseURL$url";
    case LinkProvider.LINKEDIN:
      return "$linkedinBaseURL$url";
    case LinkProvider.TWITTER:
      return "$twitterBaseURL$url";
    case LinkProvider.YOUTUBE:
      return "$youtubeBaseURL$url";
    case LinkProvider.REDDIT:
      return "$redditBaseURL$url";
    case LinkProvider.TELEGRAM:
      return "$telegramBaseURL$url";
    case LinkProvider.FB_MESSENGER:
      return "$facebookMessengerURL$url";
    case LinkProvider.WHATSAPP:
      return "$whatsappURL$url";
    case LinkProvider.GOOGLE_DRIVE:
      return "$googleDriveURL$url";
  }
}

/// Converts degrees to radians.
const double degrees2Radians = pi / 180.0;

/// Converts degrees to radians.
double radians(double degrees) => degrees * degrees2Radians;

/// Executes a function after the build is created.
void afterBuildCreated(Function()? onCreated) {
  makeNullable(SchedulerBinding.instance)!
      .addPostFrameCallback((_) => onCreated?.call());
}

/// Widget wrapper for animated dialog transitions.
Widget dialogAnimatedWrapperWidget({
  required Animation<double> animation,
  required Widget child,
  required DialogAnimation dialogAnimation,
  required Curve curve,
}) {
  switch (dialogAnimation) {
    // Animation for rotating the dialog.
    case DialogAnimation.ROTATE:
      return Transform.rotate(
        angle: radians(animation.value * 360),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    // Animation for sliding the dialog from top to bottom.
    case DialogAnimation.SLIDE_TOP_BOTTOM:
      final curvedValue = curve.transform(animation.value) - 1.0;

      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 300, 0.0),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    // Animation for scaling the dialog.
    case DialogAnimation.SCALE:
      return Transform.scale(
        scale: animation.value,
        child: FadeTransition(opacity: animation, child: child),
      );

    // Animation for sliding the dialog from bottom to top.
    case DialogAnimation.SLIDE_BOTTOM_TOP:
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: curve))
            .animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    // Animation for sliding the dialog from left to right.
    case DialogAnimation.SLIDE_LEFT_RIGHT:
      return SlideTransition(
        position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: curve))
            .animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    // Animation for sliding the dialog from right to left.
    case DialogAnimation.SLIDE_RIGHT_LEFT:
      return SlideTransition(
        position: Tween(begin: Offset(-1, 0), end: Offset.zero)
            .chain(CurveTween(curve: curve))
            .animate(animation),
        child: Opacity(
          opacity: animation.value,
          child: FadeTransition(opacity: animation, child: child),
        ),
      );

    // Default fade animation.
    case DialogAnimation.DEFAULT:
      return FadeTransition(opacity: animation, child: child);
  }
}

/// Builds a page route with the specified animation.
Route<T> buildPageRoute<T>(
  Widget child,
  PageRouteAnimation? pageRouteAnimation,
  Duration? duration,
) {
  if (pageRouteAnimation != null) {
    if (pageRouteAnimation == PageRouteAnimation.Fade) {
      // Fade animation for page route.
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Rotate) {
      // Rotation animation for page route.
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return RotationTransition(
              child: child, turns: ReverseAnimation(anim));
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Scale) {
      // Scale animation for page route.
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return ScaleTransition(child: child, scale: anim);
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.Slide) {
      // Slide animation for page route.
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return SlideTransition(
            child: child,
            position: Tween(
              begin: Offset(1.0, 0.0),
              end: Offset(0.0, 0.0),
            ).animate(anim),
          );
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    } else if (pageRouteAnimation == PageRouteAnimation.SlideBottomTop) {
      // Slide from bottom to top animation for page route.
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => child,
        transitionsBuilder: (c, anim, a2, child) {
          return SlideTransition(
            child: child,
            position: Tween(
              begin: Offset(0.0, 1.0),
              end: Offset(0.0, 0.0),
            ).animate(anim),
          );
        },
        transitionDuration: duration ?? pageRouteTransitionDurationGlobal,
      );
    }
  }
  // Default page route.
  return MaterialPageRoute<T>(builder: (_) => child);
}

/// Provides dynamic padding for app buttons based on the context.
EdgeInsets dynamicAppButtonPadding(BuildContext context) {
  if (context.isDesktop()) {
    return EdgeInsets.symmetric(vertical: 20, horizontal: 20);
  } else if (context.isTablet()) {
    return EdgeInsets.symmetric(vertical: 16, horizontal: 16);
  } else {
    return EdgeInsets.symmetric(vertical: 14, horizontal: 16);
  }
}

/// Enum representing types of bottom sheet dialogs.
enum BottomSheetDialog { Dialog, BottomSheet }

/// Shows a bottom sheet or a dialog based on the specified type.
Future<dynamic> showBottomSheetOrDialog({
  required BuildContext context,
  required Widget child,
  BottomSheetDialog bottomSheetDialog = BottomSheetDialog.Dialog,
}) {
  if (bottomSheetDialog == BottomSheetDialog.BottomSheet) {
    // Show a bottom sheet.
    return showModalBottomSheet(context: context, builder: (_) => child);
  } else {
    // Show a dialog.
    return showInDialog(context, builder: (_) => child);
  }
}

/// Retrieves package information asynchronously.
Future<PackageInfoData> getPackageInfo() async {
  if (isAndroid || isIOS) {
    var data = await invokeNativeMethod(channelName, 'packageInfo');

    if (data != null && data is Map) {
      // Parse package info data from native method result.
      return PackageInfoData(
        appName: data['appName'],
        packageName: data['packageName'],
        versionName: data['versionName'],
        versionCode: data['versionCode'],
        androidSDKVersion: data['androidSDKVersion'],
      );
    } else {
      // Throw an error if data retrieval fails.
      throw errorSomethingWentWrong;
    }
  } else {
    // Return empty package info for unsupported platforms.
    return PackageInfoData();
  }
}

/// Get Package Name
Future<String> getPackageName() async {
  return (await getPackageInfo()).packageName.validate();
}

/// mailto: function to open native email app
Uri mailTo({
  required List<String> to,
  String subject = '',
  String body = '',
  List<String> cc = const [],
  List<String> bcc = const [],
}) {
  String subject0 = '';
  if (subject.isNotEmpty) subject0 = '&subject=$subject';

  String body0 = '';
  if (body.isNotEmpty) body0 = '&body=$body';

  String cc0 = '';
  if (cc.isNotEmpty) cc0 = '&cc=${cc.join(',')}';

  String bcc0 = '';
  if (bcc.isNotEmpty) bcc0 = '&bcc=${bcc.join(',')}';

  return Uri(
    scheme: 'mailto',
    query: 'to=${to.join(',')}$subject0$body0$cc0$bcc0',
  );
}

/// Use this if you want to skip splash delay above Android 12
Future<void> splashDelay({int second = 2}) async {
  if (await isAndroid12Above()) {
    await 300.milliseconds.delay;
  } else {
    await second.seconds.delay;
  }
}


/// Convert Time Format
String formatLocalTime(int timeNum) =>
    timeNum < 10 ? "0$timeNum" : timeNum.toString();

/// Calculate Age
String calculateAge(String birthDateString) {
  String datePattern = "dd-MM-yyyy";
  DateTime today = DateFormat(datePattern).parse(DateTime.now().toString());
  DateTime birthDate = DateFormat(datePattern).parse(birthDateString);
  String year = (today.year - birthDate.year).toString();
  String month = (today.month - birthDate.month).abs().toString();
  return '$year year, $month months';
}

/// Validate Text Input Field
bool validateTextInputField(
    BuildContext context, TextEditingController controller, String fieldName,
    {FocusNode? focusNode}) {
  if (controller.text.isEmpty) {
    if (focusNode != null) {
      focusNode.requestFocus();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$fieldName can\'t be empty'),
    ));
    return false;
  }
  return true;
}

/// Validate Text Field or Dropdown Value
bool validateTextField(BuildContext context, var controller, String fieldName,
    {FocusNode? focusNode}) {
  if (controller.isEmpty) {
    if (focusNode != null) {
      focusNode.requestFocus();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$fieldName can\'t be empty'),
    ));
    return false;
  }
  return true;
}

/// Lies Between Times
bool liesBetweenTimes(String sTime, String eTime) {
  DateTime now = DateTime.now();
  var format = DateFormat("HH:mm");
  var startTime = format.parse(sTime);
  var endTime = format.parse(eTime);
  startTime =
      DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
  endTime =
      DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
  if (now.isAfter(startTime) && now.isBefore(endTime)) {
    return true;
  }
  return false;
}

/// Check Age if age is greater than 18 year or not
bool checkMature(String birthDateString) {
  String datePattern = "dd-MM-yyyy";
  DateTime today = DateTime.now();
  DateTime birthDate = DateFormat(datePattern).parse(birthDateString);
  // Date to check but moved 18 years ahead
  DateTime adultDate = DateTime(
    birthDate.year + 18,
    birthDate.month,
    birthDate.day,
  );
  return adultDate.isBefore(today);
}

/// Time Difference
String timeDifference(String startTime, String endTime) {
  var format = DateFormat("HH:mm");
  DateTime now = DateTime.now();
  var sTime = format.parse(startTime);
  var eTime = format.parse(endTime);
  sTime = DateTime(now.year, now.month, now.day, sTime.hour, sTime.minute);
  eTime = DateTime(now.year, now.month, now.day, eTime.hour, eTime.minute);
  if (sTime.isAfter(eTime)) {
    return "${sTime.difference(eTime).inMinutes}";
  } else {
    return "${eTime.difference(sTime).inMinutes}";
  }
}


RoundedRectangleBorder itqRoundedRectangleShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(8),
);

/// returns gradient
Gradient gradientColor(
    [Color secondGradientColor = textSecondaryColor,
      Color firstGradientColor = textPrimaryColor,
      AlignmentGeometry begin = Alignment.topCenter,
      AlignmentGeometry end = Alignment.bottomCenter]) {
  return LinearGradient(
    colors: [
      secondGradientColor,
      firstGradientColor,
    ],
    //stops: [0, 1],
    begin: begin,
    end: end,
  );
}

showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text(
          "Warning",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to exit the app?",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Continue
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}

Future<T?> openDialog<T>({
  required BuildContext context,
  bool barrierDismissible = true,
  Widget? child,
  WidgetBuilder? builder,
}) {
  assert(child == null || builder == null);
  assert(debugCheckHasMaterialLocalizations(context));

  final ThemeData theme = Theme.of(
    context,
  );
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = child ?? Builder(builder: builder!);
      return Builder(builder: (BuildContext context) {
        return Theme(data: theme, child: pageChild);
      });
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: _buildTransition,
  );
}

Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  return ScaleTransition(
    scale: CurvedAnimation(
      parent: animation,
      curve: Curves.bounceIn,
      reverseCurve: Curves.bounceIn,
    ),
    child: child,
  );
}

// String Extensions
extension StringCasingExtension on String {
  /// Word Capitalized
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// Title Capitalized
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

// Indexed Map Extensions
extension IndexedIterable<E> on Iterable<E> {
  /// Indexed Map
  Iterable<T> indexedMap<T>(T Function(E element, int index) f) {
    var index = 0;
    return map((e) => f(e, index++));
  }
}

// File Extensions
extension FileSaveUtils on void {
  /// Save PDF Documents
  savePdfDocuments(
      {required String name,
        required Uint8List fileBytes,
        String customDirectoryName = "Documents",
        BuildContext? context}) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = Platform.isAndroid
        ? dirPath
        : "${appDocDirectory.path}/$customDirectoryName";
    try {
      bool checkPermission = await Permission.accessMediaLocation.isGranted;
      if (checkPermission) {
        File pdfDoc = File(
            "$path/${DateFormat('yy-HH-mm-ss').format(DateTime.now())}-$name");
        await pdfDoc.writeAsBytes(fileBytes);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(
              "File saved successfully to $path/${DateFormat('yy-HH-mm-ss').format(DateTime.now())}-$name"
                  "File saved successfully to $path/${DateFormat('yy-HH-mm-ss').format(DateTime.now())}-$name"),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
          content: Text("Storage permission denied !, please try again!"),
        ));
        var status = await Permission.accessMediaLocation.status;
        if (!status.isGranted) {
          await Permission.accessMediaLocation.request();
        }
      }
    } on FileSystemException catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text("ERROR: ${e.message} $path/$name"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text("ERROR: $e"),
      ));
    }
  }

  /// Save Network Image
  saveNetworkImage(
      {required String name,
        required String url,
        String customDirectoryName = "Documents",
        BuildContext? context}) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = Platform.isAndroid
        ? dirPath
        : "${appDocDirectory.path}/$customDirectoryName";

    try {
      var response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      bool checkPermission = await Permission.mediaLibrary.isGranted;
      if (checkPermission) {
        File file = File(
            "$path/${DateFormat('yy-HH-mm-ss').format(DateTime.now())}-$name");
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(
              "File saved successfully to $path/${DateFormat('yy-HH-mm-ss').format(DateTime.now())}-$name"),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
          content: Text("Storage permission denied !, please try again!"),
        ));
        var status = await Permission.mediaLibrary.status;
        if (!status.isGranted) {
          await Permission.mediaLibrary.request();
        }
      }
    } on FileSystemException catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text("ERROR: ${e.message} $path/$name"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text("ERROR: $e"),
      ));
    }
  }
}