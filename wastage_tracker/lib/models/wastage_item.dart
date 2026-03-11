class WastageItem {
  final int? id;
  final String name;
  final String category;
  final double weight;
  final DateTime date;

  WastageItem({
    this.id,
    required this.name,
    required this.category,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory WastageItem.fromMap(Map<String, dynamic> map) {
    return WastageItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
    );
  }
}
