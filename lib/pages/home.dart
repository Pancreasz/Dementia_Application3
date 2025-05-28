import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แบบทดสอบโรคประสาทเสื่อม (Test Edition)"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("เริ่มทำแบบทดสอบ"),
          onPressed: () {
            Navigator.pushNamed(context, '/larksen');
          },
        ),
      ),
    );
  }
}
