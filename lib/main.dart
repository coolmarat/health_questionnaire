import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/question.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Опросник здоровья',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserInputScreen(),
    );
  }
}

class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final TextEditingController _ageController = TextEditingController();
  int? _gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Введите данные'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Возраст',
                hintText: 'Введите ваш возраст',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Выберите пол:'),
            RadioListTile<int>(
              title: const Text('Мужской'),
              value: 1,
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
            ),
            RadioListTile<int>(
              title: const Text('Женский'),
              value: 2,
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_ageController.text.isNotEmpty && _gender != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionnaireScreen(
                          age: int.parse(_ageController.text),
                          gender: _gender!,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Начать опрос'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionnaireScreen extends StatefulWidget {
  final int age;
  final int gender;

  const QuestionnaireScreen({
    super.key,
    required this.age,
    required this.gender,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  List<Question> _questions = [];
  final Map<String, bool> _answers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');
    final data = json.decode(jsonString);
    final List<dynamic> questionsJson = data['questions'];

    setState(() {
      _questions = questionsJson
          .map((q) => Question.fromJson(q))
          .where((q) => q.gender == -1 || q.gender == widget.gender)
          .where((q) => widget.age >= q.from && (q.to == null || widget.age <= q.to!))
          .toList();
      _isLoading = false;
    });
  }

  void _showResults() {
    final notPassedTests = _questions
        .where((q) => _answers[q.id] == null || _answers[q.id] == false)
        .map((q) => q.name)
        .toList();

    if (notPassedTests.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Поздравляем!'),
          content: const Text('Вы прошли все необходимые анализы'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Рекомендуемые анализы'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Вам следует пройти следующие анализы:'),
                const SizedBox(height: 10),
                ...notPassedTests.map((test) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('• $test'),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Опросник'),
      ),
      body: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(question.question),
              subtitle: Text('Периодичность: ${question.year} год(а)'),
              trailing: Switch(
                value: _answers[question.id] ?? false,
                onChanged: (value) {
                  setState(() {
                    _answers[question.id] = value;
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showResults,
        child: const Icon(Icons.check),
      ),
    );
  }
}
