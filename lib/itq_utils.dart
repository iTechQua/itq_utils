library itq_utils;

export 'package:flutter/material.dart'
    show
    TextTheme,
    ThemeMode,
    RouteFactory,
    GenerateAppTitle,
    InitialRouteListFactory;
export 'package:flutter/widgets.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itq_utils/itq_utils.dart';

export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:shared_preferences/shared_preferences.dart';

export 'src/custom_paints/google_logo_painter.dart';
export 'src/chatgpt/chat_gpt.dart';
export 'src/chatgpt/chat_gpt_component.dart';
export 'src/chatgpt/chat_gpt_strings.dart';
export 'src/chatgpt/chat_gpt_models.dart';
export 'src/deprecated_widgets.dart';
export 'src/extensions/bool_extensions.dart';
export 'src/extensions/color_extensions.dart';
export 'src/extensions/context_extensions.dart';
export 'src/extensions/date_time_extensions.dart';
export 'src/extensions/device_extensions.dart';
export 'src/extensions/double_extensions.dart';
export 'src/extensions/duration_extensions.dart';
export 'src/extensions/int_extensions.dart';
export 'src/extensions/list_extensions.dart';
export 'src/extensions/map_extensions.dart';
export 'src/extensions/num_extensions.dart';
export 'src/extensions/scroll_extensions.dart';
export 'src/extensions/string_extensions.dart';
export 'src/extensions/widget_extensions.dart';
export 'src/live_stream.dart';
export 'src/models/language_data_model.dart';
export 'src/models/package_info_model.dart';
export 'src/models/walkthrough_model.dart';
export 'src/utils/alert_dialog.dart';
export 'src/utils/app_bar.dart';
export 'src/utils/app_stack_loader.dart';
export 'src/utils/after_layout.dart';
export 'src/utils/colors.dart';
export 'src/utils/common.dart';
export 'src/utils/confirmation_dialog.dart';
export 'src/utils/constants.dart';
export 'src/utils/debouncer.dart';
export 'src/utils/decorations.dart';
export 'src/utils/enums.dart';
export 'src/utils/jwt_decoder.dart';
export 'src/utils/line_icons.dart';
export 'src/utils/get_ip_address.dart';
export 'src/utils/network_utils.dart';
export 'src/utils/pattern.dart';
export 'src/utils/shared_pref.dart';
export 'src/utils/size_config.dart';
export 'src/utils/system_utils.dart';
export 'src/utils/text_styles.dart';
export 'src/utils/time_formatter.dart';
export 'src/widgets/animatedList/animated_configurations.dart';
export 'src/widgets/animatedList/animated_list_view.dart';
export 'src/widgets/animatedList/animated_scroll_view.dart';
export 'src/widgets/animatedList/animated_wrap.dart';
export 'src/widgets/animatedText/animated_text.dart';
export 'src/widgets/animatedText/type_writer_animation.dart';
export 'src/widgets/app_button.dart';
export 'src/widgets/app_text_field.dart';
export 'src/widgets/blur_widget.dart';
export 'src/widgets/circular_progress_gradient.dart';
export 'src/widgets/dot_indicator.dart';
export 'src/widgets/dotted_border_widget.dart';
export 'src/widgets/double_press_back_widget.dart';
export 'src/widgets/gradient_border.dart';
export 'src/widgets/horizontal_list.dart';
export 'src/widgets/hover_widget.dart';
export 'src/widgets/hyper_link_widget.dart';
export 'src/widgets/language_list_widget.dart';
export 'src/widgets/loader_widget.dart';
export 'src/widgets/marquee_widget.dart';
export 'src/widgets/no_data_widget.dart';
export 'src/widgets/overlay_custom_widget.dart';
export 'src/widgets/otp_text_field.dart';
export 'src/widgets/placeholder_widget.dart';
export 'src/widgets/rating_bar_widget.dart';
export 'src/widgets/read_more_text.dart';
export 'src/widgets/responsive_widget.dart';
export 'src/widgets/restart_app_widget.dart';
export 'src/widgets/rich_text_widget.dart';
export 'src/widgets/rounded_checkbox_widget.dart';
export 'src/widgets/setting_item_widget.dart';
export 'src/widgets/setting_section.dart';
export 'src/widgets/size_listener.dart';
export 'src/widgets/snap_helper_widget.dart';
export 'src/widgets/text_icon_widget.dart';
export 'src/widgets/theme_widget.dart';
export 'src/widgets/timer_widget.dart';
export 'src/widgets/ul_widget.dart';
export 'src/widgets/version_info_widget.dart';
export 'src/widgets/widgets.dart';

export 'src/emergent/emergent_colors.dart';
export 'src/emergent/emergent_box_shape.dart';
export 'src/emergent/emergent_shape.dart';
export 'src/emergent/emergent_light_source.dart';
export 'src/emergent/shape/emergent_path_provider.dart';
export 'src/emergent/theme/emergent_app_bar.dart';
export 'src/emergent/theme/emergent_theme.dart';
export 'src/emergent/theme/emergent_decoration_theme.dart';
export 'src/emergent/widget/emergent_app.dart';
export 'src/emergent/widget/emergent_app_bar.dart';
export 'src/emergent/widget/emergent_back_button.dart';
export 'src/emergent/widget/emergent_background.dart';
export 'src/emergent/widget/emergent_button.dart';
export 'src/emergent/widget/emergent_checkbox.dart';
export 'src/emergent/widget/emergent_close_button.dart';
export 'src/emergent/widget/emergent_container.dart';
export 'src/emergent/widget/emergent_icon.dart';
export 'src/emergent/widget/emergent_indicator.dart';
export 'src/emergent/widget/emergent_progress.dart';
export 'src/emergent/widget/emergent_radio.dart';
export 'src/emergent/widget/emergent_range_slider.dart';
export 'src/emergent/widget/emergent_slider.dart';
export 'src/emergent/widget/emergent_switch.dart';
export 'src/emergent/widget/emergent_text.dart';
export 'src/emergent/widget/emergent_toggle.dart';
export 'src/emergent/widget/emergent_floating_action_button.dart';

export 'src/upgrade/itq_alert_style_widget.dart';
export 'src/upgrade/itq_app_cast.dart';
export 'src/upgrade/itq_itunes_search_api.dart';
export 'src/upgrade/itq_play_store_search_api.dart';
export 'src/upgrade/itq_upgrade_new_version_alert.dart';
export 'src/upgrade/itq_upgrade_new_version_card.dart';
export 'src/upgrade/itq_upgrade_new_version_device.dart';
export 'src/upgrade/itq_upgrade_new_version_messages.dart';
export 'src/upgrade/itq_upgrade_new_version_os.dart';
export 'src/upgrade/itq_upgrade_new_version.dart';

export 'src/utils/alert/dialog_button.dart';
export 'src/utils/alert/alert_style.dart';
export 'src/utils/alert/itq_alert.dart';

export 'src/dropdown_search/dropdown_search_form_field.dart';
export 'src/dropdown_search/properties/bottom_sheet_props.dart';
export 'src/dropdown_search/properties/clear_button_props.dart';
export 'src/dropdown_search/properties/dialog_props.dart';
export 'src/dropdown_search/properties/dropdown_button_props.dart';
export 'src/dropdown_search/properties/dropdown_decorator_props.dart';
export 'src/dropdown_search/properties/favorite_item_props.dart';
export 'src/dropdown_search/properties/icon_button_props.dart';
export 'src/dropdown_search/properties/list_view_props.dart';
export 'src/dropdown_search/properties/menu_props.dart';
export 'src/dropdown_search/properties/modal_bottom_sheet_props.dart';
export 'src/dropdown_search/properties/popup_props.dart';
export 'src/dropdown_search/properties/text_field_props.dart';


//region Global variables - This variables can be changed.
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
double textBoldSizeGlobal = 16;
double textPrimarySizeGlobal = 16;
double textSecondarySizeGlobal = 14;
String? fontFamilyBoldGlobal;
String? fontFamilyPrimaryGlobal;

String? fontFamilySecondaryGlobal;
FontWeight fontWeightBoldGlobal = FontWeight.bold;
FontWeight fontWeightPrimaryGlobal = FontWeight.normal;
FontWeight fontWeightSecondaryGlobal = FontWeight.normal;

Color appBarBackgroundColorGlobal = Colors.white;
Color appButtonBackgroundColorGlobal = Colors.white;
Color defaultAppButtonTextColorGlobal = textPrimaryColorGlobal;
double defaultAppButtonRadius = 8.0;
double defaultAppButtonElevation = 4.0;
double defaultAppButtonFocusElevation = 4.0;
double defaultAppButtonHighlightElevation = 4.0;
double defaultAppButtonHoverElevation = 4.0;
bool enableAppButtonScaleAnimationGlobal = true;
int? appButtonScaleAnimationDurationGlobal;
ShapeBorder? defaultAppButtonShapeBorder;

Color defaultLoaderBgColorGlobal = Colors.white;
Color? defaultLoaderAccentColorGlobal;

Color? defaultInkWellSplashColor;
Color? defaultInkWellHoverColor;
Color? defaultInkWellHighlightColor;
double? defaultInkWellRadius;

Color shadowColorGlobal = Colors.grey.withOpacity(0.2);
int defaultElevation = 4;
double defaultRadius = 8.0;
double defaultBlurRadius = 4.0;
double defaultSpreadRadius = 1.0;
double defaultAppBarElevation = 4.0;

double? maxScreenWidth;

double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;

int passwordLengthGlobal = 6;

late SharedPreferences sharedPreferences;

ShapeBorder? defaultDialogShape;

String defaultCurrencySymbol = currencyRupee;

LanguageDataModel? selectedLanguageDataModel;
List<LanguageDataModel> localeLanguageList = [];

/// If forceEnableDebug if true, you will be able to see log in the logcat in release build also.
/// By default, your log will not seen in logcat in release mode.
bool forceEnableDebug = false;

// Toast Config
Color defaultToastBackgroundColor = Colors.grey.shade200;
Color defaultToastTextColor = Colors.black;
ToastGravity defaultToastGravityGlobal = ToastGravity.CENTER;
BorderRadius defaultToastBorderRadiusGlobal = radius(30);

PageRouteAnimation? pageRouteAnimationGlobal;
Duration pageRouteTransitionDurationGlobal = 400.milliseconds;

//ChatGpt Key
String chatGPTAPIkey = '';
ChatGPTConfig chatGPTConfigGlobal = ChatGPTConfig();

//endregion

const channelName = 'itq_utils';
final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;

LiveStream liveStream = LiveStream();

// Must be initialize before using shared preference
Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  sharedPreferences = await SharedPreferences.getInstance();

  defaultAppButtonShapeBorder =
      RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius));

  defaultDialogShape = dialogShape(defaultDialogBorderRadius);

  localeLanguageList = aLocaleLanguageList ?? [];

  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: defaultLanguage);
}

/// itq_utils class
class ITQUtils {
  static const MethodChannel _channel = MethodChannel(channelName);

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

/// Redirect to given widget without context
Future<T?> push<T>(
  Widget widget, {
  bool isNewTask = false,
  PageRouteAnimation? pageRouteAnimation,
  Duration? duration,
}) async {
  if (isNewTask) {
    return await Navigator.of(getContext).pushAndRemoveUntil(
      buildPageRoute(
          widget, pageRouteAnimation ?? pageRouteAnimationGlobal, duration),
      (route) => false,
    );
  } else {
    return await Navigator.of(getContext).push(
      buildPageRoute(
          widget, pageRouteAnimation ?? pageRouteAnimationGlobal, duration),
    );
  }
}

/// Dispose current screen or close current dialog
void pop([Object? object]) {
  if (Navigator.canPop(getContext)) Navigator.pop(getContext, object);
}
