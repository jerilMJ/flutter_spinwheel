import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';

import 'spinwheel_painter.dart';
import '../named_image.dart';
import 'utilities.dart';

/// Custom-made UI widget that takes an array of strings as [items] and makes
/// a wheel with each sector of the wheel assigned to each of the option. Use the [select]
/// param to choose which sector of the wheel to act as the selecting sector. Use the [size]
/// param to specify the area to be occupied by the widget.
///
/// This widget uses the CustomPainter class to draw itself and its component on the given
/// area specified by [size]. Some customizations are provided as params. For additional
/// customizations, you will have to edit the source code and tweak the SpinwheelPainter
/// to your liking.
class Spinwheel extends StatefulWidget {
  /// The [size] of the square on which the circular spinner will be drawn.
  final double size;

  /// The [items] that will be shown on the spinner. Each will get an equally
  /// separated sector of the circle. (360° / no. of items) .Either this or [imageItems] must not
  /// be null for this widget to work.
  final List<String> items;

  /// The [imageItems] to display on the spinner. Either this or [items] must not
  /// be null for this widget to work.
  final List<NamedImage> imageItems;

  /// The position of the selection (hihglighted) sector of the circle.
  /// The range is : 0..(size of items).. Imagine it just like an array.
  /// Selection numbering starts from 0.
  final int select;

  /// Callback that returns the selected value from spinner menu everytime the
  /// selection is changed.
  final ValueSetter<String> onChanged;

  /// The number of menu-items given to the spinwheel class.
  /// Should be handled in the constructor.
  final int itemCount;

  /// The duration (in milliseconds) of the rotation animation.
  final int rotationDuration;

  /// Decides whether touching the spinner will make it rotate in the
  /// previously panned direction (default-clockwise).
  final bool touchToRotate;

  /// Set to true to autoplay.
  final bool autoPlay;

  /// Default duration is 5 seconds.
  final Duration autoPlayDuration;

  /// Set to true to cancel autoplay temporarily when touching.
  final bool longPressToPauseAutoplay;

  /// Paint settings used for drawing wheel. Customizable
  final Paint wheelPaint;

  /// Paint settings used for drawing wheel border if applicable. Customizable
  final Paint borderPaint;

  /// Paint settings used for drawing the dividers if applicable. Customizable
  final Paint sectorDividerPaint;

  /// Paint settings used for drawing the center piece (circle) if applicable. Customizable
  final Paint centerPiecePaint;

  /// Paint settings used for drawing the highlight if applicable. Customizable
  final Paint highlightPaint;

  /// Paint settings used for drawing the shutter if applicable. Customizable
  final Paint shutterPaint;

  /// Determines whether sector dividers should be drawn.
  final bool shouldDrawDividers;

  /// Determines whether border should be drawn.
  final bool shouldDrawBorder;

  /// Determines whether center piece should be drawn.
  final bool shouldDrawCenterPiece;

  /// Determines whether highlight should be drawn.
  final bool shouldHighlight;

  /// Determines whether the shutter to hide all options except selected should be drawn.
  final bool hideOthers;

  /// Determines whether highlighter should be present while rotating.
  /// This might seem not so good on some designs.
  final bool highlightWhileRotating;

  /// The angle to rotate the wheel by (around center).
  final double wheelOrientation;

  /// The duration for fade-in of the spinner. Set to Duration(unit: 0) for disabling.
  final Duration fadeDuration;

  /// Creates a SpinnerWheel (sort of like a radial menu) which takes an items list (list of strings [items])
  /// or images list (list of images [imageItems]). It provides callback [onChanged] to keep track of
  /// the current value and many other customization options (which are given as parameters of type [Paint]).
  /// If the provided customizations feel short of your needs, please edit the source code according to
  /// your demands.
  ///
  /// Here is one way to provide a Paint(which only has a default constructor) object as a parameter:
  /// ```
  /// SpinnerWheel(
  ///       ..,
  ///       ..,
  ///       ..,
  ///       wheelPaint: Paint()
  ///             ..color = Colors.white
  ///             ..style = PaintingStyle.fill,
  ///       ..,
  ///),
  /// ```
  Spinwheel({
    this.items,
    this.imageItems,
    this.select = 0,
    this.size = 100.0,
    this.onChanged,
    this.rotationDuration = 200,
    this.touchToRotate = true,
    this.autoPlay = false,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.longPressToPauseAutoplay = false,
    this.shouldDrawDividers = true,
    this.shouldDrawBorder = true,
    this.shouldDrawCenterPiece = true,
    this.shouldHighlight = true,
    this.hideOthers = true,
    this.highlightWhileRotating = false,
    this.wheelPaint,
    this.borderPaint,
    this.sectorDividerPaint,
    this.centerPiecePaint,
    this.highlightPaint,
    this.shutterPaint,
    this.wheelOrientation = 0,
    this.fadeDuration = const Duration(milliseconds: 1500),
  })  : itemCount = items != null ? items.length : imageItems.length,
        assert(
          (items != null && imageItems == null) ||
              (items == null && imageItems != null),
          'Spinwheel widget can only take either [items] or [imageItems] parameter'
          'and not both. Please remove one to clear this exception.',
        ),
        assert(
          (onChanged != null),
          'Spinwheel requires an onChange function. If it is not required,'
          'pass an empty function with a string parameter.',
        );

  @override
  _SpinwheelState createState() => _SpinwheelState();
}

class _SpinwheelState extends State<Spinwheel>
    with SingleTickerProviderStateMixin {
  // The animation controller that controls the rotation of the spinwheel.
  AnimationController _rotationController;
  Animation _rotationAnimation;

  // To determine whether the pan on the wheel results in clockwise or
  // counter-clockwise motion.
  bool _movingClockwise = true;
  double _velocity;

  // Unified list for list of String and NamedImage.
  List<dynamic> _spinnerItems;

  // Used by components to check whether the given items are images or not.
  bool _isImageList = false;

  // List to store images loaded using ui.instantiateImageCodec()
  List<ui.Image> loadedImages = [];

  // Timer for autoplay.
  Timer _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    initFields();
  }

  void initFields() {
    _rotationController = AnimationController(
        duration: Duration(milliseconds: widget.rotationDuration), vsync: this);

    _rotationAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_rotationController)
          ..addListener(
            () {
              setState(() {});
            },
          )
          ..addStatusListener(
            (status) {
              if (status == AnimationStatus.completed) {
                _rotationController.reset();
              }
            },
          );

    // Assigning to a unified list
    _spinnerItems = widget.items ?? widget.imageItems;
    _isImageList = widget.imageItems != null;

    // If image details are provided, load them.
    if (_isImageList) {
      loadImages(widget.imageItems, context, loadedImages, () {
        setState(() {});
      });
    }

    autoPlayStart();
  }

  // Function that triggers callback to set selected value.
  void notifySelectedOption() {
    if (_isImageList)
      widget.onChanged((_spinnerItems[widget.select] as NamedImage).name);
    else
      widget.onChanged(_spinnerItems[widget.select]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isImageList
          ? (loadedImages.length == widget.imageItems.length) ? 1 : 0
          : 1,
      duration: widget.fadeDuration,
      child: GestureDetector(
        onTap: _tapHandler,
        onLongPress: _longPressHandler,
        onLongPressEnd: _longPressEndHandler,
        onPanUpdate: _panUpdateHandler,
        onPanEnd: _panEndHandler,
        child: CustomPaint(
          painter: SpinwheelPainter(
            widget.itemCount,
            _isImageList,
            _spinnerItems,
            _isImageList ? loadedImages : null,
            _movingClockwise,
            _movingClockwise ? previousItem : nextItem,
            _rotationAnimation,
            widget.select,
            widget.shouldDrawDividers,
            widget.shouldDrawBorder,
            widget.shouldDrawCenterPiece,
            widget.hideOthers,
            widget.shouldHighlight,
            widget.highlightWhileRotating,
            widget.wheelPaint,
            widget.borderPaint,
            widget.sectorDividerPaint,
            widget.centerPiecePaint,
            widget.highlightPaint,
            widget.shutterPaint,
            widget.wheelOrientation,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
          ),
        ),
      ),
    );
  }

  // Tapping rotates the wheel to previously panned direction. Default is clockwise.
  void _tapHandler() {
    startAnimation();
    autoPlayRestart();
  }

  // Long press to pause
  void _longPressHandler() {
    if (widget.longPressToPauseAutoplay) autoPlayCancel();
  }

  // Start autoplay after long press ends
  void _longPressEndHandler(LongPressEndDetails details) {
    if (widget.longPressToPauseAutoplay) autoPlayStart();
  }

  // Function that keeps track of radial movement i.e, movement along the
  // wheel during each pan session and determines whether the pan
  // indicates clockwise or counter-clockwise motion.
  void _panUpdateHandler(DragUpdateDetails update) {
    bool onTop = update.localPosition.dy <= widget.size / 2;
    bool onRight = update.localPosition.dx >= widget.size / 2;
    bool onBottom = !onTop;
    bool onLeft = !onRight;

    bool panningUp = update.delta.dy <= 0;
    bool panningRight = update.delta.dx >= 0;
    bool panningDown = !panningUp;
    bool panningLeft = !panningRight;

    // Absolute change in the X and Y direction.
    double absX = update.delta.dx.abs();
    double absY = update.delta.dy.abs();

    bool isHorizontalClockwiseMotion =
        (onTop && panningRight) || (onBottom && panningLeft);
    bool isVerticalClockwiseMotion =
        (onLeft && panningUp) || (onRight && panningDown);

    double horizontalRotation = isHorizontalClockwiseMotion ? absX : -absX;
    double verticalRotation = isVerticalClockwiseMotion ? absY : -absY;

    // Resultant rotation. Can be used to find the velocity by multiplying
    // with update.delta.distance.
    double resultantRotation = verticalRotation + horizontalRotation;

    _movingClockwise = resultantRotation > 0;
    _velocity = resultantRotation * update.delta.distance;
  }

  // Function to be called at the end of each pan session and
  // trigger the rotation animation.
  void _panEndHandler(DragEndDetails details) {
    if (_rotationController.status != AnimationStatus.forward &&
        (widget.touchToRotate || _velocity != null)) {
      startAnimation();
      autoPlayRestart();
      _velocity = null;
    }

    autoPlayRestart();
  }

  // Cancel and start autoplay
  void autoPlayRestart() {
    autoPlayCancel();
    autoPlayStart();
  }

  void autoPlayStart() {
    if (widget.autoPlay) {
      _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (timer) {
        startAnimation();
      });
    }
  }

  // Function that starts the animation after a pan session.
  void startAnimation() async {
    await _rotationController.forward();
  }

  void autoPlayCancel() {
    if (_autoPlayTimer != null) if (widget.autoPlay &&
        _autoPlayTimer.isActive) {
      _autoPlayTimer.cancel();
    }
  }

  // Function that shifts the ordering of the menu list to the right
  // and triggers callback to set
  void previousItem() {
    shiftItemsRight(_spinnerItems);
    if (_isImageList) shiftItemsRight(loadedImages);
    notifySelectedOption();
  }

  // Function that shifts the ordering of the menu list to the left.
  void nextItem() {
    shiftItemsLeft(_spinnerItems);
    if (_isImageList) shiftItemsLeft(loadedImages);
    notifySelectedOption();
  }

  @override
  void deactivate() {
    super.deactivate();
    _rotationController.dispose();
    _autoPlayTimer.cancel();
  }
}
