import 'water_calculator.dart';

class WaterSettings {
  final double dailyGoal; // în ml
  final bool enableReminders;
  final List<int> reminderIntervals; // în minute
  final String preferredUnit; // 'ml' sau 'oz'
  final bool smartGoalAdjustment;
  final Map<String, int> customContainers; // nume -> ml
  final bool trackCaffeine;
  final int caffeineLimit; // în mg
  final bool trackSodium;
  final int sodiumLimit; // în mg
  final List<String> preferredBeverages;
  final bool enableWeatherAdjustment;
  final bool enableActivityAdjustment;

  // Informații personale pentru calculul necesarului de apă
  final String? gender;
  final int? age;
  final double? weight; // în kg
  final double? height; // în cm
  final int activityLevel; // 1-5
  final bool isPregnant;
  final bool isBreastfeeding;

  WaterSettings({
    this.dailyGoal = 2500,
    this.enableReminders = true,
    this.reminderIntervals = const [60, 120, 180],
    this.preferredUnit = 'ml',
    this.smartGoalAdjustment = true,
    this.customContainers = const {
      'Pahar mic': 200,
      'Pahar mediu': 300,
      'Pahar mare': 400,
      'Sticlă mică': 500,
      'Sticlă medie': 750,
      'Sticlă mare': 1000,
    },
    this.trackCaffeine = false,
    this.caffeineLimit = 400,
    this.trackSodium = false,
    this.sodiumLimit = 2300,
    this.preferredBeverages = const ['Apă plată', 'Apă minerală', 'Ceai verde', 'Ceai negru'],
    this.enableWeatherAdjustment = true,
    this.enableActivityAdjustment = true,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.activityLevel = 2,
    this.isPregnant = false,
    this.isBreastfeeding = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'enableReminders': enableReminders,
      'reminderIntervals': reminderIntervals,
      'preferredUnit': preferredUnit,
      'smartGoalAdjustment': smartGoalAdjustment,
      'customContainers': Map<String, dynamic>.from(customContainers),
      'trackCaffeine': trackCaffeine,
      'caffeineLimit': caffeineLimit,
      'trackSodium': trackSodium,
      'sodiumLimit': sodiumLimit,
      'preferredBeverages': preferredBeverages,
      'enableWeatherAdjustment': enableWeatherAdjustment,
      'enableActivityAdjustment': enableActivityAdjustment,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'activityLevel': activityLevel,
      'isPregnant': isPregnant,
      'isBreastfeeding': isBreastfeeding,
    };
  }

  factory WaterSettings.fromJson(Map<String, dynamic> json) {
    return WaterSettings(
      dailyGoal: (json['dailyGoal'] ?? 2500).toDouble(),
      enableReminders: json['enableReminders'] ?? true,
      reminderIntervals: List<int>.from(json['reminderIntervals'] ?? [60, 120, 180]),
      preferredUnit: json['preferredUnit'] ?? 'ml',
      smartGoalAdjustment: json['smartGoalAdjustment'] ?? true,
      customContainers: Map<String, int>.from(json['customContainers'] ?? {
        'Pahar mic': 200,
        'Pahar mediu': 300,
        'Pahar mare': 400,
        'Sticlă mică': 500,
        'Sticlă medie': 750,
        'Sticlă mare': 1000,
      }),
      trackCaffeine: json['trackCaffeine'] ?? false,
      caffeineLimit: json['caffeineLimit'] ?? 400,
      trackSodium: json['trackSodium'] ?? false,
      sodiumLimit: json['sodiumLimit'] ?? 2300,
      preferredBeverages: List<String>.from(json['preferredBeverages'] ?? ['Apă plată', 'Apă minerală', 'Ceai verde', 'Ceai negru']),
      enableWeatherAdjustment: json['enableWeatherAdjustment'] ?? true,
      enableActivityAdjustment: json['enableActivityAdjustment'] ?? true,
      gender: json['gender'],
      age: json['age'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      activityLevel: json['activityLevel'] ?? 2,
      isPregnant: json['isPregnant'] ?? false,
      isBreastfeeding: json['isBreastfeeding'] ?? false,
    );
  }

  WaterSettings copyWith({
    double? dailyGoal,
    bool? enableReminders,
    List<int>? reminderIntervals,
    String? preferredUnit,
    bool? smartGoalAdjustment,
    Map<String, int>? customContainers,
    bool? trackCaffeine,
    int? caffeineLimit,
    bool? trackSodium,
    int? sodiumLimit,
    List<String>? preferredBeverages,
    bool? enableWeatherAdjustment,
    bool? enableActivityAdjustment,
    String? gender,
    int? age,
    double? weight,
    double? height,
    int? activityLevel,
    bool? isPregnant,
    bool? isBreastfeeding,
  }) {
    return WaterSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      enableReminders: enableReminders ?? this.enableReminders,
      reminderIntervals: reminderIntervals ?? this.reminderIntervals,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      smartGoalAdjustment: smartGoalAdjustment ?? this.smartGoalAdjustment,
      customContainers: customContainers ?? this.customContainers,
      trackCaffeine: trackCaffeine ?? this.trackCaffeine,
      caffeineLimit: caffeineLimit ?? this.caffeineLimit,
      trackSodium: trackSodium ?? this.trackSodium,
      sodiumLimit: sodiumLimit ?? this.sodiumLimit,
      preferredBeverages: preferredBeverages ?? this.preferredBeverages,
      enableWeatherAdjustment: enableWeatherAdjustment ?? this.enableWeatherAdjustment,
      enableActivityAdjustment: enableActivityAdjustment ?? this.enableActivityAdjustment,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      isPregnant: isPregnant ?? this.isPregnant,
      isBreastfeeding: isBreastfeeding ?? this.isBreastfeeding,
    );
  }

  double getAdjustedGoal({
    required double temperature,
    required double humidity,
    required int activeMinutes,
  }) {
    if (!hasPersonalInfo()) {
      return dailyGoal;
    }

    final calculatedGoal = WaterCalculator.calculateDailyNeeds(
      gender: gender!,
      age: age!,
      weight: weight!,
      height: height!,
      activityLevel: activityLevel,
      isPregnant: isPregnant,
      isBreastfeeding: isBreastfeeding,
      temperature: temperature,
      humidity: humidity,
    );

    return calculatedGoal;
  }

  bool hasPersonalInfo() {
    return gender != null && age != null && weight != null && height != null;
  }

  String formatVolume(double volume) {
    if (preferredUnit == 'oz') {
      return '${(volume / 29.5735).toStringAsFixed(1)} oz';
    }
    return '${volume.toStringAsFixed(0)} ml';
  }

  List<String> getPersonalizedTips() {
    if (!hasPersonalInfo()) {
      return [
        'Completează-ți informațiile personale pentru recomandări personalizate.',
        'În general, se recomandă consumul a 2-3 litri de apă pe zi.',
      ];
    }

    return WaterCalculator.getHydrationTips(
      recommendedIntake: getAdjustedGoal(
        temperature: 25,
        humidity: 50,
        activeMinutes: 0,
      ),
      age: age!,
      activityLevel: activityLevel,
    );
  }
}