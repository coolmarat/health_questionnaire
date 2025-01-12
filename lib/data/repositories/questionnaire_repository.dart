import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/question.dart';

class QuestionnaireRepository {
  Future<List<Question>> loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> jsonList = jsonData['questions'];
    return jsonList.map((json) => Question.fromJson(json)).toList();
  }

  List<Question> filterQuestionsByAgeAndGender(
    List<Question> questions,
    int age,
    int gender,
  ) {
    final int currentYear = DateTime.now().year;
    return questions.where((question) {
      final bool ageMatch = age >= question.from && (question.to == null || age <= question.to!);
      final bool genderMatch = question.gender == -1 || question.gender == gender;
      final bool yearMatch = (currentYear - age) >= question.year;
      return ageMatch && genderMatch && yearMatch;
    }).toList();
  }
}
