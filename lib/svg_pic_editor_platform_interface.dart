import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'svg_pic_editor_method_channel.dart';

abstract class SvgPicEditorPlatform extends PlatformInterface {
  /// Constructs a SvgPicEditorPlatform.
  SvgPicEditorPlatform() : super(token: _token);

  static final Object _token = Object();

  static SvgPicEditorPlatform _instance = MethodChannelSvgPicEditor();

  /// The default instance of [SvgPicEditorPlatform] to use.
  ///
  /// Defaults to [MethodChannelSvgPicEditor].
  static SvgPicEditorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SvgPicEditorPlatform] when
  /// they register themselves.
  static set instance(SvgPicEditorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
