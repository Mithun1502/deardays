class DiaryModel {
  final int? id;
  final String title;
  final String content;
  final String dateTime;
  final String? mood;

  DiaryModel({
    this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.mood,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateTime': dateTime,
      'mood': mood,
    };
  }

  factory DiaryModel.fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      dateTime: map['dateTime'],
      mood: map['mood'],
    );
  }
}
