import 'package:flutter/material.dart';
import 'package:ridesense_assignemt_solvis/screen2.dart';

class LocationInputScreen extends StatefulWidget {
  @override
  _LocationInputScreenState createState() => _LocationInputScreenState();
}

class _LocationInputScreenState extends State<LocationInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _submit() {
    final String input = _controller.text;

    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a location.';
      });
    } else {
      // Navigate to the next screen with the entered location
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationResultScreen(location: input),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Enter Location',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.indigo,
                  fontSize: 22,
                ),
                labelText: 'Location',
                hintText: 'Enter city names',
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(),
              onPressed: _submit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
