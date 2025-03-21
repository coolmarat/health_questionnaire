import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/question.dart';
import '../../domain/models/bmi_result.dart';
import '../../domain/models/patient_model.dart';

class Hospital {
  final String name;
  final List<String> phones;

  Hospital({required this.name, required this.phones});

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'],
      phones: List<String>.from(json['phones']),
    );
  }
}

class ResultsScreen extends StatefulWidget {
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
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Hospital> hospitals = [];

  @override
  void initState() {
    super.initState();
    loadHospitals();
  }

  Future<void> loadHospitals() async {
    try {
      final String jsonString =
          await DefaultAssetBundle.of(context).loadString('assets/phones.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        hospitals = jsonList.map((json) => Hospital.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint('Error loading hospitals: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove any non-digit characters from the phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Different handling for web platform
    if (kIsWeb) {
      final webUri = Uri.parse('tel:$cleanNumber');
      try {
        final canLaunch = await canLaunchUrl(webUri);
        if (!canLaunch) {
          // Если звонок не поддерживается, копируем номер в буфер обмена
          await _copyToClipboard(cleanNumber);
          return;
        }
        await launchUrl(webUri, webOnlyWindowName: '_self');
      } catch (e) {
        // В случае ошибки тоже копируем номер
        await _copyToClipboard(cleanNumber);
      }
      return;
    }

    // Mobile platform handling
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Если звонок не поддерживается на мобильном устройстве, тоже копируем номер
        await _copyToClipboard(cleanNumber);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось совершить звонок: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String phoneNumber) async {
    try {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Номер $phoneNumber скопирован в буфер обмена',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось скопировать номер телефона'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final declinedQuestions = widget.questions
        .where((question) => widget.answers[question.id] != true)
        .toList();

    final bmiResult = BMIResult.calculate(
      widget.patient.getBMI(),
      age: widget.patient.age,
    );

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
                        bmiResult.getImagePath(widget.patient.gender),
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
                  'Вы прошли все необходимые исследования.',
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
                )),

          const SizedBox(height: 24),

          // Hospitals Section
          Text(
            'Контакты больниц:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          ...hospitals.map((hospital) => Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      ...hospital.phones.map((phone) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () => _makePhoneCall(phone),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 24,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
