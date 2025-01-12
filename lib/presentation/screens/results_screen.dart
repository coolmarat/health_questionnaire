import 'package:flutter/material.dart';
import '../../domain/entities/question.dart';
import '../../domain/models/patient_model.dart';
import '../../domain/models/bmi_result.dart';

class ResultsScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<String, bool> answers;
  final PatientModel patient;

  const ResultsScreen({
    super.key,
    required this.questions,
    required this.answers,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final declinedQuestions = questions
        .where((question) => answers[question.id] != true)
        .toList();
    
    final bmiResult = BMIResult.calculate(patient.getBMI());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты опроса'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // BMI Card
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Индекс массы тела (BMI)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${bmiResult.bmiValue} - ${bmiResult.descriptionText}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        bmiResult.getImagePath(patient.gender),
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Results Title
          Text(
            'Рекомендации по результатам опроса:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Results Content
          if (declinedQuestions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Отлично! Вы ответили "Да" на все вопросы.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          else
            ...declinedQuestions.map((question) => Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.question,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Возможные проблемы:',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )).toList(),
        ],
      ),
    );
  }
}
