import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'backend/services/api_service_coduri.dart' as code_service;

class ModernCodeReader extends StatefulWidget {
  final String codeId;
  final String codeTitle;

  const ModernCodeReader({
    super.key,
    required this.codeId,
    required this.codeTitle,
  });

  @override
  State<ModernCodeReader> createState() => _ModernCodeReaderState();
}

class _ModernCodeReaderState extends State<ModernCodeReader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Animation<double> _fadeInAnimation;
  late Animation<double> _searchSlideAnimation;

  code_service.ApiServiceCoduri? _apiService;
  code_service.ParsedCode? _codeStructure;
  bool _isLoading = true;
  bool _isSearchVisible = false;
  String? _errorMessage;

  final TextEditingController _searchTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<code_service.Article> _allArticles = [];
  List<code_service.Article> _filteredArticles = [];
  List<dynamic> _searchResults = [];
  Timer? _searchTimer;
  String _currentSearchQuery = '';

  double _fontSize = 16.0;
  double _lineHeight = 1.5;

  Set<String> _bookmarkedArticles = {};
  Set<String> _highlightedArticles = {};
  List<String> _readingPlan = [];

  int _currentTabIndex = 0;
  final List<String> _tabTitles = ['Toate', 'Plan', 'Salvate', 'Evidențiate'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _initializeAnimations();
    _initializeApiService();
    _loadPreferences();
    _loadCodeStructure();

    _searchTextController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _searchSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _initializeApiService() {
    _apiService = code_service.ApiServiceCoduri(token: null);
  }

  Future<void> _loadCodeStructure() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_apiService == null) {
        throw Exception('API service not initialized');
      }

      print('Loading code structure for: ${widget.codeId}');
      final parsedCode = await _apiService!.getCodeContent(widget.codeId);
      print('Received parsed code: ${parsedCode.id}, articles: ${parsedCode.articles.length}');

      setState(() {
        _codeStructure = parsedCode;
        _allArticles = _extractAllArticles(parsedCode);
        _filteredArticles = _allArticles;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading code structure: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Eroare neașteptată: ${e.toString()}';
      });
    }

    if (_errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Reîncercare',
            textColor: Colors.white,
            onPressed: _loadCodeStructure,
          ),
        ),
      );
    }
  }

  List<code_service.Article> _extractAllArticles(code_service.ParsedCode structure) {
    final articles = <code_service.Article>[...structure.articles];

    for (var book in structure.books) {
      for (var title in book.titles) {
        for (var chapter in title.chapters) {
          for (var section in chapter.sections) {
            articles.addAll(section.articles);
            for (var subsection in section.subsections) {
              articles.addAll(subsection.articles);
            }
          }
        }
      }
    }

    debugPrint('✅ Extracted ${articles.length} articles total');
    return articles;
  }

  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchTextController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _currentSearchQuery = query;
    });

    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _filteredArticles = _allArticles;
      });
      return;
    }

    try {
      if (_apiService == null) {
        throw Exception('API service not initialized');
      }

      final results = await _apiService!.searchContent(
        query: query,
        codeType: widget.codeId,
      );

      setState(() {
        _searchResults = results;
        if (results.isNotEmpty) {
          final matchingIds = results.map((m) => m['articleId'] as String).toSet();
          _filteredArticles = _allArticles.where((a) => matchingIds.contains(a.id)).toList();
        } else {
          _filteredArticles = [];
        }
      });
    } catch (e) {
      debugPrint('❌ Backend search failed: $e, falling back to local search');
      _performLocalSearch(query);
    }
  }

  void _performLocalSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = _allArticles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
             article.content.toLowerCase().contains(lowerQuery) ||
             article.number.toLowerCase().contains(lowerQuery) ||
             article.keywords.any((keyword) => keyword.toLowerCase().contains(lowerQuery));
    }).toList();

    setState(() {
      _filteredArticles = filtered;
      _searchResults = [];
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchTextController.clear();
        _searchResults = [];
        _filteredArticles = _allArticles;
        _currentSearchQuery = '';
      }
    });
  }

  List<code_service.Article> _getTabArticles() {
    if (_allArticles.isEmpty) {
      return [];
    }

    switch (_currentTabIndex) {
      case 0:
        return _filteredArticles.isNotEmpty ? _filteredArticles : _allArticles;
      case 1:
        final planArticles = _allArticles.where((article) =>
            _readingPlan.contains(article.id)).toList();
        return planArticles;
      case 2:
        final savedArticles = _allArticles.where((article) =>
            _bookmarkedArticles.contains(article.id)).toList();
        return savedArticles;
      case 3:
        final highlightedArticles = _allArticles.where((article) =>
            _highlightedArticles.contains(article.id)).toList();
        return highlightedArticles;
      default:
        return _filteredArticles.isNotEmpty ? _filteredArticles : _allArticles;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationController.dispose();
    _tabController.dispose();
    _searchTextController.dispose();
    _scrollController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildStructureDrawer(),
      body: SafeArea(
        child: _isLoading ? _buildLoadingView() :
               _errorMessage != null ? _buildErrorView() : _buildMainView(),
      ),
    );
  }

  Widget _buildStructureDrawer() {
    if (_codeStructure == null) return const SizedBox();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.codeTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Structura completă',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._codeStructure!.books.map((book) => _buildBookItem(book)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(code_service.Book book) {
    return ExpansionTile(
      title: Text(
        book.title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: book.titles.map((title) => _buildTitleItem(title)).toList(),
    );
  }

  Widget _buildTitleItem(code_service.CodeTitle title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        title: Text(
          title.title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: title.chapters.map((chapter) => _buildChapterItem(chapter)).toList(),
      ),
    );
  }

  Widget _buildChapterItem(code_service.Chapter chapter) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        title: Text(
          chapter.title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          ...chapter.sections.map((section) => _buildSectionItem(section)),
        ],
      ),
    );
  }

  Widget _buildSectionItem(code_service.CodeSection section) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          ...section.articles.map((article) => _buildArticleLink(article)),
          ...section.subsections.map((subsection) => _buildSubsectionItem(subsection)),
        ],
      ),
    );
  }

  Widget _buildSubsectionItem(code_service.CodeSection subsection) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        title: Text(
          subsection.title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: subsection.articles.map((article) => _buildArticleLink(article)).toList(),
      ),
    );
  }

  Widget _buildArticleLink(code_service.Article article) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32),
      dense: true,
      title: Text(
        'Art. ${article.number}',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        final index = _allArticles.indexWhere((a) => a.id == article.id);
        if (index != -1) {
          _scrollController.animateTo(
            index * 200.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Încărcare ${widget.codeTitle}...',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Procesarea structurii codului juridic',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Column(
        children: [
          _buildAppBar(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: _isSearchVisible ? null : 0,
            child: _isSearchVisible ? _buildSearchBar() : const SizedBox.shrink(),
          ),
          _buildTabBar(),
          Expanded(
            child: _buildArticlesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.codeTitle,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_allArticles.isNotEmpty)
                      Text(
                        '${_allArticles.length} articole',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _isSearchVisible ? 0.125 : 0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isSearchVisible ? Icons.close : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: _toggleSearch,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_searchSlideAnimation),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _searchTextController,
            style: GoogleFonts.inter(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Căutați în ${widget.codeTitle}...',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              suffixIcon: _searchTextController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade400),
                      onPressed: () {
                        _searchTextController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        tabs: _tabTitles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final count = _getTabCount(index);

          return Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: _currentTabIndex == index
                          ? Colors.blue.shade500
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        labelColor: Colors.blue.shade600,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.blue.shade600,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  int _getTabCount(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _filteredArticles.length;
      case 1:
        return _readingPlan.length;
      case 2:
        return _bookmarkedArticles.length;
      case 3:
        return _highlightedArticles.length;
      default:
        return 0;
    }
  }

  Widget _buildArticlesList() {
    final articles = _getTabArticles();

    if (articles.isEmpty) {
      return _buildEnhancedEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: _buildModernArticleCard(article, index),
        );
      },
    );
  }

  Widget _buildModernArticleCard(code_service.Article article, int index) {
    final isBookmarked = _bookmarkedArticles.contains(article.id);
    final isHighlighted = _highlightedArticles.contains(article.id);
    final isInReadingPlan = _readingPlan.contains(article.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isHighlighted ? Colors.amber.shade200 : Colors.grey.shade100,
            width: isHighlighted ? 2 : 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: article.isImportant
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: article.isImportant
                          ? Colors.red.shade300
                          : Colors.blue.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Art. ${article.number}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: article.isImportant
                          ? Colors.red.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    article.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildHighlightedText(
              article.content,
              _currentSearchQuery,
              GoogleFonts.inter(
                fontSize: _fontSize,
                height: _lineHeight,
                color: Colors.grey.shade800,
              ),
            ),

            if (article.notes.isNotEmpty || article.references.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildReferencesSection(article),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                _buildActionButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amber.shade600 : Colors.grey.shade500,
                  onTap: () => _toggleBookmark(article.id),
                ),
                _buildActionButton(
                  icon: isHighlighted ? Icons.highlight : Icons.highlight_outlined,
                  color: isHighlighted ? Colors.amber.shade600 : Colors.grey.shade500,
                  onTap: () => _toggleHighlight(article.id),
                ),
                _buildActionButton(
                  icon: isInReadingPlan ? Icons.list_alt : Icons.list_alt_outlined,
                  color: isInReadingPlan ? Colors.green.shade600 : Colors.grey.shade500,
                  onTap: () => _toggleReadingPlan(article.id),
                ),
                const Spacer(),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  color: Colors.grey.shade500,
                  onTap: () => _shareArticle(article),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferencesSection(code_service.Article article) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.notes.isNotEmpty) ...[
            Text(
              'Note:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            ...article.notes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                note,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            )),
          ],
          if (article.references.isNotEmpty) ...[
            if (article.notes.isNotEmpty) const SizedBox(height: 8),
            Text(
              'Referințe:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            ...article.references.map((ref) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $ref',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty || query.length < 2) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final queryWords = query.split(' ').where((w) => w.length > 1).toList();

    List<TextSpan> spans = [];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, currentIndex);

      if (matchIndex == -1) {
        spans.add(TextSpan(
          text: text.substring(currentIndex),
          style: style,
        ));
        break;
      }

      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: style,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: style.copyWith(
          backgroundColor: Colors.yellow.shade200,
          fontWeight: FontWeight.w700,
        ),
      ));

      currentIndex = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Niciun articol găsit',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Niciun articol găsit',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(String articleId) {
    setState(() {
      if (_bookmarkedArticles.contains(articleId)) {
        _bookmarkedArticles.remove(articleId);
      } else {
        _bookmarkedArticles.add(articleId);
      }
    });
    _savePreferences();
  }

  void _toggleHighlight(String articleId) {
    setState(() {
      if (_highlightedArticles.contains(articleId)) {
        _highlightedArticles.remove(articleId);
      } else {
        _highlightedArticles.add(articleId);
      }
    });
    _savePreferences();
  }

  void _toggleReadingPlan(String articleId) {
    setState(() {
      if (_readingPlan.contains(articleId)) {
        _readingPlan.remove(articleId);
      } else {
        _readingPlan.add(articleId);
      }
    });
    _savePreferences();
  }

  void _shareArticle(code_service.Article article) {
    debugPrint('Share: ${article.number} - ${article.title}');
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fontSize = prefs.getDouble('fontSize') ?? 16.0;
        _lineHeight = prefs.getDouble('lineHeight') ?? 1.5;

        final bookmarksString = prefs.getString('bookmarkedArticles') ?? '[]';
        final List<dynamic> bookmarksList = jsonDecode(bookmarksString);
        _bookmarkedArticles = Set<String>.from(bookmarksList);

        final highlightedString = prefs.getString('highlightedArticles') ?? '[]';
        final List<dynamic> highlightedList = jsonDecode(highlightedString);
        _highlightedArticles = Set<String>.from(highlightedList);

        _readingPlan = prefs.getStringList('readingPlan') ?? [];
      });
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setDouble('lineHeight', _lineHeight);
      await prefs.setString('bookmarkedArticles', jsonEncode(_bookmarkedArticles.toList()));
      await prefs.setString('highlightedArticles', jsonEncode(_highlightedArticles.toList()));
      await prefs.setStringList('readingPlan', _readingPlan);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Eroare la încărcare',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'A apărut o eroare neașteptată.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.purple.shade500],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadCodeStructure,
                  borderRadius: BorderRadius.circular(25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Reîncercare',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}