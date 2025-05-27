import 'package:flutter/material.dart';
import 'score.dart' as globals;

class ReorderImagesPage extends StatefulWidget {
  @override
  _ReorderImagesPageState createState() => _ReorderImagesPageState();
}

class _ReorderImagesPageState extends State<ReorderImagesPage> {
  late List<String> availableImages;
  List<String?> selectedImages = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    availableImages = List.generate(
      10,
      (index) => 'assets/img${index + 1}.jpg',
    );
    availableImages.shuffle();
  }

  void _onImageDrop(int index, String image) {
    setState(() {
      if (!selectedImages.contains(image)) {
        availableImages.remove(image);
      }

      if (selectedImages[index] != null) {
        availableImages.add(selectedImages[index]!);
      }

      selectedImages[index] = image;
    });
  }

  void _removeImage(int index) {
    setState(() {
      availableImages.add(selectedImages[index]!);
      selectedImages[index] = null;
    });
  }

  bool _canSubmit() => selectedImages.every((img) => img != null);

  void _checkResult() {
    int score = 0;
    List<String> correctOrder = globals.correctOrder;

    for (int i = 0; i < 5; i++) {
      if (selectedImages[i] == correctOrder[i]) {
        score++;
      }
    }
    globals.reorderScore = score;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Center(child: Text('ผลลัพธ์')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'คุณได้คะแนน: $score/5',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'ลำดับที่ถูกต้อง:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  children:
                      correctOrder
                          .map((img) => Image.asset(img, width: 50))
                          .toList(),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  child: Text('Go to Endpage'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/endpage');
                  },
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('เรียงลำดับรูปภาพ')),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'รูปภาพทั้งหมด:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      availableImages.map((img) {
                        return Draggable<String>(
                          data: img,
                          feedback: Image.asset(img, width: 80),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.asset(img, width: 80),
                          ),
                          child: Image.asset(img, width: 80),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'ลากรูปภาพมาเรียงลำดับให้ถูกต้อง:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Column(
                      children: [
                        DragTarget<String>(
                          onAccept: (data) => _onImageDrop(index, data),
                          builder: (context, _, __) {
                            final img = selectedImages[index];
                            return Container(
                              width: 80,
                              height: 80,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: img != null ? Image.asset(img) : null,
                            );
                          },
                        ),
                        if (selectedImages[index] != null)
                          IconButton(
                            icon: Icon(Icons.delete, size: 20),
                            onPressed: () => _removeImage(index),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: _canSubmit() ? _checkResult : null,
                child: Text('ส่งคำตอบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
