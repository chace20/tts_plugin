import 'package:flutter/material.dart';
import 'package:tts_plugin_example/views/realtts.dart';
import 'package:tts_plugin_example/views/tts.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Demo')),
      body: Column(
        children: [
          MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const TTSView();
                }));
              },
              child: const Text("语音合成")),
          // MaterialButton(
          //     color: Colors.blue,
          //     textColor: Colors.white,
          //     minWidth: double.infinity,
          //     onPressed: () {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) {
          //         return const RealTTSView();
          //       }));
          //     },
          //     child: const Text("实时语音合成"))
        ],
      ),
    ));
  }
}
