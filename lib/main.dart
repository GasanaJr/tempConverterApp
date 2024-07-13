// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

void main() => runApp(TemperatureConversionApp());

class TemperatureConversionApp extends StatefulWidget {
  const TemperatureConversionApp({super.key});

  @override
  _TemperatureConversionAppState createState() =>
      _TemperatureConversionAppState();
}

class _TemperatureConversionAppState extends State<TemperatureConversionApp> {
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
              bodyText1: TextStyle(color: Colors.white),
              bodyText2: TextStyle(color: Colors.white),
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
          home: TemperatureConversionHome(
            onThemeModeChanged: (newMode) {
              _themeMode.value = newMode;
            },
          ),
        );
      },
    );
  }
}

class TemperatureConversionHome extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeModeChanged;

  TemperatureConversionHome({required this.onThemeModeChanged});

  @override
  _TemperatureConversionHomeState createState() =>
      _TemperatureConversionHomeState();
}

class _TemperatureConversionHomeState extends State<TemperatureConversionHome> {
  String _selectedConversion = 'F to C';
  // ignore: prefer_final_fields
  TextEditingController _inputController = TextEditingController();
  String _result = '';
  // ignore: prefer_final_fields
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
      _result = output.toStringAsFixed(2);
      _history.insert(0, '$_selectedConversion: $input => $_result');
    });
  }

  @override
  Widget build(BuildContext context) {
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
            DropdownButton<String>(
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
                  child: Text(value),
                );
              }).toList(),
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
