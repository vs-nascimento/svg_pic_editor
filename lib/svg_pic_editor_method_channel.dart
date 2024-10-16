import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'svg_pic_editor_platform_interface.dart';

/// An implementation of [SvgPicEditorPlatform] that uses method channels.
class MethodChannelSvgPicEditor extends SvgPicEditorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('svg_pic_editor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
