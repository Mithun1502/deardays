class DiaryModel {
  final int? id;
  final String userId;
  final String title;
  final String content;
  final String dateTime;
  final String? mood;
  final List<String> mediaPaths;

  DiaryModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.dateTime,
    this.mood,
    required this.mediaPaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'dateTime': dateTime,
      'mood': mood,
      'mediaPaths': mediaPaths.join(','),
    };
  }

  factory DiaryModel.fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      dateTime: map['dateTime'],
      mood: map['mood'],
      mediaPaths: map['mediaPaths'] != null && map['mediaPaths'] != ''
          ? (map['mediaPaths'] as String).split(',')
          : [],
    );
  }
}
