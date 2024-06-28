import 'package:flutter/material.dart';

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
  bool _isFlipped = false;
  int _timesFlipped = 0;
  String _cardTitle = "";
  // color
  Color _cardColor = Colors.purple;
  Color _cardTitleColor = Colors.black;

  void _flipCard(context) {
    setState(() {
      _timesFlipped++;
      if (_isFlipped) {
        // change card design
        _cardColor = Theme.of(context).colorScheme.onPrimary;
        _cardTitleColor = Theme.of(context).colorScheme.primary;
        _cardTitle = "Goodbye!";
        // set card state
        _isFlipped = false;
      } else if (!_isFlipped) {
        // change card design
        _cardColor = Theme.of(context).colorScheme.secondaryContainer;
        _cardTitleColor = Theme.of(context).colorScheme.onPrimaryContainer;
        _cardTitle = "Hello!";
        // set card state
        _isFlipped = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            title: Text(
              widget.title,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            )),
        body: Center(
          child: Card(
            color: _cardColor,
            elevation: 20,
            margin: const EdgeInsets.all(12),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Click the button to flip the card.",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    _cardTitle,
                    style: TextStyle(
                      color: _cardTitleColor,
                      fontSize: 70,
                    ),
                  ),
                  Text(
                    '$_timesFlipped',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _flipCard(context),
          tooltip: "Flip the card!",
          child: const Icon(Icons.rotate_90_degrees_cw),
        ),
      ),
    );
  }
}
