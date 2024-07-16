import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _savedResults = [];

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      List<String>? savedResults = prefs.getStringList('savedResults');
      if (savedResults != null) {
        setState(() {
          _savedResults = savedResults
              .map((result) => jsonDecode(result) as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      // Handle errors here (e.g., log the error, show error message)
      print('Error loading saved results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _savedResults.isEmpty
          ? Center(
              child: Text('No saved results'),
            )
          : ListView.separated(
              itemCount: _savedResults.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                Map<String, dynamic> result = _savedResults[index];
                List<Widget> cardsWidgets = [];

                // Generate cards widgets only if data is available
                if (result['date'] != null) {
                  cardsWidgets.add(Text("Date: ${result['date']}"));

                  if (result['cards'] != null) {
                    result['cards'].forEach((card) {
                      if (card['cardTitle'] != null && card['cardSubtitle'] != null) {
                        cardsWidgets.add(
                          Text(
                            "${card['cardTitle']}: ${card['cardSubtitle']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }
                    });
                  }
                }

                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cardsWidgets,
                  ),
                );
              },
            ),
    );
  }
}
