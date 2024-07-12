import 'package:flutter/material.dart';

void main() {
  runApp(TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TemperatureConverterScreen(),
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  @override
  _TemperatureConverterScreenState createState() =>
      _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  String _conversionType = 'C to F';
  List<String> _conversionHistory = [];
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 1.2)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _convertTemperature() {
    if (_inputController.text.isEmpty) {
      setState(() {
        _output = '';
      });
      return;
    }

    try {
      double inputTemperature = double.parse(_inputController.text);
      double convertedTemperature;

      if (_conversionType == 'C to F') {
        convertedTemperature = inputTemperature * 9 / 5 + 32;
        setState(() {
          _output =
              '$inputTemperature °C = ${convertedTemperature.toStringAsFixed(3)} °F';
          _conversionHistory.add(
              'C -> F: $inputTemperature = ${convertedTemperature.toStringAsFixed(2)}F');
        });
      } else {
        convertedTemperature = (inputTemperature - 32) * 5 / 9;
        setState(() {
          _output =
              '$inputTemperature °F = ${convertedTemperature.toStringAsFixed(3)} °C';
          _conversionHistory.add(
              'F -> C: $inputTemperature = ${convertedTemperature.toStringAsFixed(2)}C');
        });
      }

      _controller.forward();
    } catch (e) {
      setState(() {
        _output = 'Invalid input';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Temperature Converter'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildConversionTypeSelector(),
                  SizedBox(height: 16),
                  TextField(
                    controller: _inputController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _conversionType == 'C to F'
                          ? 'Degrees Celsius'
                          : 'Degrees Fahrenheit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ScaleTransition(
                    scale: _animation,
                    child: ElevatedButton(
                      onPressed: _convertTemperature,
                      child: Text('Convert'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _output,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  _buildConversionHistoryTable(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversionTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<String>(
          value: 'C to F',
          groupValue: _conversionType,
          onChanged: (value) {
            setState(() {
              _conversionType = value!;
              _inputController.clear();
              _output = '';
            });
          },
        ),
        Text('Celsius to Fahrenheit'),
        Radio<String>(
          value: 'F to C',
          groupValue: _conversionType,
          onChanged: (value) {
            setState(() {
              _conversionType = value!;
              _inputController.clear();
              _output = '';
            });
          },
        ),
        Text('Fahrenheit to Celsius'),
      ],
    );
  }

  Widget _buildConversionHistoryTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: _conversionHistory.map((conversion) {
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(conversion),
                  Icon(conversion.startsWith('C -> F')
                      ? Icons.arrow_forward
                      : Icons.arrow_back),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
