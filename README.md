# Material Theme Builder for Flutter
Simple Flutter interface for the Material Theme Builder. Check out the original
builder online at https://material-foundation.github.io/material-theme-builder/.

## Features

- Create tonal palettes from a single colour
- Create `ColorScheme` from 3 to 5 colours (primary, secondary, tertiary, error, neutral)

## Getting started

1. Add the package to your pubspec.yaml: 
`flutter pub add material_theme_builder`

2. Use the package:

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: MaterialThemeBuilder(
          primary: Colors.blue,
          secondary: Colors.purple,
          tertiary: Colors.lightBlue
        ).toScheme()
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```