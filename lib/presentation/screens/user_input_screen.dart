import 'package:flutter/material.dart';
import '../../domain/models/patient_model.dart';
import 'questionnaire_screen.dart';

class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  int? _gender;
  
  String? _ageError;
  String? _heightError;
  String? _weightError;

  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  void _validateAge(String value) {
    setState(() {
      if (value.isEmpty) {
        _ageError = null;
      } else {
        try {
          final age = int.parse(value);
          if (age < 18) {
            _ageError = 'Возраст должен быть не менее 18 лет';
          } else if (age > 99) {
            _ageError = 'Возраст должен быть не более 99 лет';
          } else {
            _ageError = null;
          }
        } catch (e) {
          _ageError = 'Введите корректное число';
        }
      }
    });
  }

  void _validateWeight(String value) {
    setState(() {
      if (value.isEmpty) {
        _weightError = null;
      } else {
        try {
          final weight = int.parse(value);
          if (weight < 20) {
            _weightError = 'Вес должен быть не менее 20 кг';
          } else if (weight > 300) {
            _weightError = 'Вес должен быть не более 300 кг';
          } else {
            _weightError = null;
          }
        } catch (e) {
          _weightError = 'Введите корректное число';
        }
      }
    });
  }

  void _validateHeight(String value) {
    setState(() {
      if (value.isEmpty) {
        _heightError = null;
      } else {
        try {
          final height = int.parse(value);
          if (height < 100) {
            _heightError = 'Рост должен быть не менее 100 см';
          } else if (height > 250) {
            _heightError = 'Рост должен быть не более 250 см';
          } else {
            _heightError = null;
          }
        } catch (e) {
          _heightError = 'Введите корректное число';
        }
      }
    });
  }

  bool get _isFormValid {
    return _ageController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _gender != null &&
        _ageError == null &&
        _heightError == null &&
        _weightError == null;
  }

  void _startQuestionnaire() {
    if (_isFormValid) {
      final patient = PatientModel(
        age: int.parse(_ageController.text),
        gender: _gender!,
        height: int.parse(_heightController.text),
        weight: int.parse(_weightController.text),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionnaireScreen(patient: patient),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все поля'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Введите данные'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              focusNode: _ageFocusNode,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => _heightFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Возраст',
                border: const OutlineInputBorder(),
                errorText: _ageError,
                errorStyle: const TextStyle(color: Colors.red),
              ),
              onChanged: _validateAge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              focusNode: _heightFocusNode,
              textInputAction: TextInputAction.next,
              onEditingComplete: () => _weightFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Рост (см)',
                border: const OutlineInputBorder(),
                errorText: _heightError,
                errorStyle: const TextStyle(color: Colors.red),
              ),
              onChanged: _validateHeight,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              focusNode: _weightFocusNode,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Вес (кг)',
                border: const OutlineInputBorder(),
                errorText: _weightError,
                errorStyle: const TextStyle(color: Colors.red),
              ),
              onChanged: _validateWeight,
            ),
            const SizedBox(height: 20),
            const Text('Пол:', style: TextStyle(fontSize: 16)),
            RadioListTile(
              title: const Text('Мужской'),
              value: 1,
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
            ),
            RadioListTile(
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startQuestionnaire,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Начать опрос', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }
}
