import 'package:flutter/services.dart';

class LoadSvgUseCase {
  Future<String> call(String path, String? package) async {
    return await rootBundle.loadString(
      package != null ? 'packages/$package/$path' : path,
    );
  }
}
