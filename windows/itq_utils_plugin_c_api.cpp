#include "include/itq_utils/itq_utils_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "i_t_q_utils_plugin.h"

void ItqUtilsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  itq_utils::ItqUtilsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
