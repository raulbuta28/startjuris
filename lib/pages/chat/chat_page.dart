import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:startjuris/pages/chat/chat2.dart';
import 'package:startjuris/pages/acasa/laindemana.dart';
import 'package:startjuris/pages/backend/social/users_search_page.dart';
import 'package:startjuris/pages/backend/providers/chat_provider.dart';
import 'package:startjuris/pages/backend/models/chat_models.dart';
import 'package:startjuris/pages/backend/models/user_model.dart';
import 'package:startjuris/pages/backend/providers/auth_provider.dart';
import 'package:startjuris/pages/backend/auth/login_page.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatPage extends StatefulWidget {
  final bool showGroups;

  const ChatPage({super.key, this.showGroups = false});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> userCreatedGroups = [];
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.loadConversations();
  }

  Future<void> _onRefresh() async {
    await _loadConversations();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _showFullScreenMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return const FullScreenMenu();
      },
    );
  }

  void _createNewGroup() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creează un grup nou'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nume grup'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  userCreatedGroups.add({
                    'name': name,
                    'message': 'Bine ați venit în grupul $name!',
                    'time': 'Acum',
                    'unreadCount': 0,
                    'avatar': '',
                    'groupText': name.length > 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase(),
                    'gradient': const LinearGradient(
                      colors: [Color(0xFFB0BEC5), Color(0xFF78909C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    'members': ['Ion Popescu'],
                    'hasCheckmark': false,
                    'isImageAvatar': false,
                    'nameFontSize': 16.0,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Creează'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    final chats = widget.showGroups ? [...fixedGroups, ...userCreatedGroups] : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showGroups
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(showGroups: false),
                  ),
                ),
              )
            : null,
        title: Text(
          widget.showGroups ? 'Comunități' : 'Conversații',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          if (!widget.showGroups) ...[
            IconButton(
              icon: const Icon(
                Icons.person_add_rounded,
                color: Colors.black87,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsersSearchPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.black87,
                size: 24,
              ),
              onPressed: () => _showFullScreenMenu(context),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (!widget.showGroups) 
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: const LaIndemanaCarousel(),
            ),
          Expanded(
            child: widget.showGroups
                ? ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ChatTile(
                        name: chat['name']!,
                        message: chat['message']!,
                        time: chat['time']!,
                        unreadCount: chat['unreadCount']!,
                        avatar: chat['avatar'],
                        index: index,
                        isGroup: true,
                        groupText: chat['groupText'],
                        groupGradient: chat['gradient'],
                        hasCheckmark: chat['hasCheckmark'],
                        isImageAvatar: chat['isImageAvatar'] ?? false,
                        nameFontSize: chat['nameFontSize'] ?? 16.0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat2Page(
                                contactName: chat['name']!,
                                contactAvatar: chat['avatar'],
                                isGroup: true,
                                groupText: chat['groupText'],
                                groupGradient: chat['gradient'],
                                isImageAvatar: chat['isImageAvatar'] ?? false,
                                hasCheckmark: chat['hasCheckmark'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      if (chatProvider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue[600],
                            strokeWidth: 3,
                          ),
                        );
                      }

                      if (chatProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Colors.red[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'A apărut o eroare',
                                style: GoogleFonts.inter(
                                  color: Colors.red[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                chatProvider.error!,
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextButton.icon(
                                onPressed: _loadConversations,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Încearcă din nou'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue[600],
                                  textStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (chatProvider.conversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nicio conversație',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Începe o conversație cu cineva',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        header: WaterDropHeader(
                          waterDropColor: Colors.blue[600]!,
                          complete: Icon(
                            Icons.check,
                            color: Colors.blue[600],
                          ),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: chatProvider.conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = chatProvider.conversations[index];
                            return _buildConversationTile(conversation);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) return const SizedBox.shrink();

    final chatProvider = context.read<ChatProvider>();
    final otherParticipantName = chatProvider.getOtherParticipantName(conversation, currentUser.id);
    final otherParticipantAvatar = chatProvider.getOtherParticipantAvatar(conversation, currentUser.id);
    final lastMessage = conversation.messages?.isNotEmpty == true ? conversation.messages!.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat2Page(
                contactName: otherParticipantName,
                contactAvatar: otherParticipantAvatar ?? '',
                recipientId: conversation.participants.firstWhere((id) => id != currentUser.id),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: otherParticipantAvatar != null
                      ? Image.network(
                          otherParticipantAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          otherParticipantName,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            _formatTimestamp(lastMessage.timestamp),
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage?.text ?? 'Niciun mesaj',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: conversation.unreadCount != null && conversation.unreadCount! > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount != null && conversation.unreadCount! > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(timestamp);
    } else {
      return DateFormat('dd MMM').format(timestamp);
    }
  }
}

class FullScreenMenu extends StatelessWidget {
  const FullScreenMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.black87, size: 24),
              title: Text(
                'Confidențialitate',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Confidențialitate pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 24),
              title: Text(
                'Notificări',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Notificări pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.black87, size: 24),
              title: Text(
                'Stocare și date',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Stocare și date pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt, color: Colors.black87, size: 24),
              title: Text(
                'Invită un prieten',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Invită un prieten pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.black87, size: 24),
              title: Text(
                'Ajutor',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Ajutor pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined, color: Colors.black87, size: 24),
              title: Text(
                'Dark mode',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Dark mode pressed');
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 24),
              title: Text(
                'Deconectare',
                style: TextStyle(
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmare'),
                    content: const Text('Sigur doriți să vă deconectați?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Anulează'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Deconectare',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  // Close menu
                  Navigator.pop(context);
                  
                  try {
                    // Cleanup ChatProvider first
                    final chatProvider = context.read<ChatProvider>();
                    await chatProvider.cleanup();
                    
                    // Then logout user
                    await context.read<AuthProvider>().logout();
                    
                    // Navigate to login page and remove all previous routes
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Eroare la deconectare: $e',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: Colors.red[400],
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final String avatar;
  final int index;
  final bool isGroup;
  final String? groupText;
  final LinearGradient? groupGradient;
  final bool hasCheckmark;
  final bool isImageAvatar;
  final double nameFontSize;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.avatar,
    required this.index,
    required this.onTap,
    this.isGroup = false,
    this.groupText,
    this.groupGradient,
    this.hasCheckmark = false,
    this.isImageAvatar = false,
    this.nameFontSize = 16.0,
  });

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dismissible(
        key: Key(widget.name),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Șterge conversația',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                content: Text(
                  'Ești sigur că vrei să ștergi această conversație?',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Anulează',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Șterge',
                      style: GoogleFonts.inter(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Colors.red[600],
            size: 24,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isGroup
                        ? widget.isImageAvatar
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  widget.avatar,
                                  fit: BoxFit.cover,
                                  width: 48,
                                  height: 48,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: widget.groupGradient,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.groupText ?? '',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              widget.avatar,
                              fit: BoxFit.cover,
                              width: 48,
                              height: 48,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black87,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isGroup && widget.hasCheckmark) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue[600],
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[600],
                            letterSpacing: -0.2,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.time,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: widget.unreadCount > 0 ? Colors.blue[600] : Colors.grey[500],
                          fontWeight: widget.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (widget.unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.unreadCount.toString(),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy data for chat list
final List<Map<String, dynamic>> dummyChats = [
  {
    'name': 'Ion Popescu',
    'message': 'Bună, ce mai faci?',
    'time': '10:30',
    'unreadCount': 2,
    'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
  },
  {
    'name': 'Maria Ionescu',
    'message': 'Ne întâlnim mâine?',
    'time': '09:15',
    'unreadCount': 0,
    'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
  },
  {
    'name': 'Alexandru Matei',
    'message': 'Vezi acest link!',
    'time': 'Ieri',
    'unreadCount': 1,
    'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
  },
  {
    'name': 'Elena Dumitrescu',
    'message': 'Mulțumesc pentru ajutor!',
    'time': 'Ieri',
    'unreadCount': 0,
    'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
  },
];

// Fixed group chats data with image avatars and checkmarks
final List<Map<String, dynamic>> fixedGroups = [
  {
    'name': 'Admitere INM',
    'message': 'Discutăm despre examenul de săptămâna viitoare!',
    'time': '12:45',
    'unreadCount': 3,
    'avatar': 'assets/icon/2.png',
    'groupText': 'INM',
    'gradient': null,
    'members': ['Ion Popescu', 'Maria Ionescu', 'Alexandru Matei'],
    'hasCheckmark': true,
    'isImageAvatar': true,
    'nameFontSize': 16.0,
  },
  {
    'name': 'Admitere Barou',
    'message': 'Cine are notițele de la cursul de drept civil?',
    'time': '11:20',
    'unreadCount': 1,
    'avatar': 'assets/icon/3.png',
    'groupText': 'BAROU',
    'gradient': null,
    'members': ['Elena Dumitrescu', 'Maria Ionescu'],
    'hasCheckmark': true,
    'isImageAvatar': true,
    'nameFontSize': 16.0,
  },
  {
    'name': 'Admitere INR',
    'message': 'S-a publicat calendarul examenelor!',
    'time': '10:00',
    'unreadCount': 0,
    'avatar': 'assets/icon/4.png',
    'groupText': 'INR',
    'gradient': null,
    'members': ['Ion Popescu', 'Alexandru Matei'],
    'hasCheckmark': true,
    'isImageAvatar': true,
    'nameFontSize': 16.0,
  },
  {
    'name': 'Admitere directă INM',
    'message': 'Cine participă la sesiunea din mai?',
    'time': '09:30',
    'unreadCount': 2,
    'avatar': 'assets/icon/5.png',
    'groupText': 'DIRECT',
    'gradient': null,
    'members': ['Maria Ionescu', 'Elena Dumitrescu'],
    'hasCheckmark': true,
    'isImageAvatar': true,
    'nameFontSize': 16.0,
  },
  {
    'name': 'Student la drept',
    'message': 'Întrebări despre cursul de drept civil?',
    'time': '08:15',
    'unreadCount': 1,
    'avatar': 'assets/icon/6.png',
    'groupText': 'DREPT',
    'gradient': null,
    'members': ['Ion Popescu', 'Alexandru Matei'],
    'hasCheckmark': true,
    'isImageAvatar': true,
    'nameFontSize': 16.0,
  },
  {
    'name': 'startJuris',
    'message': 'Bun venit în comunitatea startJuris!',
    'time': 'Ieri',
    'unreadCount': 0,
    'avatar': 'assets/icon/icon.png',
    'groupText': 'sJ',
    'gradient': null,
    'members': ['Maria Ionescu', 'Elena Dumitrescu'],
    'hasCheckmark': true,
    'isImageAvatar': true,
    'nameFontSize': 16.0,
  },
];