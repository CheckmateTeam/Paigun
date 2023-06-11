import 'package:flutter/material.dart';
import 'package:paigun/page/components/sizeappbar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SizeAppbar(context, 'History',
          () => Navigator.pushReplacementNamed(context, '/home')),
      body: Center(
        child: Text('History Page'),
      ),
    );
  }
}
