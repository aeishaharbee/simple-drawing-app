import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(DrawingApp());

class DrawingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DrawingScreen(),
    );
  }
}

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<Map<String, dynamic>> _strokes = [];
  List<Map<String, dynamic>> _redoStack = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;

  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _redoStack.add(_strokes.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _strokes.add(_redoStack.removeLast());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing App'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: _selectColor,
          ),
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _redo,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset localPosition =
                renderBox.globalToLocal(details.localPosition);
            _strokes.add({
              'points': [localPosition],
              'color': _selectedColor,
            });
            _redoStack.clear();
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset localPosition =
                renderBox.globalToLocal(details.localPosition);
            _strokes.last['points'].add(localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _strokes.last['points'].add(null);
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(strokes: _strokes, strokeWidth: _strokeWidth),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Map<String, dynamic>> strokes;
  final double strokeWidth;

  DrawingPainter({required this.strokes, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      Paint paint = Paint()
        ..color = stroke['color'] as Color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      List<Offset?> points = stroke['points'] as List<Offset?>;
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
