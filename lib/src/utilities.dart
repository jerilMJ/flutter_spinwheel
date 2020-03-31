import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'named_image.dart';

class Utilities {
// Loading images from assetbundle using path from details in [imageItems].
  static void loadImages(List<NamedImage> imageItems, BuildContext context,
      List<ui.Image> loadedImages, Function notify, State state) async {
    ByteData byteData;
    Uint8List buffer;
    ui.Codec codec;
    ui.FrameInfo frameInfo;

    for (NamedImage namedImage in imageItems) {
      if (state.mounted) {
        byteData = await DefaultAssetBundle.of(context)
            .load(namedImage.path)
            .catchError((error) {
          throw FlutterError(
              'Error while loading image at ${namedImage.path}.. Check if the asset is'
              'specified in pubspec.yaml and that the path is correct. Error info: $error');
        });

        buffer = Uint8List.view(byteData.buffer);
        codec = await ui.instantiateImageCodec(buffer);

        frameInfo = await codec.getNextFrame();
        loadedImages.add(frameInfo.image);
      }
    }
    if (state.mounted) notify();
  }

  static void shiftItemsLeft(List<dynamic> items) {
    items.add(items.removeAt(0));
  }

  static void shiftItemsRight(List<dynamic> items) {
    items.insert(0, items.removeLast());
  }
}
