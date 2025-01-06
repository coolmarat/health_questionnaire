enum BMIDescription {
  deficit,
  normal,
  predObesity,
  obesity1,
  obesity2,
  obesity3,
}

class BMIResult {
  final double bmiValue;
  final BMIDescription description;
  final String descriptionText;

  BMIResult({
    required this.bmiValue,
    required this.description,
    required this.descriptionText,
  });

  String getImagePath(int gender) {
    final prefix = gender == 1 ? 'man' : 'woman';
    final suffix = switch (description) {
      BMIDescription.deficit => 'underweight',
      BMIDescription.normal => 'normal',
      BMIDescription.predObesity => 'overweight',
      BMIDescription.obesity1 => 'obese1',
      BMIDescription.obesity2 => 'obese2',
      BMIDescription.obesity3 => 'obese3',
    };
    return 'assets/png/${prefix}_$suffix.png';
  }

  static BMIResult calculate(double bmi) {
    BMIDescription desc;
    String text;

    if (bmi < 19) {
      desc = BMIDescription.deficit;
      text = 'Дефицит массы тела';
    } else if (bmi < 25) {
      desc = BMIDescription.normal;
      text = 'Норма';
    } else if (bmi < 30) {
      desc = BMIDescription.predObesity;
      text = 'Предожирение';
    } else if (bmi < 35) {
      desc = BMIDescription.obesity1;
      text = 'Ожирение I степени';
    } else if (bmi < 40) {
      desc = BMIDescription.obesity2;
      text = 'Ожирение II степени';
    } else {
      desc = BMIDescription.obesity3;
      text = 'Ожирение III степени';
    }

    return BMIResult(
      bmiValue: double.parse(bmi.toStringAsFixed(2)),
      description: desc,
      descriptionText: text,
    );
  }
}
