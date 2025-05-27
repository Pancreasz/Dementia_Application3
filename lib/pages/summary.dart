import 'package:flutter/material.dart';
import 'score.dart';

int totalScore =
    larkScore + clockScore + animalScore + attentionScore + reorderScore;

class EndPage extends StatelessWidget {
  const EndPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แบบทดสอบโรคประสาทเสื่อม"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "คะแนนแบบทดสอบลากเส้น: $larkScore/1\nคะแนนแบบทดสอบนาฬิกา: $clockScore/3 \nคะแนนแบบทดสอบทายชื่อสัตว์: $animalScore/3\nคะแนนแบบทดสอบลบเลข: $attentionScore/3\nคะแนนแบบทดสอบความจำ: $reorderScore/5\nคะแนนรวมทั้งหมด: $totalScore/15",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("ทำแบบทดสอบอีกครั้ง"),
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
              },
            ),
          ],
        ),
      ),
    );
  }
}
