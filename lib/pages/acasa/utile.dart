import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'utile/pomodoro_page.dart';
import 'utile/water_page.dart';
import 'utile/sleep_page.dart';
import 'utile/reflections_page.dart';
import 'utile/meditation_page.dart';
import 'utile/workout_page.dart';
import 'utile/contemplation_detail_page.dart';

class UtilePage extends StatelessWidget {
  const UtilePage({super.key});

  static const String _headerImage = 'assets/utile/10.png';

  static final List<Map<String, dynamic>> _icons = [
    {
      'name': 'Cronometru',
      'icon': Icons.timer,
      'color': Colors.blue,
      'page': const PomodoroPage(),
    },
    {
      'name': 'Hidratare',
      'icon': Icons.water_drop,
      'color': Colors.cyan,
      'page': const WaterPage(),
    },
    {
      'name': 'Somn',
      'icon': Icons.nightlight_round,
      'color': Colors.indigo,
      'page': const SleepPage(),
    },
    {
      'name': 'Reflecții',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'page': const ReflectionsPage(),
    },
    {
      'name': 'Meditație',
      'icon': Icons.self_improvement,
      'color': Colors.teal,
      'page': const MeditationPage(),
    },
    {
      'name': 'Antrenament',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'page': const WorkoutPage(),
    },
  ];

  static const List<List<Map<String, String>>> _contemplations = [
    [
      {'image': 'assets/utile/21.png', 'title': 'Scop', 'description': 'Clarifică-ți obiectivele în viață și potrivirea cu profesia juridică.'},
      {'image': 'assets/utile/22.png', 'title': 'Anxietate', 'description': 'Observă stresul legat de volumul de studiu, aplică tehnici simple de relaxare.'},
    ],
    [
      {'image': 'assets/utile/23.png', 'title': 'Plan de studiu', 'description': 'Evaluează orarul actual, identifică lacune și ajustează pașii pentru eficiență.'},
      {'image': 'assets/utile/24.png', 'title': 'Motivație', 'description': 'Descoperă zilnic motive puternice care susțin visul juridic.'},
    ],
    [
      {'image': 'assets/utile/25.png', 'title': 'Echilibru', 'description': 'Monitorizează timpul pentru studiu, odihnă și socializare, previne epuizarea.'},
      {'image': 'assets/utile/26.png', 'title': 'Progres', 'description': 'Notează realizările la grile și adaptează constant metodele de învățare.'},
    ],
  ];

  static const List<List<Map<String, String>>> _beforeSleep = [
    [
      {'image': 'assets/utile/peisaj/7.png', 'title': 'Ploaie torențială', 'duration': '32 minute'},
      {'image': 'assets/utile/peisaj/8.png', 'title': 'Pădure tropicală', 'duration': '30 minute'},
    ],
    [
      {'image': 'assets/utile/peisaj/9.png', 'title': 'Ploaie măruntă', 'duration': '28 minute'},
      {'image': 'assets/utile/peisaj/10.png', 'title': 'Malul oceanului', 'duration': '30 minute'},
    ],
    [
      {'image': 'assets/utile/peisaj/11.png', 'title': 'Triluri la malul oceanului', 'duration': '32 minute'},
      {'image': 'assets/utile/peisaj/12.png', 'title': 'Noapte la malul oceanului', 'duration': '29 minute'},
    ],
    [
      {'image': 'assets/utile/peisaj/13.png', 'title': 'Noapte pe câmpia nesfârșită', 'duration': '31 minute'},
      {'image': 'assets/utile/peisaj/14.png', 'title': 'Zumzet discret de insecte', 'duration': '30 minute'},
    ],
    [
      {'image': 'assets/utile/peisaj/15.png', 'title': 'Ploaie liniștită', 'duration': '28 minute'},
      {'image': 'assets/utile/peisaj/16.png', 'title': 'Picuri dansând pe bălți', 'duration': '29 minute'},
    ],
    [
      {'image': 'assets/utile/peisaj/17.png', 'title': 'Furtună ploioasă', 'duration': '31 minute'},
      {'image': 'assets/utile/peisaj/18.png', 'title': 'Furtună cu tunete', 'duration': '30 minute'},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Instrumente utile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 700 / 300,
                        child: Image.asset(
                          _headerImage,
                          fit: BoxFit.contain,
                          width: constraints.maxWidth,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Icons Row
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _icons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  return GestureDetector(
                    onTap: () {
                      if (icon['page'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => icon['page'],
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                icon['color'].withOpacity(0.7),
                                icon['color'],
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: icon['color'].withOpacity(0.3),
                                offset: const Offset(2, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            icon['icon'],
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          icon['name'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Hydration Containers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/utile/11.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/utile/12.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Contemplations Section
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Contemplări',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    color: Colors.white,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 220,
                        autoPlay: false,
                        enlargeCenterPage: false,
                        viewportFraction: 0.75,
                        enableInfiniteScroll: false,
                        padEnds: false,
                      ),
                      items: _contemplations.map((pair) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
                          child: Column(
                            children: pair.map((item) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                width: double.infinity,
                                height: 106,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ContemplationDetailPage(
                                            title: item['title']!,
                                            description: item['description']!,
                                            image: item['image']!,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                          ),
                                          child: Image.asset(
                                            item['image']!,
                                            width: 90,
                                            height: 106,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  item['title']!,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item['description']!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Before Sleep Section
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Utile înainte de somn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    color: Colors.white,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 260,
                        autoPlay: false,
                        enlargeCenterPage: false,
                        viewportFraction: 0.75,
                        enableInfiniteScroll: false,
                        padEnds: false,
                      ),
                      items: _beforeSleep.map((pair) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
                          child: Column(
                            children: pair.map((item) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                width: double.infinity,
                                height: 126,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                      child: Image.asset(
                                        item['image']!,
                                        width: 120,
                                        height: 126,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item['title']!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['duration']!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
