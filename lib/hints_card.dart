import 'package:flutter/foundation.dart';

class HintsCard {
  String id;
  List<String> hints;
  String notes;
  HintsCard({this.id, this.hints = const [], this.notes});


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HintsCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listEquals(hints, other.hints) && // https://stackoverflow.com/a/55974120/1121497
          notes == other.notes;

  @override
  int get hashCode => id.hashCode ^ hints.hashCode ^ notes.hashCode;

  @override
  String toString() {
    return 'HintsCard{id: $id, hints: $hints, notes: $notes}';
  }
}