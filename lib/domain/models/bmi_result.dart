enum BMIDescription {
  anorexia,
  deficit,
  normal,
  overweight,
  obesity1,
  obesity2,
  obesity3,
  obesity4,
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
      BMIDescription.anorexia => 'anorexia',
      BMIDescription.deficit => 'underweight',
      BMIDescription.normal => 'normal',
      BMIDescription.overweight => 'overweight',
      BMIDescription.obesity1 => 'obese1',
      BMIDescription.obesity2 => 'obese2',
      BMIDescription.obesity3 => 'obese3',
      BMIDescription.obesity4 => 'obese4',
    };
    return 'assets/png/${prefix}_$suffix.png';
  }

  static BMIResult calculate(double bmi) {
    BMIDescription desc;
    String text;

    if (bmi < 17.5) {
      desc = BMIDescription.anorexia;
      text = 'Анорексия';
    } else if (bmi < 18.5) {
      desc = BMIDescription.deficit;
      text = 'Недостаток массы';
    } else if (bmi < 23) {
      desc = BMIDescription.normal;
      text = 'Норма';
    } else if (bmi < 27.5) {
      desc = BMIDescription.overweight;
      text = 'Избыточная масса тела';
    } else if (bmi < 30) {
      desc = BMIDescription.obesity1;
      text = 'Ожирение I степени';
    } else if (bmi < 35) {
      desc = BMIDescription.obesity2;
      text = 'Ожирение II степени';
    } else if (bmi < 40) {
      desc = BMIDescription.obesity3;
      text = 'Ожирение III степени';
    } else {
      desc = BMIDescription.obesity4;
      text = 'Ожирение IV степени';
    }

    return BMIResult(
      bmiValue: double.parse(bmi.toStringAsFixed(2)),
      description: desc,
      descriptionText: text,
    );
  }
}
