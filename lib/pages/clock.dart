import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'score.dart';

Future<void> saveCanvas(
  BuildContext context,
  GlobalKey repaintBoundaryKey,
) async {
  try {
    if (repaintBoundaryKey.currentContext == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No context available")));
      return;
    }

    RenderRepaintBoundary boundary =
        repaintBoundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    var uri = Uri.parse('http://192.168.1.108:5000/upload');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pngBytes,
        filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
        contentType: MediaType('image', 'png'),
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final String message = responseData['message'] ?? 'No message';
        final String filename = responseData['filename'] ?? 'Unknown file';
        final predictedScore = responseData['predicted_moca_score'];
        clockScore = predictedScore;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ $message\n📄 File: $filename\n🧠 Score: $predictedScore",
            ),
          ),
        );
      } catch (e) {
        print("JSON parse error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error parsing server response")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Upload failed: ${response.statusCode} - ${response.body}",
          ),
        ),
      );
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Error uploading image")));
  }
}

void main() {
  runApp(const MaterialApp(home: ClockTestPage()));
}

class ClockTestPage extends StatefulWidget {
  const ClockTestPage({Key? key}) : super(key: key);

  @override
  _ClockTestPageState createState() => _ClockTestPageState();
}

class _ClockTestPageState extends State<ClockTestPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  List<LineSegment> lines = [];
  bool isErasing = false;
  Offset? lastPoint;

  Size? canvasSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('วาดหน้าปัดนาฬิกาที่บอกเวลา 11:10 น.'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final squareSize = constraints.biggest.shortestSide;

                return Center(
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: LayoutBuilder(
                      builder: (context, innerConstraints) {
                        canvasSize = Size(
                          innerConstraints.maxWidth,
                          innerConstraints.maxHeight,
                        );

                        return GestureDetector(
                          onPanStart: (details) {
                            final pos = details.localPosition;
                            if (_isInsideCanvas(pos)) {
                              setState(() {
                                lastPoint = pos;
                              });
                            }
                          },
                          onPanUpdate: (details) {
                            final pos = details.localPosition;
                            if (lastPoint != null && _isInsideCanvas(pos)) {
                              setState(() {
                                lines.add(
                                  LineSegment(
                                    lastPoint!,
                                    pos,
                                    isErasing ? Colors.white : Colors.black,
                                  ),
                                );
                                lastPoint = pos;
                              });
                            }
                          },
                          onPanEnd: (_) {
                            setState(() {
                              lastPoint = null;
                            });
                          },
                          child: RepaintBoundary(
                            key: _repaintBoundaryKey,
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: LinePainter(lines),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.blue,
        overlayOpacity: 0.3,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.clear),
            label: 'Clear Canvas',
            onTap: () {
              setState(() {
                lines.clear();
              });
            },
          ),
          SpeedDialChild(
            child: Icon(isErasing ? Icons.brush : Icons.auto_fix_off),
            label: isErasing ? 'Draw Mode' : 'Eraser Mode',
            onTap: () {
              setState(() {
                isErasing = !isErasing;
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.save),
            label: 'Save as Image',
            onTap: () {
              saveCanvas(context, _repaintBoundaryKey);
              Navigator.pushNamed(context, '/selectimages');
            },
          ),
        ],
      ),
    );
  }

  // Helper: Check if point is inside canvas
  bool _isInsideCanvas(Offset point) {
    if (canvasSize == null) return false;
    return point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx <= canvasSize!.width &&
        point.dy <= canvasSize!.height;
  }
}

class LineSegment {
  final Offset start;
  final Offset end;
  final Color color;

  LineSegment(this.start, this.end, this.color);
}

class LinePainter extends CustomPainter {
  final List<LineSegment> lines;

  LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final linePaint =
          Paint()
            ..color = line.color
            ..strokeWidth = 10.0
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(line.start, line.end, linePaint);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
