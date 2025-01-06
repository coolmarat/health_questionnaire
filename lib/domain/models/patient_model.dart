class PatientModel {
  final int age;
  final int gender;
  final int height;
  final int weight;

  PatientModel({
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  double getBMI() {
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }
}
