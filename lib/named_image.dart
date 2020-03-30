import 'package:flutter/material.dart';

/// Custom class used with Spinwheel to distinguish between images
/// and customize individual settings of images.
class NamedImage {
  /// Take note that [path] should be set to the full path name just like what
  /// you would write in pubspec.yaml.
  ///
  /// IMPORTANT!! The [name] field is the field that will be returned in the callback
  /// in the [onChanged] field of the Spinheel class.
  ///
  /// Change [offsetX] (default: 1) to horizontally offset.
  /// Change [offsetY] (default: 1.5) to vertically offset.
  /// [fit] describes the bounding box of the image.
  NamedImage({
    @required this.path,
    @required this.name,
    this.offsetX = 1,
    this.offsetY = 1.5,
    this.fit = BoxFit.cover,
    this.filter,
  });

  /// Path to the image file (same as what you would describe in pubspec.yaml).
  String path;

  /// Name of the image to be used as callback value.
  String name;

  /// Horizontally offset image.
  double offsetX;

  /// Vertically offset image.
  double offsetY;

  /// Bounding box of the image.
  BoxFit fit;

  /// Filter to use on image. By default, none. Refer to ColorFilter doc
  /// information on how to use.
  ColorFilter filter;
}
