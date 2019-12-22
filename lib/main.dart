import 'package:flutter/material.dart';
import 'hints_cards.dart';
import 'cards_repo.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.blue
      ),
      home: ServicesWidget(child: HintsCards())
    );
  }
}

class ServicesWidget extends InheritedWidget {

  final CardsRepo cardsRepo = InMemoryCardsRepo();

  ServicesWidget({Widget child}) : super(child: child);

  static ServicesWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServicesWidget>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
