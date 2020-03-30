import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../named_image.dart';

// Loading images from assetbundle using path from details in [imageItems].
void loadImages(List<NamedImage> imageItems, BuildContext context,
    List<ui.Image> loadedImages, Function notify) async {
  for (NamedImage namedImage in imageItems) {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load(namedImage.path)
        .catchError((error) {
      throw FlutterError(
          'Error while loading image at ${namedImage.path}.. Check if the asset is'
          'specified in pubspec.yaml and that the path is correct. Error info: $error');
    });

    Uint8List buffer = Uint8List.view(byteData.buffer);
    ui.Codec codec = await ui.instantiateImageCodec(buffer);

    ui.FrameInfo frameInfo = await codec.getNextFrame();
    loadedImages.add(frameInfo.image);
  }
  notify();
}

void shiftItemsLeft(List<dynamic> items) {
  items.add(items.removeAt(0));
}

void shiftItemsRight(List<dynamic> items) {
  items.insert(0, items.removeLast());
}
