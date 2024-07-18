import 'package:flutter/material.dart';
import 'cardstates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

import 'history_page.dart';
import 'tarotcontent.dart';

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
    var cardnum = Random().nextInt(tarotdeck.length);
    if (_cardStates[index]?["flipCount"] == 0) {

      //check for repeats
      var previousCards = [];
      for(var i = 0;i<5;i++){
        if(_cardStates[i]?["flipCount"] > 0){
          //make a list of all flipped cards
          if (previousCards.contains(_cardStates[i]?["cardNumber"])==false){ //to avoid repeats
            previousCards.add(_cardStates[i]?["cardNumber"]);
          }
        }
      }

      while(previousCards.contains((cardnum/2).floor())){ //if there's a match, reroll
        cardnum = Random().nextInt(tarotdeck.length);
      }
      // set card title and meaning
      _cardStates[index]?["cardTitle"] = tarotdeck[cardnum]["title"];
      _cardStates[index]?["cardSubtitle"] = tarotdeck[cardnum]["meaning"];
      _cardStates[index]?["cardImage"] = tarotdeck[cardnum]["image"];
      _cardStates[index]?["isReversed"] = (cardnum%2==0)?false:true;
      _cardStates[index]?["cardNumber"] = (cardnum/2).floor();
    }
  }

  // flip card on tap
  void _flipCard(index, context) {
    bool isFlipped = _cardStates[index]?["isFlipped"];
    setState(() {
      if (isFlipped) {
        // change card design
        _cardStates[index]?["cardColor"] =
            Theme.of(context).colorScheme.secondaryContainer;
        _cardStates[index]?["cardTitleColor"] =
            Theme.of(context).colorScheme.onPrimaryContainer;
        // set card state
        _cardStates[index]?["isFlipped"] = false;
        _cardStates[index]?["flipCount"] == _cardStates[index]?["flipCount"]++;
      } else if (!isFlipped) {
        // change card design
        _cardStates[index]?["cardColor"] =
            Theme.of(context).colorScheme.onPrimary;
        _cardStates[index]?["cardTitleColor"] =
            Theme.of(context).colorScheme.primary;
        // change text
        _getCard(index);
        // set card state
        _cardStates[index]?["isFlipped"] = true;
        _cardStates[index]?["flipCount"] == _cardStates[index]?["flipCount"]++;
      }
    });
  }

  void _resetCards(context) {
    setState(() {
      for (var i in _cardStates.values) {
        i["isFlipped"] = false;
        i["flipCount"] = 0;
        i["cardColor"] = Theme.of(context).colorScheme.secondaryContainer;
        i["cardTitleColor"] = Theme.of(context).colorScheme.onPrimaryContainer;
      }
    });
  }

  // Save the results locally
  void _saveResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String date = DateTime.now().toString();
    List<Map<String, dynamic>> cards = _cardStates.values.map((state) {
      return {
        "cardTitle": state["cardTitle"],
        "cardSubtitle": state["cardSubtitle"],
        "cardImage": state["cardImage"],
        "orientation": state["isReversed"],
      };
    }).toList();
    Map<String, dynamic> result = {"date": date, "cards": cards};
    List<String>? savedResults = prefs.getStringList('savedResults') ?? [];
    savedResults.add(jsonEncode(result));
    prefs.setStringList('savedResults', savedResults);
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
          backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          // app name
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          // save and history buttons
          actions: [
            ElevatedButton(
              onPressed: () => _resetCards(context),
              child: const Text('Pull New Cards'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _saveResults,
              child: const Text('Save Results'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryPage(),
                  ),
                );
              },
              child: const Text('View History'),
            ),
          ],
        ),
        // Center all children
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.sizeOf(context).width,
                    maxWidth: MediaQuery.sizeOf(context).width,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(children: [
                      GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // prevent scrolling
                        shrinkWrap: true, // allow GridView to center vertically
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // column count
                          childAspectRatio: (250 / 420), // width and height
                        ),
                        itemCount:
                            5, // how many items to build with itemBuilder
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
                            child: Builder(
                              builder: (context) {
                                if (_cardStates[index]?["isFlipped"]) {
                                  // show tarot image
                                  return Builder(
                                    builder: (context) {
                                      if (_cardStates[index]?["isReversed"]) {
                                        return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              // display reversed image
                                              Transform.rotate(
                                                  angle: 180 * pi / 180,
                                                  child: Image.network(
                                                    _cardStates[index]
                                                        ?["cardImage"],
                                                    height: 400,
                                                  )),
                                            ]);
                                      } else {
                                        return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Image.network(
                                                _cardStates[index]
                                                    ?["cardImage"],
                                                height: 400,
                                              ),
                                            ]);
                                      }
                                    },
                                  );
                                } else {
                                  // show tarot back design
                                  return const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image(
                                          image: AssetImage(
                                              "assets/tarot_back.png"),
                                          height: 400,
                                        ),
                                      ]);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // prevent scrolling
                        shrinkWrap: true, // allow GridView to center vertically
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // column count
                          childAspectRatio: (250 / 100), // width and height
                        ),
                        itemCount:
                            5, // how many items to build with itemBuilder
                        itemBuilder: (context, index) =>
                            Builder(builder: (context) {
                          if (_cardStates[index]?["flipCount"] > 0) {
                            // card container
                            return Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              elevation: 10,
                              margin: const EdgeInsets.all(12),
                              // card body
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    _cardStates[index]!["cardTitle"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize:
                                          MediaQuery.sizeOf(context).width / 80,
                                    ),
                                  ),
                                  Text(
                                    _cardStates[index]!["cardSubtitle"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryFixedVariant,
                                      fontSize:
                                          MediaQuery.sizeOf(context).width /
                                              100,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox(
                              width: 20,
                            );
                          }
                        }),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
