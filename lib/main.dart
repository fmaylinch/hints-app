import 'package:flutter/material.dart';
import 'api_cards_repo.dart';
import 'hints_cards.dart';
import 'cards_repo.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF404040),
        iconTheme: IconThemeData(
          color: Colors.grey // normal Icon
        ),
        primaryIconTheme: IconThemeData(
            color: Colors.grey // AppBar IconButton
        ),
        primaryTextTheme: TextTheme(
            title: TextStyle(color: Colors.grey), // AppBar title
            subtitle: TextStyle(color: Colors.orange), // ?
            display1: TextStyle(color: Colors.pink), // ?
            display2: TextStyle(color: Colors.purple), // ?
            display3: TextStyle(color: Colors.red), // ?
            display4: TextStyle(color: Colors.cyan), // ?
            body1: TextStyle(color: Colors.brown), // ?
            body2: TextStyle(color: Colors.yellow), // ?
            headline: TextStyle(color: Colors.green), // ?
            subhead: TextStyle(color: Colors.amber) // ?
        ),
        textTheme: TextTheme(
            caption: TextStyle(color: Colors.brown),
            overline: TextStyle(color: Colors.teal),
            title: TextStyle(color: Colors.blue), // ?
            subtitle: TextStyle(color: Colors.orange), // ?
            display1: TextStyle(color: Colors.pink), // ?
            display2: TextStyle(color: Colors.purple), // ?
            display3: TextStyle(color: Colors.red), // ?
            display4: TextStyle(color: Colors.cyan), // ?
            body1: TextStyle(color: Colors.grey), // non-list text
            body2: TextStyle(color: Colors.yellow), // ?
            headline: TextStyle(color: Colors.green), // ?
            subhead: TextStyle(color: Colors.grey) // list text
        )
      ),
      home: ServicesWidget(child: HintsCards())
    );
  }
}

class ServicesWidget extends InheritedWidget {

  final CardsRepo cardsRepo = ApiCardsRepo();

  ServicesWidget({Widget? child}) : super(child: child!);

  static ServicesWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServicesWidget>()!;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
