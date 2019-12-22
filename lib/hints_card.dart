
class HintsCard {
  String id;
  List<String> hints;
  String notes;
  HintsCard({this.id, this.hints = const [], this.notes});

  @override
  String toString() {
    return 'HintsCard{id: $id, hints: $hints, notes: $notes}';
  }
}