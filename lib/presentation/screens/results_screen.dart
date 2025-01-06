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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
            ),
            const SizedBox(height: 24),
            Text(
              'Рекомендации по результатам опроса:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: declinedQuestions.isEmpty
                  ? const Center(
                      child: Text(
                        'Отлично! Вы ответили "Да" на все вопросы.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: declinedQuestions.length,
                      itemBuilder: (context, index) {
                        final question = declinedQuestions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
