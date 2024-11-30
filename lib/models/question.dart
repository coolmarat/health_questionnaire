import 'package:uuid/uuid.dart';

class Question {
  final String id;
  final int from;
  final int? to;
  final String question;
  final int year;
  final int gender;
  final String name;

  Question({
    required this.id,
    required this.from,
    this.to,
    required this.question,
    required this.year,
    required this.gender,
    required this.name,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      question: json['question'],
      year: json['year'],
      gender: json['gender'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'question': question,
      'year': year,
      'gender': gender,
      'name': name,
    };
  }
}
