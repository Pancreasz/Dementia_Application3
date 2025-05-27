import 'package:flutter/material.dart';
import 'score.dart' as globals;

class SelectImagesPage extends StatefulWidget {
  @override
  _SelectImagesPageState createState() => _SelectImagesPageState();
}

class _SelectImagesPageState extends State<SelectImagesPage> {
  final List<String> allImages = List.generate(
    10,
    (index) => 'assets/img${index + 1}.jpg',
  );
  late List<String> availableImages;
  List<String?> selectedImages = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    availableImages = List.from(allImages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsDialog();
    });
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('คำแนะนำในการทำแบบทดสอบ')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '1. เลือกรูปภาพ 5 รูปจากทั้งหมด 10 รูป',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '2. เรียงรูปภาพแบบใดก็ได้ในช่องที่เตรียมไว้',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text('3. จำรูปภาพและลำดับให้ดี', textAlign: TextAlign.center),
                SizedBox(height: 10),
                Text(
                  '4. ในแบบทดสอบภายหลัง ให้เรียงรูปภาพให้ตรงกับที่คุณจำไว้',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'คุณจะได้คะแนนตามจำนวนรูปภาพที่เรียงถูกต้อง! \n ถ้าหากช่องสี่เหลี่ยมไม่ครบกรุณาเอียงจอเป็นแนวนอน',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                child: Text('เริ่มแบบทดสอบ'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
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

  bool _canProceed() => selectedImages.every((img) => img != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('ถ้าหากช่องสี่เหลี่ยมไม่ครบ 5 ช่องกรุณาเอียงจอเป็นแนวนอน', style: TextStyle(fontSize: 20)),
        ),
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
                'ลากรูปภาพ 5 รูปมาวางที่นี่:',
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
                onPressed:
                    _canProceed()
                        ? () {
                          globals.correctOrder = selectedImages.cast<String>();
                          Navigator.pushNamed(context, '/animal');
                        }
                        : null,
                child: Text('ต่อไป'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
