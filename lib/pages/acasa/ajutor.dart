import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:startjuris/pages/chat/chat_page.dart';

class AjutorPage extends StatefulWidget {
  const AjutorPage({super.key});

  @override
  State<AjutorPage> createState() => _AjutorPageState();
}

class _AjutorPageState extends State<AjutorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Categories for help topics with enhanced visual design
  static final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.school_rounded,
      'title': 'Studiu',
      'color': const Color(0xFF4CAF50),
      'gradient': const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    },
    {
      'icon': Icons.people_alt_rounded,
      'title': 'Comunitate',
      'color': const Color(0xFF2196F3),
      'gradient': const [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
    {
      'icon': Icons.assignment_rounded,
      'title': 'Examene',
      'color': const Color(0xFFF44336),
      'gradient': const [Color(0xFFF44336), Color(0xFFD32F2F)],
    },
    {
      'icon': Icons.settings_rounded,
      'title': 'Setări',
      'color': const Color(0xFF9C27B0),
      'gradient': const [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    },
  ];

  // Extended Q&A data with categories
  static final List<Map<String, dynamic>> qaList = [
    {
      'category': 'Studiu',
      'question': 'Cum pot seta un obiectiv de studiu?',
      'answer':
          'Pentru a seta un obiectiv de studiu:\n\n1. Accesează secțiunea "Setează un obiectiv" din meniul principal\n2. Alege materiile dorite din lista disponibilă\n3. Stabilește timpul zilnic dedicat studiului\n4. Configurează reminder-uri pentru studiu\n5. Monitorizează-ți progresul în dashboard',
      'tags': ['obiective', 'studiu', 'planificare'],
      'videoUrl': 'https://example.com/tutorial-obiective',
      'icon': Icons.track_changes_rounded,
    },
    {
      'category': 'Examene',
      'question': 'Unde găsesc datele despre examene?',
      'answer':
          'Informațiile despre examene sunt disponibile în mai multe locuri:\n\n1. Secțiunea "Calendar Examene" - pentru date și termene\n2. Pagina dedicată fiecărui tip de examen (INM, Barou, INR)\n3. Notificări automate pentru deadline-uri importante\n4. Resurse și materiale de pregătire specifice',
      'tags': ['examene', 'calendar', 'termene'],
      'videoUrl': 'https://example.com/calendar-examene',
      'icon': Icons.event_note_rounded,
    },
    {
      'category': 'Comunitate',
      'question': 'Cum pot interacționa cu alți utilizatori?',
      'answer':
          'Platforma oferă multiple modalități de interacțiune:\n\n1. Forum-uri tematice pentru diferite subiecte\n2. Grupuri de studiu virtual\n3. Sesiuni de întrebări și răspunsuri live\n4. Schimb de materiale și resurse\n5. Mentorat și networking profesional',
      'tags': ['comunitate', 'networking', 'forum'],
      'videoUrl': 'https://example.com/comunitate-guide',
      'icon': Icons.groups_rounded,
    },
    {
      'category': 'Studiu',
      'question': 'Cum funcționează sistemul de grile?',
      'answer':
          'Sistemul de grile este proiectat pentru eficiență maximă:\n\n1. Teste adaptative bazate pe performanță\n2. Feedback instant pentru răspunsuri\n3. Explicații detaliate pentru fiecare întrebare\n4. Statistici și analize ale progresului\n5. Recomandări personalizate de studiu',
      'tags': ['grile', 'teste', 'evaluare'],
      'videoUrl': 'https://example.com/grile-tutorial',
      'icon': Icons.quiz_rounded,
    },
    {
      'category': 'Setări',
      'question': 'Cum îmi pot personaliza experiența în aplicație?',
      'answer':
          'Personalizarea aplicației include:\n\n1. Preferințe de notificări\n2. Teme vizuale și mod întunecat\n3. Organizarea conținutului preferat\n4. Setări de confidențialitate\n5. Sincronizare între dispozitive',
      'tags': ['setări', 'personalizare', 'preferințe'],
      'videoUrl': 'https://example.com/personalizare',
      'icon': Icons.palette_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredQA {
    if (_searchQuery.isEmpty) return qaList;
    return qaList.where((qa) {
      return qa['question'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          qa['answer'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          qa['tags'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildSliverAppBar(context),
                    SliverToBoxAdapter(
                      child: _buildSearchBar(),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: const Color(0xFF25D366),
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: const Color(0xFF25D366),
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          padding: const EdgeInsets.only(left: 16),
                          tabAlignment: TabAlignment.start,
                          tabs: categories
                              .map((category) => Tab(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(category['icon'] as IconData),
                                        const SizedBox(width: 8),
                                        Text(category['title'] as String),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: categories.map((category) {
                    final categoryQA = filteredQA
                        .where((qa) => qa['category'] == category['title'])
                        .toList();
                    return _buildQAList(categoryQA, category);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatPage(showGroups: true),
            ),
          );
        },
        backgroundColor: const Color(0xFF25D366),
        elevation: 4,
        icon: const Icon(Icons.support_agent_rounded),
        label: Text(
          'Asistență live',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      expandedHeight: size.height * 0.32,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        expandedTitleScale: 1.0,
        titlePadding: EdgeInsets.zero,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1FAB89),
                    Color(0xFF25D366),
                  ],
                ),
              ),
            ),
            // Decorative elements
            Positioned(
              right: -100,
              top: -50,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: -100,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(125),
                  ),
                ),
              ),
            ),
            // Content overlay with blur
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.support_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(0.95),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Centru de asistență',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Cum te putem\najuta astăzi?',
                      style: GoogleFonts.roboto(
                        fontSize: 36,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Text(
                      'Găsește rapid răspunsurile de care ai nevoie',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.roboto(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Caută în centrul de ajutor...',
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQAList(List<Map<String, dynamic>> questions, Map<String, dynamic> category) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nu am găsit rezultate pentru căutarea ta',
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final qa = questions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 2,
            shadowColor: category['color'].withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: category['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    qa['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  qa['question'] as String,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qa['answer'] as String,
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade700,
                            height: 1.5,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (qa['videoUrl'] != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.play_circle_outline_rounded,
                                size: 20,
                              ),
                              label: Text(
                                'Vezi tutorialul video',
                                style: GoogleFonts.roboto(
                                  letterSpacing: -0.3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: category['color'],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (qa['tags'] as List<String>).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: category['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '#$tag',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: category['color'],
                                  letterSpacing: -0.2,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}