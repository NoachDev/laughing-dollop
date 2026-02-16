//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <srt_dart/srt_dart_plugin.h>
#include <srt_flutter_libs/srt_flutter_libs_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) srt_dart_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SrtDartPlugin");
  srt_dart_plugin_register_with_registrar(srt_dart_registrar);
  g_autoptr(FlPluginRegistrar) srt_flutter_libs_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SrtFlutterLibsPlugin");
  srt_flutter_libs_plugin_register_with_registrar(srt_flutter_libs_registrar);
}
