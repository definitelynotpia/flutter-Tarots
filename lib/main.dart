import 'package:flutter/material.dart';
import 'dart:math';
import './tarotcontent.dart';
import 'cardstates.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tarots',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: "Flutter Tarots Home"),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // initialize tarot card states as a nested hashmap
  final Map<int, Map> _cardStates = cardstates;

  // tarot card randomizer
  void _getCard(index) {
    int cardnum = Random().nextInt(tarotdeck.length);
    // set card title and meaning
    _cardStates[index]?["cardTitle"] = tarotdeck[cardnum]['title'];
    _cardStates[index]?["cardSubtitle"] = tarotdeck[cardnum]['meaning'];
  }

  // flip card on tap
  void _flipCard(index, context) {
    bool isFlipped = _cardStates[index]?["isFlipped"];
    setState(() {
      if (isFlipped) {
        // change card design
        _cardStates[index]?["cardColor"] =
            Theme.of(context).colorScheme.onPrimary;
        _cardStates[index]?["cardTitleColor"] =
            Theme.of(context).colorScheme.primary;
        _cardStates[index]?["cardTitle"] = "Click me!";
        _cardStates[index]?["cardSubtitle"] = "";
        // set card state
        _cardStates[index]?["isFlipped"] = false;
      } else if (!isFlipped) {
        // change card design
        _cardStates[index]?["cardColor"] =
            Theme.of(context).colorScheme.secondaryContainer;
        _cardStates[index]?["cardTitleColor"] =
            Theme.of(context).colorScheme.onPrimaryContainer;
        _getCard(index);
        // set card state
        _cardStates[index]?["isFlipped"] = true;
      }
    });
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
        // set transparent background to show gradient
        backgroundColor: Colors.transparent,
        // display app name at header
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            title: Text(
              widget.title,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            )),
        // Center all children
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width/1.5,
              maxWidth: MediaQuery.sizeOf(context).width/1.5,
            ),
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // prevent scrolling
              shrinkWrap: true, // allow GridView to center vertically
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // rows
                // mainAxisSpacing: 40,
                // crossAxisSpacing: 10, // space between
                childAspectRatio: (250 / 400), // width and height
              ),
              itemCount: 5, // how many items to build with itemBuilder
              itemBuilder: (context, index) =>
                  // make card clickable
                  GestureDetector(
                // flip card on tap
                onTap: () => _flipCard(index, context),
                // card container
                child: Card(
                  color: _cardStates[index]?["cardColor"],
                  elevation: 20,
                  margin: const EdgeInsets.all(12),
                  // card body
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // card title
                        Text(
                          _cardStates[index]?["cardTitle"],
                          style: TextStyle(
                            color: _cardStates[index]?["cardTitleColor"],
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          _cardStates[index]?["cardSubtitle"],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
