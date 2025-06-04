import 'package:flutter/material.dart';
import '../models/water_calculator.dart';
import '../models/water_settings.dart';

class WaterOnboardingDialog extends StatefulWidget {
  final Function(WaterSettings) onComplete;

  const WaterOnboardingDialog({
    super.key,
    required this.onComplete,
  });

  @override
  State<WaterOnboardingDialog> createState() => _WaterOnboardingDialogState();
}

class _WaterOnboardingDialogState extends State<WaterOnboardingDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  String? _age;
  String? _weight;
  String? _height;
  int _activityLevel = 2;
  bool _isPregnant = false;
  bool _isBreastfeeding = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Să începem!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pentru a-ți oferi un plan personalizat de hidratare, avem nevoie de câteva informații despre tine.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Gen
              DropdownButtonFormField<String>(
                value: _gender,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gen',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'masculin', child: Text('Masculin')),
                  DropdownMenuItem(value: 'feminin', child: Text('Feminin')),
                ],
                validator: (value) => value == null ? 'Selectează genul' : null,
                onChanged: (value) => setState(() {
                  _gender = value;
                  if (value == 'masculin') {
                    _isPregnant = false;
                    _isBreastfeeding = false;
                  }
                }),
              ),
              const SizedBox(height: 16),
              
              // Vârstă
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Vârstă',
                  border: OutlineInputBorder(),
                  suffixText: 'ani',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introdu vârsta';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 12 || age > 120) {
                    return 'Vârstă invalidă (12-120)';
                  }
                  return null;
                },
                onChanged: (value) => _age = value,
              ),
              const SizedBox(height: 16),
              
              // Greutate
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Greutate',
                  border: OutlineInputBorder(),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introdu greutatea';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 300) {
                    return 'Greutate invalidă (30-300)';
                  }
                  return null;
                },
                onChanged: (value) => _weight = value,
              ),
              const SizedBox(height: 16),
              
              // Înălțime
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Înălțime',
                  border: OutlineInputBorder(),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introdu înălțimea';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Înălțime invalidă (100-250)';
                  }
                  return null;
                },
                onChanged: (value) => _height = value,
              ),
              const SizedBox(height: 16),
              
              // Nivel de activitate
              DropdownButtonFormField<int>(
                value: _activityLevel,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Nivel de activitate',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(5, (index) => index + 1).map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      WaterCalculator.getActivityLevelDescription(level),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  if (value != null) _activityLevel = value;
                }),
              ),
              const SizedBox(height: 16),
              
              // Opțiuni pentru femei
              if (_gender == 'feminin') ...[
                SwitchListTile(
                  title: const Text('Sunt însărcinată'),
                  value: _isPregnant,
                  onChanged: (value) => setState(() {
                    _isPregnant = value;
                    if (value) _isBreastfeeding = false;
                  }),
                ),
                SwitchListTile(
                  title: const Text('Alăptez'),
                  value: _isBreastfeeding,
                  onChanged: (value) => setState(() {
                    _isBreastfeeding = value;
                    if (value) _isPregnant = false;
                  }),
                ),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text('Calculează planul meu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final settings = WaterSettings(
        gender: _gender,
        age: int.tryParse(_age ?? ''),
        weight: double.tryParse(_weight ?? ''),
        height: double.tryParse(_height ?? ''),
        activityLevel: _activityLevel,
        isPregnant: _isPregnant,
        isBreastfeeding: _isBreastfeeding,
        enableReminders: true,
        smartGoalAdjustment: true,
      );
      
      widget.onComplete(settings);
    }
  }
} 