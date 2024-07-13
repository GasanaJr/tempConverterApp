// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_final_fields, unnecessary_cast, unnecessary_overrides

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyTempConverterApplication());

class MyTempConverterApplication extends StatefulWidget {
  const MyTempConverterApplication({super.key});

  @override
  _MyTempConverterApplicationState createState() =>
      _MyTempConverterApplicationState();
}

class _MyTempConverterApplicationState
    extends State<MyTempConverterApplication> {
  ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Temperature Conversion App',
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blueGrey[900],
            scaffoldBackgroundColor: Colors.blueGrey[50],
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey[900],
            scaffoldBackgroundColor: Colors.blueGrey[900],
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          themeMode: mode,
          home: SplashScreen(
            onInitComplete: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyTempConverterHome(
                    onThemeModeChanged: (newMode) {
                      _themeMode.value = newMode;
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MyTempConverterHome extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const MyTempConverterHome({super.key, required this.onThemeModeChanged});

  @override
  _MyTempConverterHomeState createState() => _MyTempConverterHomeState();
}

class _MyTempConverterHomeState extends State<MyTempConverterHome> {
  String _selectedConversion = 'F to C';
  TextEditingController _inputController = TextEditingController();
  String _result = '';
  List<String> _history = [];
  ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _inputController.removeListener(_updateButtonState);
    _inputController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    _isButtonEnabled.value = _inputController.text.isNotEmpty;
  }

  void _convertTemperature() {
    double input = double.tryParse(_inputController.text) ?? 0;
    double output;

    if (_selectedConversion == 'F to C') {
      output = (input - 32) * 5 / 9;
    } else {
      output = input * 9 / 5 + 32;
    }

    setState(() {
      _result = output.toStringAsFixed(1);
      _history.insert(0, '$_selectedConversion: $input => $_result');
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          'Temperature Conversion App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              widget.onThemeModeChanged(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Temperature',
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blueGrey[800] : Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                dropdownColor: isDarkMode ? Colors.blueGrey[800] : Colors.white,
                value: _selectedConversion,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedConversion = newValue!;
                  });
                },
                items: <String>['F to C', 'C to F']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                underline: SizedBox(),
                iconEnabledColor: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            ValueListenableBuilder<bool>(
              valueListenable: _isButtonEnabled,
              builder: (context, isEnabled, child) {
                return ElevatedButton(
                  onPressed: isEnabled ? _convertTemperature : null,
                  child: Text('Convert'),
                );
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Result: $_result',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_history[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitComplete;

  const SplashScreen({super.key, required this.onInitComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyTempConverterHome(
              onThemeModeChanged: (newMode) {
                (context.findAncestorStateOfType<
                            _MyTempConverterApplicationState>()!
                        as _MyTempConverterApplicationState)
                    ._themeMode
                    .value = newMode;
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF143342),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.published_with_changes_rounded,
              color: Colors.white,
              size: 100,
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                "Temperature Converter App",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
