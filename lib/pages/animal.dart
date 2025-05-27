import 'package:flutter/material.dart';
import 'score.dart';

void main() {
  runApp(const MaterialApp(home: AnimalMocaTestPage()));
}

class AnimalMocaTestPage extends StatefulWidget {
  const AnimalMocaTestPage({super.key});

  @override
  State<AnimalMocaTestPage> createState() => _AnimalMocaTestPageState();
}

class _AnimalMocaTestPageState extends State<AnimalMocaTestPage> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, String> animalImages = {
    'assets/lion.png': 'lion',
    'assets/camel.png': 'camel',
    'assets/rhino.png': 'rhino',
  };

  late List<MapEntry<String, String>> shuffledAnimals;
  int currentIndex = 0;
  int score = 0;
  bool quizFinished = false;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    shuffledAnimals = animalImages.entries.toList()..shuffle();
    currentIndex = 0;
    score = 0;
    quizFinished = false;
  }

  void _handleSubmit() {
    final userAnswer = _controller.text.trim().toLowerCase();
    final correctAnswer = shuffledAnimals[currentIndex].value.toLowerCase();

    if (userAnswer == correctAnswer) {
      score++;
    }

    setState(() {
      _controller.clear();
      currentIndex++;
      if (currentIndex >= shuffledAnimals.length) {
        animalScore = score;
        quizFinished = true;
      }
    });
  }

  // void _restartQuiz() {
  //   setState(() {
  //     _startQuiz();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal MoCA Test'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body:
          quizFinished
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '✅ Quiz Complete!\nYour score: $score / ${shuffledAnimals.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/attention');
                      },
                      child: const Text('Go to Next Test'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Image.asset(
                        shuffledAnimals[currentIndex].key,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Image not found',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'What animal is this?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
    );
  }
}
