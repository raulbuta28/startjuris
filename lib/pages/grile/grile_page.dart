import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:startjuris/pages/grile/burgermenu/burgermenu.dart';
import 'meciuri.dart';
import 'level.dart';
import 'admitereinm.dart';
import 'admiterebarou.dart';
import 'admitereinr.dart';

class GrilePage extends StatefulWidget {
  final int initialTabIndex;
  final int inmTabIndex;
  const GrilePage({super.key, this.initialTabIndex = 0, this.inmTabIndex = 0});

  @override
  _GrilePageState createState() => _GrilePageState();
}

class _GrilePageState extends State<GrilePage> with TickerProviderStateMixin {
  TabController? _tabController;
  List<int> _selectedTabs = [0, 1, 2];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedTabs();
  }

  void _initController() {
    int desiredPos = _selectedTabs.indexOf(widget.initialTabIndex);
    if (desiredPos == -1) desiredPos = 0;

    _tabController = TabController(
      initialIndex: desiredPos,
      length: _selectedTabs.length,
      vsync: this,
    );
    _tabController!.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedTabs() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getStringList('selectedTabs')?.map(int.parse).toList();
    var valid = (loaded != null && loaded.isNotEmpty) ? loaded : [0, 1, 2];
    if (!valid.contains(widget.initialTabIndex)) valid.insert(0, widget.initialTabIndex);
    setState(() {
      _selectedTabs = valid;
      _initController();
      _isLoading = false;
    });
  }

  Future<void> _saveSelectedTabs(List<int> tabs) async {
    var valid = tabs.where((i) => [0, 1, 2].contains(i)).toList();
    valid = valid.isNotEmpty ? valid : [0, 1, 2];
    if (!valid.contains(widget.initialTabIndex)) valid.insert(0, widget.initialTabIndex);
    if (!listEquals(valid, _selectedTabs)) {
      setState(() {
        _selectedTabs = valid;
        _tabController?.dispose();
        _initController();
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'selectedTabs',
        valid.map((i) => i.toString()).toList(),
      );
    }
  }

  void _showTabSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TabSelectionModal(
        selectedTabs: _selectedTabs,
        onSave: _saveSelectedTabs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );
    final count = _selectedTabs.length;
    final isSingle = count == 1;
    final fontSize = isSingle ? 16.0 : (count == 3 ? 12.0 : 14.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Flexible(
                child: MeciuriPage.buildFindAdversaryButton(context),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => LevelBadge.showLevelsGridModal(context),
                child: const LevelBadge(level: 1),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings, size: 24, color: Colors.grey),
                onPressed: _showTabSelectionModal,
              ),
              IconButton(
                icon: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Icon(Icons.menu, size: 24),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BurgerMenuPage()),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: isSingle
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _tabTitle(_selectedTabs.first),
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w500),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(width: 2.0, color: Colors.grey.shade300),
                        insets: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      tabs: _selectedTabs.map((i) => Tab(text: _tabTitle(i))).toList(),
                    ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _selectedTabs.map((i) {
                  switch (i) {
                    case 0:
                      return AdmitereINMPage(initialTabIndex: widget.inmTabIndex);
                    case 1:
                      return const AdmitereBarouPage();
                    case 2:
                      return const AdmitereINRPage();
                    default:
                      return const SizedBox();
                  }
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tabTitle(int i) {
    return i == 0 ? 'Admitere INM' : i == 1 ? 'Admitere Barou' : 'Admitere INR';
  }
}

class _TabSelectionModal extends StatefulWidget {
  final List<int> selectedTabs;
  final Future<void> Function(List<int>) onSave;
  const _TabSelectionModal({required this.selectedTabs, required this.onSave});

  @override
  __TabSelectionModalState createState() => __TabSelectionModalState();
}

class __TabSelectionModalState extends State<_TabSelectionModal> with SingleTickerProviderStateMixin {
  late List<int> _tempSelected;
  late AnimationController _aniCtrl;
  late Animation<double> _fadeAni;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedTabs);
    _aniCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAni = CurvedAnimation(parent: _aniCtrl, curve: Curves.easeInOut);
    _aniCtrl.forward();
  }

  @override
  void dispose() {
    _aniCtrl.dispose();
    super.dispose();
  }

  void _toggle(int index, bool? checked) {
    setState(() {
      if (checked == true && !_tempSelected.contains(index)) {
        _tempSelected.add(index);
      } else if (checked == false && _tempSelected.contains(index)) {
        _tempSelected.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAni,
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Alege o admitere',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.75,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Admitere INM',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
                activeColor: Colors.pink.shade200,
                controlAffinity: ListTileControlAffinity.leading,
                value: _tempSelected.contains(0),
                onChanged: (v) => _toggle(0, v),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Admitere Barou',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
                activeColor: Colors.pink.shade200,
                controlAffinity: ListTileControlAffinity.leading,
                value: _tempSelected.contains(1),
                onChanged: (v) => _toggle(1, v),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Admitere INR',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
                activeColor: Colors.pink.shade200,
                controlAffinity: ListTileControlAffinity.leading,
                value: _tempSelected.contains(2),
                onChanged: (v) => _toggle(2, v),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(
                        'Anulează',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_tempSelected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Confirmă',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}