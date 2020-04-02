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

<table>
    <tr>
        <td align="center">
            <img  src="https://raw.githubusercontent.com/jerilMJ/flutter_spinwheel/master/screenshots/emoji_demo.gif"  width="500px">
            Text Demo
        </td>
        <td align="center">
            <img  src="https://raw.githubusercontent.com/jerilMJ/flutter_spinwheel/master/screenshots/image_demo.gif"  width="500px">
            Image Demo
        </td>
        <td align="center">
            <img  src="https://raw.githubusercontent.com/jerilMJ/flutter_spinwheel/master/screenshots/sample.gif"  width="500px">
            Simple Demo
        </td>
    </tr>
</table>

## 🚀 Future Plans

- Tap on any item on the spinner to rotate to that item
- More fluid animations

## 👨🏼‍💻 Support / Feature Request / Bug Report

If you experience any issues or need help understanding some of the functionalities or you feel that it can be improved, feel free to open an issue on the repo (ofcourse, first look if there is already a similar open issue).
