import 'package:flutter/foundation.dart';

class HintsCard {

  String id;
  List<String> hints;
  String notes;
  HintsCard({this.id, this.hints = const [], this.notes});


  // -- equals, hashCode, toString ---

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


  // --- JSON mapping ---

  // https://flutter.dev/docs/cookbook/networking/fetch-data
  factory HintsCard.fromJson(Map<String, dynamic> json) {

    return HintsCard(
      id: json['id'] as String,
      hints: json['hints'].cast<String>(), // https://javiercbk.github.io/json_to_dart/
      notes: json['notes'] as String,
    );
  }

  // TODO: This could be moved to a generic json utility
  static List<HintsCard> listFromJson(List<dynamic> list) {
    // https://stackoverflow.com/a/52576858/1121497
    return list.map((x) => HintsCard.fromJson(x)).toList();
  }

  static Map<String, dynamic> toJson(HintsCard card) {

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = card.id;
    data['hints'] = card.hints;
    data['notes'] = card.notes;
    return data;
  }
}