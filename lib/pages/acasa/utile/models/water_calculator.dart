class WaterCalculator {
  static double calculateDailyNeeds({
    required String gender,
    required int age,
    required double weight, // în kg
    required double height, // în cm
    required int activityLevel, // 1-5 (1: sedentar, 5: foarte activ)
    required bool isPregnant,
    required bool isBreastfeeding,
    required double temperature, // în grade Celsius
    required double humidity, // în procente
  }) {
    // Calculul de bază folosind formula standard
    // Folosim formula: 35ml per kg pentru adulți activi
    double baseNeeds = weight * 35; // 35ml per kg corp
    
    // Ajustare în funcție de gen
    if (gender.toLowerCase() == 'feminin') {
      baseNeeds *= 0.9; // Femeile au nevoie de aproximativ 90% din necesarul bărbaților
    }
    
    // Ajustare în funcție de vârstă
    if (age < 30) {
      baseNeeds *= 1.1; // Persoanele tinere au nevoie de mai multă apă
    } else if (age > 55) {
      baseNeeds *= 0.95; // Persoanele în vârstă au nevoie de puțin mai puțină apă
    }
    
    // Ajustare în funcție de nivelul de activitate
    double activityMultiplier = switch (activityLevel) {
      1 => 0.8,    // Sedentar
      2 => 1.0,    // Ușor activ
      3 => 1.2,    // Moderat activ
      4 => 1.4,    // Foarte activ
      5 => 1.6,    // Extra activ
      _ => 1.0,
    };
    baseNeeds *= activityMultiplier;
    
    // Ajustare pentru sarcină sau alăptare
    if (isPregnant) {
      baseNeeds += 300; // 300ml extra pentru sarcină
    }
    if (isBreastfeeding) {
      baseNeeds += 700; // 700ml extra pentru alăptare
    }
    
    // Ajustare în funcție de temperatură
    if (temperature > 25) {
      baseNeeds += (temperature - 25) * 100; // 100ml în plus pentru fiecare grad peste 25°C
    }
    
    // Ajustare în funcție de umiditate
    if (humidity < 30) {
      baseNeeds += (30 - humidity) * 20; // 20ml în plus pentru fiecare procent sub 30%
    }
    
    // Ajustare minimă și maximă
    if (baseNeeds < 1500) baseNeeds = 1500; // Minim 1.5L
    if (baseNeeds > 4000) baseNeeds = 4000; // Maxim 4L
    
    // Rotunjire la cel mai apropiat 100ml
    return (baseNeeds / 100).round() * 100;
  }

  static String getActivityLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Sedentar (puțină sau deloc activitate fizică)';
      case 2:
        return 'Ușor activ (exerciții ușoare/sport 1-3 zile/săptămână)';
      case 3:
        return 'Moderat activ (exerciții moderate/sport 3-5 zile/săptămână)';
      case 4:
        return 'Foarte activ (exerciții intense/sport 6-7 zile/săptămână)';
      case 5:
        return 'Extra activ (exerciții foarte intense/sport & muncă fizică)';
      default:
        return 'Nivel de activitate necunoscut';
    }
  }

  static List<String> getHydrationTips({
    required double recommendedIntake,
    required int age,
    required int activityLevel,
  }) {
    final tips = <String>[
      'Obiectivul tău zilnic recomandat este de ${recommendedIntake.toStringAsFixed(0)}ml de apă.',
      'Încearcă să bei apă la intervale regulate pe parcursul zilei.',
    ];

    if (age > 55) {
      tips.add('La vârsta ta, este important să menții o hidratare constantă, chiar dacă nu simți sete.');
    }

    if (activityLevel >= 4) {
      tips.add('Cu nivelul tău ridicat de activitate, consideră consumul de băuturi sportive pentru exerciții ce depășesc 1 oră.');
    }

    tips.addAll([
      'Bea un pahar de apă la fiecare masă și între mese.',
      'Setează alarme pentru a-ți aminti să bei apă regulat.',
      'Monitorizează culoarea urinei - ar trebui să fie galben pai sau mai deschisă.',
    ]);

    return tips;
  }
} 