import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'agent_screen.dart';
import 'chat_screen.dart';

class AgentListScreen extends StatefulWidget {
  const AgentListScreen({super.key});

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  List<Map<String, String>> _agents = [];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? agentsData = prefs.getStringList('agents');
    if (agentsData != null) {
      setState(() {
        _agents = agentsData.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
      });
    }
  }

  Future<void> _deleteAgent(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> agentsData = prefs.getStringList('agents') ?? [];

    String agentName = _agents[index]['name'] ?? '';
    await prefs.remove('${agentName}_messages');

    agentsData.removeAt(index);
    await prefs.setStringList('agents', agentsData);

    setState(() {
      _agents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
      ),
      body: ListView.builder(
        itemCount: _agents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_agents[index]['name'] ?? 'Unnamed Agent'),
            subtitle: Text(_agents[index]['persona'] ?? 'No persona'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _deleteAgent(index);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreenUi(
                    agentName: _agents[index]['name'] ?? 'Unnamed Agent',
                    agentPersona: _agents[index]['persona'] ?? 'No persona',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgentScreen()),
          ).then((_) => _loadAgents());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
