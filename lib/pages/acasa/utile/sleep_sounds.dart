class SleepSound {
  final String title;
  final String assetPath;
  final String duration;
  final String description;

  const SleepSound({
    required this.title,
    required this.assetPath,
    required this.duration,
    required this.description,
  });
}

const sleepSounds = [
  SleepSound(
    title: 'Ploaie liniștită',
    assetPath: 'assets/sounds/sleep/rain.mp3',
    duration: '30m',
    description: 'Sunetul relaxant al ploii care cade ușor',
  ),
  SleepSound(
    title: 'Valuri oceanice',
    assetPath: 'assets/sounds/sleep/waves.mp3',
    duration: '30m',
    description: 'Valurile oceanului care se sparg de țărm',
  ),
  SleepSound(
    title: 'Pădure nocturnă',
    assetPath: 'assets/sounds/sleep/forest.mp3',
    duration: '30m',
    description: 'Sunete ambientale din pădure noaptea',
  ),
  SleepSound(
    title: 'Foc de tabără',
    assetPath: 'assets/sounds/sleep/fire.mp3',
    duration: '30m',
    description: 'Trosnetul liniștitor al lemnelor în foc',
  ),
  SleepSound(
    title: 'Vânt prin frunze',
    assetPath: 'assets/sounds/sleep/wind.mp3',
    duration: '30m',
    description: 'Sunetul vântului printre frunzele copacilor',
  ),
  SleepSound(
    title: 'Ploaie pe acoperiș',
    assetPath: 'assets/sounds/sleep/roof_rain.mp3',
    duration: '30m',
    description: 'Picături de ploaie care cad pe acoperiș',
  ),
]; 