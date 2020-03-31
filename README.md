# 🎨 Flutter Spinwheel

A widget that outputs items (text or image) along a pan-able circular wheel/spinner with customization options.

## 🍀 Features

- Auto-play (enable/disable)
- Long-press to pause (enable/disable)
- Size adjustments
- Text/Image support
- Image tweaking support
- Clockwise and counter-clockwise pan to navigate
- Touch to navigate in previously panned direction
- Paint customization to alter the look
- Callback function to notify selected item

## 📥 Install & Import

Add:

```yaml
dependencies:
  flutter_spinwheel: "^1.0.0"
```

among your other dependencies in pubspec.yaml and then import it in your required project:

```dart
import  'package:flutter_spinwheel/flutter_spinwheel.dart';
```

## 🔧 Usage

```dart
List<String> items = ['🏘',  '🚓',  '🚛',  '🏍',  '🎉'];

List<NamedImage> imgPack = [
	NamedImage(
		path:  'assets/images/car.jpg',
		name:  'car',
	),
	NamedImage(
		path:  'assets/images/bike.jpg',
		name:  'bike',
	),
	NamedImage(
		path:  'assets/images/other.jpg',
		name:  'other',
	),
];
```

```dart
final spinwheelWithText = Spinwheel(
	items: items,
	onChanged: (val) {
	if (this.mounted)
		setState(() {
			currentText = val;
		});
	},
	size:  150.0,
	select:  2,
	autoPlay:  true,
);
```

```dart
final spinwheelWithImage = Spinwheel(
	size:  250.0,
	imageItems: imgPack,
	select:  1,
	onChanged: (val) {
		carousel.animateToPage(carouselNames.indexOf(val),
		duration:  Duration(seconds:  1), curve:  Curves.linear);
	},
	rotationDuration:  250,
	autoPlay:  true,
	longPressToPauseAutoplay:  true,
	hideOthers:  false,
	shouldDrawBorder:  false,
	shouldDrawCenterPiece:  false,
	wheelOrientation: pi /  4,
);
```

## 📁 Sample

<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; " >
	<div style="text-align:center">
		<img src="https://raw.githubusercontent.com/jerilMJ/flutter_spinwheel/develop/samples/text_demo.gif" width="500px">
		Text Demo
	</div>
	<div style="text-align:center">
		<img src="https://raw.githubusercontent.com/jerilMJ/flutter_spinwheel/develop/samples/image_demo.gif" width="500px">
		Image Demo
	</div>
	<div style="text-align:center">
		<img src="https://raw.githubusercontent.com/jerilMJ/flutter_spinwheel/develop/samples/sample.gif" width="500px">
		Simple Demo
	</div>
</div>
