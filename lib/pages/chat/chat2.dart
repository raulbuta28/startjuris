import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../backend/models/chat_models.dart';
import '../backend/providers/auth_provider.dart';
import '../backend/providers/chat_provider.dart';
import '../backend/services/api_service.dart';
import '../services/url_utils.dart';

class Chat2Page extends StatefulWidget {
  final String contactName;
  final String contactAvatar;
  final bool isGroup;
  final String? groupText;
  final LinearGradient? groupGradient;
  final bool isImageAvatar;
  final bool hasCheckmark;
  final String? conversationId;
  final String? recipientId;

  const Chat2Page({
    Key? key,
    required this.contactName,
    required this.contactAvatar,
    this.isGroup = false,
    this.groupText,
    this.groupGradient,
    this.isImageAvatar = false,
    this.hasCheckmark = false,
    this.conversationId,
    this.recipientId,
  }) : super(key: key);

  @override
  _Chat2PageState createState() => _Chat2PageState();
}

class _Chat2PageState extends State<Chat2Page> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isAttachmentMenuOpen = false;
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ro_RO');
    _currentConversationId = widget.conversationId;
    
    // Încarcă datele inițiale după ce widget-ul este construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    // Subscribe to new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.messageStream.listen((message) {
        // Actualizăm _currentConversationId dacă este un mesaj pentru o conversație nouă
        if (_currentConversationId == null && mounted) {
          setState(() {
            _currentConversationId = message.conversationId;
          });
        }

        // Scroll la început doar dacă suntem aproape de început
        if (_scrollController.hasClients && _scrollController.offset <= 100) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    try {
      // Dacă avem deja un ID de conversație, încărcăm direct mesajele
      if (widget.conversationId != null) {
        _currentConversationId = widget.conversationId;
        if (mounted) {
          await chatProvider.loadMessages(widget.conversationId!);
        }
        return;
      }

      // Dacă avem un recipient ID, căutăm sau creăm conversația
      if (widget.recipientId != null) {
        // Încărcăm mai întâi conversațiile dacă nu sunt încărcate
        if (chatProvider.conversations.isEmpty) {
          await chatProvider.loadConversations();
        }
        
        // Căutăm conversația existentă cu acest recipient
        final existingConversation = chatProvider.conversations.firstWhere(
          (conv) => conv.participants.contains(widget.recipientId),
          orElse: () => Conversation(
            id: '',
            participants: [],
            messages: [],
            lastActivity: DateTime.now(),
          ),
        );
        
        if (existingConversation.id.isNotEmpty) {
          // Am găsit o conversație existentă
          setState(() {
            _currentConversationId = existingConversation.id;
          });
          
          if (mounted) {
            await chatProvider.loadMessages(existingConversation.id);
          }
        }
      }
      
      // Încărcăm detaliile recipientului dacă sunt disponibile
      if (widget.recipientId != null && mounted) {
        await Provider.of<AuthProvider>(context, listen: false)
            .loadUserDetails(widget.recipientId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea conversației: $e'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final recipientDetails = widget.recipientId != null ? 
                authProvider.getUserDetails(widget.recipientId!) : null;
            
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (recipientDetails?.avatarUrl != null) {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  resolveUrl(recipientDetails!.avatarUrl!),
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.width * 0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Închide',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
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
                    child: widget.isGroup
                        ? _buildGroupAvatar()
                        : _buildUserAvatar(resolveUrl(recipientDetails?.avatarUrl ?? widget.contactAvatar)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipientDetails?.username ?? widget.contactName,
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, _) {
                          final isOnline = chatProvider.isUserOnline(widget.recipientId ?? '');
                          return Text(
                            isOnline ? 'Online' : 'Offline',
                            style: GoogleFonts.inter(
                              color: isOnline ? Colors.green[600] : Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Show chat options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // Încarcă mesajele pentru conversația curentă
                final messages = _currentConversationId != null ? 
                    chatProvider.getMessagesForConversation(_currentConversationId!) : [];
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Niciun mesaj încă',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final localTimestamp = message.timestamp.toLocal();
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == context.read<AuthProvider>().user?.id,
                      showAvatar: true,
                      timestamp: chatProvider.formatMessageTimestamp(localTimestamp),
                      showTimestamp: false,
                      isLastInGroup: index == messages.length - 1,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
          _buildAttachmentMenu(),
        ],
      ),
    );
  }

  Widget _buildGroupAvatar() {
    return widget.isImageAvatar
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.contactAvatar,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.groupGradient,
            ),
            child: Center(
              child: Text(
                widget.groupText ?? '',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
  }

  Widget _buildUserAvatar(String avatarUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _isAttachmentMenuOpen ? 0.125 : 0,
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: _isAttachmentMenuOpen ? Colors.blue[600] : Colors.grey[600],
                size: 28,
              ),
            ),
            onPressed: () {
              setState(() {
                _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
                if (_isAttachmentMenuOpen) {
                  _focusNode.unfocus();
                }
              });
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Scrie un mesaj...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    onPressed: () {
                      // Show emoji picker
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded),
              color: Colors.white,
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    if (!_isAttachmentMenuOpen) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachmentOption(
                icon: Icons.image_rounded,
                label: 'Imagine',
                color: Colors.green[600]!,
                onTap: () {
                  // Handle image attachment
                },
              ),
              _buildAttachmentOption(
                icon: Icons.camera_alt_rounded,
                label: 'Cameră',
                color: Colors.blue[600]!,
                onTap: () {
                  // Handle camera
                },
              ),
              _buildAttachmentOption(
                icon: Icons.file_present_rounded,
                label: 'Document',
                color: Colors.orange[600]!,
                onTap: () {
                  // Handle document
                },
              ),
              _buildAttachmentOption(
                icon: Icons.location_on_rounded,
                label: 'Locație',
                color: Colors.red[600]!,
                onTap: () {
                  // Handle location
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[800],
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAttachmentMenuOpen = false;
    });

    _messageController.clear();
    _focusNode.requestFocus();

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      // Trimite mesajul și așteaptă răspunsul
      final result = await chatProvider.sendMessage(
        widget.recipientId!,
        text,
      );

      final conversation = Conversation.fromJson(result['conversation']);

      // Actualizează ID-ul conversației dacă este necesar
      if (_currentConversationId == null) {
        setState(() {
          _currentConversationId = conversation.id;
        });
      }

      // Încarcă mesajele pentru conversație
      if (mounted) {
        await chatProvider.loadMessages(_currentConversationId!);
      }

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Eroare la trimiterea mesajului: $e',
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;
  final String timestamp;
  final bool showTimestamp;
  final bool isLastInGroup;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    required this.timestamp,
    this.showTimestamp = true,
    this.isLastInGroup = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 16,
        right: isMe ? 16 : 64,
        bottom: isLastInGroup ? 16 : 4,
        top: 2,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isMe ? LinearGradient(
                colors: [
                  Colors.blue[400]!,
                  Colors.blue[600]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              color: isMe ? null : Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 8),
                bottomRight: Radius.circular(isMe ? 8 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          if (showTimestamp && isLastInGroup)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timestamp,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead ? Colors.blue[400] : Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

//–––––––––––––––––––––––––––––––––––––– APP BAR –––––––––––––––––––––––––––––––––––
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String contactName;
  final String contactAvatar;
  final bool isGroup;
  final String? groupText;
  final LinearGradient? groupGradient;
  final List<String> members;
  final bool isImageAvatar;
  final bool hasCheckmark;

  const ChatAppBar({
    super.key,
    required this.contactName,
    required this.contactAvatar,
    required this.isGroup,
    this.groupText,
    this.groupGradient,
    required this.members,
    required this.isImageAvatar,
    required this.hasCheckmark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.maybePop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: isGroup
                ? isImageAvatar
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          contactAvatar,
                          fit: BoxFit.cover,
                          width: 36,
                          height: 36,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 18, color: Colors.grey),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: groupGradient,
                        ),
                        child: Center(
                          child: Text(
                            groupText!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                          ),
                        ),
                      )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      contactAvatar,
                      fit: BoxFit.cover,
                      width: 36,
                      height: 36,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 18, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contactName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isGroup && hasCheckmark) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                if (isGroup)
                  Text(
                    '${members.length} membri',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }
}

//––––––––––––––––––––––––––––– INFINITY ICON/SPINNER –––––––––––––––––––––––
class InfinityIcon extends StatelessWidget {
  final double size;
  const InfinityIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _InfinityPainter(0),
    );
  }
}

class InfinitySpinner extends StatefulWidget {
  final double size;
  const InfinitySpinner({super.key, required this.size});

  @override
  State<InfinitySpinner> createState() => _InfinitySpinnerState();
}

class _InfinitySpinnerState extends State<InfinitySpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size.square(widget.size),
        painter: _InfinityPainter(_ctrl.value),
      ),
    );
  }
}

class _InfinityPainter extends CustomPainter {
  final double t;
  const _InfinityPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final baseRx = size.width * 0.3;
    final baseRy = size.height * 0.4;
    final rx = baseRx * (1 + 0.1 * sin(2 * pi * t));
    final ry = baseRy * (1 + 0.1 * cos(2 * pi * t));

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final paintGold = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, 200, 70))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final paintPink = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    Path _loop(double start, double end) {
      final path = Path();
      const steps = 60;
      for (var i = 0; i <= steps; i++) {
        final theta = start + (end - start) * i / steps;
        final x = cx + rx * sin(theta);
        final y = cy + ry * sin(2 * theta) * 0.5;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    final rightLoop = _loop(0, pi);
    final leftLoop = _loop(pi, 2 * pi);

    canvas.drawPath(rightLoop, shadow);
    canvas.drawPath(leftLoop, shadow);

    canvas.drawPath(leftLoop, paintPink);
    canvas.drawPath(rightLoop, paintGold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//–––––––––––––––––––––––––––––– MESSAGE BUBBLE ––––––––––––––––––––––––––––––
class AnimatedMessageBubble extends StatefulWidget {
  final String text;
  final bool isSent;
  final DateTime timestamp;
  final int index;

  const AnimatedMessageBubble({
    super.key,
    required this.text,
    required this.isSent,
    required this.timestamp,
    required this.index,
  });

  @override
  State<AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<AnimatedMessageBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 50),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Align(
        alignment: widget.isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isSent
                  ? [const Color(0xFFE6FFDA), const Color(0xFFDFFFD6)]
                  : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: widget.isSent ? const Radius.circular(16) : const Radius.circular(0),
              bottomRight: widget.isSent ? const Radius.circular(0) : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: widget.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(widget.timestamp),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//––––––––––––––––––––––––––– MESSAGE INPUT FIELD ––––––––––––––––-––––––––––––
class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<bool> onTyping;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTyping,
  });

  @override
  Widget build( context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Scrie mesaj...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    letterSpacing: -0.4,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.4,
                ),
                onChanged: (value) => onTyping(value.isNotEmpty),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: Color(0xFF25D366)),
            ),
          ],
        ),
      ),
    );
  }
}

//–––––––––––––––––––––––––––––– TYPING –––––––––––––––––––––––––––
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build( context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(index: i)),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int index;
  const _Dot({required this.index});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800 + widget.index * 50),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build( context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}