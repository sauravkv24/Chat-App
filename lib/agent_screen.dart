import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personaController = TextEditingController();

  Future<void> _saveAgent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> agents = prefs.getStringList('agents') ?? [];
    Map<String, String> newAgent = {
      'name': _nameController.text,
      'persona': _personaController.text,
    };
    agents.add(jsonEncode(newAgent));
    await prefs.setStringList('agents', agents);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Agent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Agent Name'),
            ),
            TextField(
              controller: _personaController,
              decoration: const InputDecoration(labelText: 'Agent Persona'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAgent,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
