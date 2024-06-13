import 'package:flutter/material.dart';
import 'dart:io';

class FileParser extends StatefulWidget {
  final String filePath;

  const FileParser({super.key, required this.filePath});

  @override
  _FileParserState createState() => _FileParserState();
}

class _FileParserState extends State<FileParser> {
  String _fileContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    try {
      String content = await _readFile(widget.filePath);
      setState(() {
        _fileContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fileContent = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> _readFile(String filePath) async {
    // Use this line if the file is in the assets folder
    // return await rootBundle.loadString(filePath);

    // Use this line if the file is in the local storage
    final file = File(filePath);
    return await file.readAsString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(_fileContent),
              ),
            ),
    );
  }
}
