import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../named_image.dart';
import 'painter_presets.dart';

class SpinwheelPainter extends CustomPainter {
  /// List of menu options as strings.
  final List<dynamic> _items;
  final int _itemCount;

  /// Boolean that determines whether spinner shoudl rotate clockwise or counter-clockwise.
  final bool _clockwise;

  /// Function that shifts the contents of the given list of options
  /// depending on clockwise or counter-clockwise panning.
  final Function _shifter;

  final Animation _rotationAnimation;

  /// The index of the sector that acts as the selection sector (highlighted).
  final int _selectSector;

  /// This field is used to prevent multiple shifts that may occur when the animation
  /// emits its values i.e, one rotation may result in two shifts if this field is not
  /// present.
  int _count = 0;

  final double _orientation;

  // Same functionality for below fields as in SpinnerWheel
  Paint _wheelPaint;
  Paint _borderPaint;
  Paint _sectorDividerPaint;
  Paint _centerPiecePaint;
  Paint _highlightPaint;
  Paint _shutterPaint;

  final bool _shouldDrawDividers;
  final bool _shouldDrawBorder;
  final bool _shouldDrawCenterPiece;
  final bool _shouldHighlight;
  final bool _hideOthers;
  final bool _highlightWhileRotating;

  final bool _isImageList;

  // Angle occupied by each sector.
  final double _sectorAngle;

  List<ui.Image> _loadedImages;

  SpinwheelPainter(
    this._itemCount,
    this._isImageList,
    this._items,
    this._loadedImages,
    this._clockwise,
    this._shifter,
    this._rotationAnimation,
    this._selectSector,
    this._shouldDrawDividers,
    this._shouldDrawBorder,
    this._shouldDrawCenterPiece,
    this._hideOthers,
    this._shouldHighlight,
    this._highlightWhileRotating,
    this._wheelPaint,
    this._borderPaint,
    this._sectorDividerPaint,
    this._centerPiecePaint,
    this._highlightPaint,
    this._shutterPaint,
    this._orientation,
  ) : _sectorAngle = 2 * pi / _itemCount {
    setPresets();
  }

  void setPresets() {
    PainterPresets presets = PainterPresets();
    _wheelPaint = _wheelPaint ?? presets.wheelPaintPreset;
    _borderPaint = _borderPaint ?? presets.borderPaintPreset;
    _sectorDividerPaint =
        _sectorDividerPaint ?? presets.sectorDividerPaintPreset;
    _centerPiecePaint = _centerPiecePaint ?? presets.centerPiecePaintPreset;
    _highlightPaint = _highlightPaint ?? presets.highlightPaintPreset;
    _shutterPaint = _shutterPaint ?? presets.shutterPaintPreset;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_isImageList && _loadedImages.length != _items.length) return;

    // Calculating common constraints, offsets and angles.
    final width = size.width;
    final height = size.height;

    final radius = width / 2;
    final circleCenter = Offset(width / 2, height / 2);

    // Angles at which each consecutive sector will be drawn on the wheel.
    final sectorOffsetAngles = [
      for (int i = 0; i < _itemCount; i++) _sectorAngle * i
    ];

    // Angular offset for each string of text in the provided list of options.
    // 2pi radian (360°) is temporarily added for calculating textRotation of the
    // last element in the list of options.
    sectorOffsetAngles.add(2 * pi);
    final itemRotations = [
      for (int i = 0; i < _itemCount; i++)
        (sectorOffsetAngles[i] + sectorOffsetAngles[i + 1]) / 2
    ];
    sectorOffsetAngles.remove(2 * pi);

    // Value used for rotation animation.
    double rot = _sectorAngle;

    // If counter-clockwise, reverse the direction of rotation.
    if (!_clockwise) {
      rot = -_sectorAngle;
    }

    // Function where most of the painting occurs.
    paintSpinner(canvas, width, height, radius, circleCenter, rot,
        sectorOffsetAngles, itemRotations);
  }

  paintSpinner(
      Canvas canvas,
      double width,
      double height,
      double radius,
      Offset circleCenter,
      double rot,
      List<double> sectorOffsetAngles,
      List<double> itemRotations) {
    canvas.save();
    // Painting the big circle/wheel.
    drawWheel(canvas, radius, circleCenter);

    if (_shouldDrawBorder) drawBorder(canvas, radius, circleCenter);

    // This line of code animates the rotation of the wheel
    // by taking in the animation (param) value and multiplying it
    // with the sector angle. As it is multiplied by a fixed angle,
    // the rotation is locked to only multiples of this angle.

    // Rotating to an appropriate orientation.
    rotateCanvas(canvas, radius, pi * 1.5);

    // Custom orientation provided by user.
    rotateCanvas(canvas, radius, _orientation);

    // Rotation animation takes place here.
    rotateCanvas(canvas, radius, rot * _rotationAnimation.value);

    // Drawing components according to settings provided.
    if (_isImageList && _loadedImages != null)
      drawImages(
          canvas, radius, circleCenter, sectorOffsetAngles, itemRotations);
    else if (!_isImageList)
      drawTexts(canvas, radius, circleCenter, itemRotations);

    if (_shouldDrawDividers)
      drawSectorDividers(canvas, radius, circleCenter, sectorOffsetAngles);

    canvas.restore();

    if (_shouldHighlight)
      drawSelectionSector(canvas, radius, circleCenter, sectorOffsetAngles);

    if (_hideOthers)
      drawShutter(canvas, radius, circleCenter, sectorOffsetAngles);

    if (_shouldDrawCenterPiece) drawCenterPiece(canvas, radius, circleCenter);
  }

  // Function used to rotate the canvas i.e, the wheel about its center.
  // As the default rotate method does not
  // provide a way to specify the pivot of rotation, the canvas is translated
  // to and from the pivot offset which is the center of the wheel.
  void rotateCanvas(Canvas canvas, double radius, double angle) {
    canvas.translate(radius, radius);
    canvas.rotate(angle);
    canvas.translate(-radius, -radius);
  }

  void drawWheel(Canvas canvas, double radius, Offset circleCenter) {
    canvas.drawCircle(circleCenter, radius, _wheelPaint);
  }

  void drawBorder(Canvas canvas, double radius, Offset circleCenter) {
    canvas.drawCircle(circleCenter, radius, _borderPaint);
  }

  drawImages(Canvas canvas, double radius, Offset circleCenter,
      List<double> sectorOffsetAngles, List<double> itemRotations) {
    for (var i = 0; i < _itemCount; i++) {
      canvas.save();

      // Clipper in the shape of a sector.
      Path clip = Path();
      clip.moveTo(circleCenter.dx, circleCenter.dy);
      clip.arcTo(Rect.fromCircle(center: circleCenter, radius: radius),
          sectorOffsetAngles[i], _sectorAngle, false);
      clip.lineTo(circleCenter.dx, circleCenter.dy);
      canvas.clipPath(clip);

      // This rotation is necessary to appropriately clip the images.
      rotateCanvas(canvas, radius, pi * 1.5);

      rotateCanvas(canvas, radius, itemRotations[i]);
      paintLoadedImage(canvas, radius, circleCenter, _loadedImages[i],
          (_items[i] as NamedImage));
      canvas.restore();
    }
  }

  void paintLoadedImage(Canvas canvas, double radius, Offset circleCenter,
      ui.Image image, NamedImage imgInfo) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromCenter(
          center: Offset(radius * imgInfo.offsetX, radius * imgInfo.offsetY),
          width: radius * 2,
          height: radius * 2),
      image: image,
      colorFilter: imgInfo.filter,
      fit: BoxFit.scaleDown,
      scale: 0.4,
    );
  }

  void drawTexts(Canvas canvas, double radius, Offset circleCenter,
      List<double> itemRotations) {
    for (var i = 0; i < _itemCount; i++) {
      rotateCanvas(canvas, radius, itemRotations[i]);
      paintText(
        canvas,
        radius,
        Offset(circleCenter.dx + (radius * 2) / 10,
            circleCenter.dy - (radius * 2) / 15),
        _items[i],
      );
      rotateCanvas(canvas, radius, -itemRotations[i]);
    }
  }

  void paintText(
    Canvas canvas,
    double radius,
    Offset offset,
    String text,
  ) {
    // Painter that paints the text on to the canvas.
    var textPainter = TextPainter(
      maxLines: 1,
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: radius / 5,
              color: Colors.black,
              fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textWidthBasis: TextWidthBasis.longestLine,
    );

    textPainter.layout(minWidth: 0, maxWidth: radius / 1.25);
    textPainter.paint(canvas, offset);
  }

  void drawSectorDividers(Canvas canvas, double radius, Offset circleCenter,
      List<double> sectorOffsetAngles) {
    for (var i = 0; i < _itemCount; i++) {
      rotateCanvas(canvas, radius, sectorOffsetAngles[i]);
      canvas.drawLine(
          circleCenter, Offset(radius * 2, radius), _sectorDividerPaint);
      rotateCanvas(canvas, radius, -sectorOffsetAngles[i]);
    }
  }

  void drawSelectionSector(
    Canvas canvas,
    double radius,
    Offset circleCenter,
    List<double> sectorOffsetAngles,
  ) {
    if (_highlightWhileRotating ||
        _rotationAnimation.status != AnimationStatus.forward) {
      rotateCanvas(canvas, radius, -_orientation);
      canvas.drawArc(
          Rect.fromCircle(center: circleCenter, radius: radius),
          sectorOffsetAngles[_selectSector],
          _sectorAngle,
          true,
          _highlightPaint);
    }
  }

  void drawShutter(Canvas canvas, double radius, Offset circleCenter,
      List<double> sectorOffsetAngles) {
    double shutterStartAngle;
    double sweepAngle = _sectorAngle * (_itemCount - 1);
    if (_selectSector + 1 < _itemCount)
      shutterStartAngle = _sectorAngle * (_selectSector + 1);
    else
      shutterStartAngle = 0;

    canvas.drawArc(
      Rect.fromCenter(
          center: circleCenter, width: radius * 2, height: radius * 2),
      shutterStartAngle,
      sweepAngle,
      true,
      _shutterPaint,
    );
  }

  void drawCenterPiece(Canvas canvas, double radius, Offset circleCenter) {
    canvas.drawCircle(circleCenter, radius * 0.1, _centerPiecePaint);
  }

  @override
  bool shouldRepaint(SpinwheelPainter oldDelegate) {
    if (_rotationAnimation.status != AnimationStatus.forward && _count < 1) {
      _shifter();
      _count++;
    }
    return true;
  }
}
