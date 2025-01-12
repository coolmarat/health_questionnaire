import 'package:flutter/material.dart';
import '../../domain/entities/question.dart';
import '../../domain/models/patient_model.dart';
import '../../data/repositories/questionnaire_repository.dart';
import 'results_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  final PatientModel patient;

  const QuestionnaireScreen({
    super.key,
    required this.patient,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final QuestionnaireRepository _repository = QuestionnaireRepository();
  List<Question> questions = [];
  Map<String, bool> answers = {};
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final allQuestions = await _repository.loadQuestions();
    final filteredQuestions = _repository.filterQuestionsByAgeAndGender(
      allQuestions,
      widget.patient.age,
      widget.patient.gender,
    );
    setState(() {
      questions = filteredQuestions;
      // Инициализируем все ответы как false
      for (var question in questions) {
        answers[question.id] = false;
      }
    });
  }

  void _answerQuestion(bool answer) {
    setState(() {
      answers[questions[currentQuestionIndex].id] = answer;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              questions: questions,
              answers: answers,
              patient: widget.patient,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Опрос'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.question,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Периодичность: ${question.year} ${_getYearWord(question.year)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            Switch(
                              value: answers[question.id] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  answers[question.id] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsScreen(
                        questions: questions,
                        answers: answers,
                        patient: widget.patient,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Показать результаты',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getYearWord(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return 'год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }
}
