import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String url;
  final String title;
  final DateTime timestamp;

  Video({
    required this.id,
    required this.url,
    required this.title,
    required this.timestamp,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
