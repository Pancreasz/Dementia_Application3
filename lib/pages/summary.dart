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
        title: const Text("H O M E"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "larksen Score: $larkScore/1\nClock Score: $clockScore/3 \nAnimal Score: $animalScore/3\nAttention Score: $attentionScore/3\nReorder Images Score: $reorderScore/5\nOverall: $totalScore/15",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Start the Test (NUh UHhh)"),
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
