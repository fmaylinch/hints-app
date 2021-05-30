import 'package:flutter/foundation.dart';

class HintsCard {

  static const defaultScore = 50;

  String? id;
  int score;
  List<String> hints;
  String? notes;
  List<String> tags;

  // --- data calculated locally --- //
  /// All hints and notes together, in lower case, useful for searching/sorting
  late String allContentLower;
  /// hints[1] in lower case (by default ""), useful for sorting
  late String hint1Lower;

  HintsCard({this.id, this.score = defaultScore, this.hints = const [], this.notes, this.tags = const []}) {
    if (this.notes == null) this.notes = "";
    if (this.tags == null) this.tags = [];
    allContentLower = (hints.join(", ") + " " + (notes ?? "") + " " + tags.join(", ")).toLowerCase();
    hint1Lower = hints.length > 1 ? hints[1].toLowerCase() : "";
  }


  bool isPersisted() => id != null;

  // -- equals, hashCode, toString ---

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HintsCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          score == other.score &&
          listEquals(hints, other.hints) && // https://stackoverflow.com/a/55974120/1121497
          listEquals(tags, other.tags) &&
          notes == other.notes;

  @override
  int get hashCode => id.hashCode ^ score.hashCode ^ hints.hashCode ^ tags.hashCode ^ notes.hashCode;

  @override
  String toString() {
    return 'HintsCard{id: $id, score: $score, hints: $hints, notes: $notes, tags: $tags}';
  }


  // --- JSON mapping ---

  // https://flutter.dev/docs/cookbook/networking/fetch-data
  factory HintsCard.fromJson(Map<String, dynamic> json) {

    return HintsCard(
      id: json['id'] as String,
      score: json['score'] as int,
      hints: json['hints'].cast<String>(), // https://javiercbk.github.io/json_to_dart/
      notes: json['notes'] as String,
      tags: json['tags'].cast<String>()
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
    data['score'] = card.score;
    data['hints'] = card.hints;
    data['notes'] = card.notes;
    data['tags'] = card.tags;
    return data;
  }
}