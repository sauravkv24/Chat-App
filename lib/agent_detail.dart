import 'package:flutter/material.dart';

import 'agent_list.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Details'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AgentListScreen()),
            );
          },
          child: const Text('View Agents'),
        ),
      ),
    );
  }
}
