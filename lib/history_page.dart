import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _savedResults = [];
  bool errorSaving = false;
  String errorMessage = "";

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
      // set error to true and display error message
      errorSaving = true;
      errorMessage = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // set gradient background
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.1, 0.7, 1],
          colors: [
            Theme.of(context).colorScheme.onPrimaryContainer,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryFixedDim,
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: _savedResults.isEmpty
            ? const Center(
                child: Text('No saved results'),
              )
            : ListView.separated(
                itemCount: _savedResults.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  Map<String, dynamic> result = _savedResults[index];
                  List<Widget> cardsWidgets = [];

                  // Generate cards widgets only if data is available
                  if (result['date'] != null) {
                    cardsWidgets.add(Text("Date: ${result['date']}"));

                    if (result['cards'] != null) {
                      result['cards'].forEach((card) {
                        if (card['cardTitle'] != null &&
                            card['cardSubtitle'] != null) {
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
      ),
    );
  }
}
