// lib/pages/travel_buddy_page.dart
import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/url_service.dart';
import 'data/travel_playbook.dart';
import 'services/api_service.dart';
import 'services/travel_buddy.dart';

class TravelBuddyPage extends StatefulWidget {
  const TravelBuddyPage({super.key});
  @override
  State<TravelBuddyPage> createState() => _TravelBuddyPageState();
}

class _TravelBuddyPageState extends State<TravelBuddyPage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _msgs = <_Msg>[
    _Msg(
      text:
          "Hi there! 👋 I'm KL Buddy, your friendly travel guide! Ask me about KL's amazing food, exciting sights, or help you plan your perfect day!",
      fromBot: true,
      quickReplies: ['Top attractions', 'Best food', 'Getting around'],
    ),
  ];

  // Cached Q&A list: dynamic-generator entries plus static entries fetched
  // from the backend. Falls back to just the dynamic entries if the fetch
  // fails, so the bot still partially works offline.
  Future<List<QA>>? _qaFuture;

  // True while waiting on a reply (AI call or fallback) — drives the typing
  // indicator bubble and blocks sending a second message on top of it.
  bool _isTyping = false;

  HomePalette get _palette =>
      HomePalette.of(context);

  @override
  void initState() {
    super.initState();
    _qaFuture = _loadQAList();
  }

  Future<List<QA>> _loadQAList() async {
    try {
      final rows = await fetchRawList('appTravelBuddyQA');
      return buildQAList(rows);
    } catch (_) {
      return kDynamicQA;
    }
  }

  void _send(String text) {
    if (text.trim().isEmpty || _isTyping) return;

    // Snapshot prior turns as conversation history before adding this message.
    final history = _msgs
        .map((m) => {'role': m.fromBot ? 'bot' : 'user', 'text': m.text})
        .toList();

    setState(() {
      _msgs.add(_Msg(text: text, fromBot: false));
      _isTyping = true;
    });
    _ctrl.clear();

    // Scroll to bottom after user message (and again once the typing
    // indicator bubble is laid out).
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    _fetchReply(text, history);
  }

  Future<void> _fetchReply(
    String text,
    List<Map<String, String>> history,
  ) async {
    // Keep the typing indicator visible for a minimum stretch so it doesn't
    // flash instantly when the local fallback answers immediately.
    final results = await Future.wait([
      _resolveReply(text, history),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    final (reply, quickReplies) = results[0] as (String, List<String>);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _msgs.add(_Msg(text: reply, fromBot: true, quickReplies: quickReplies));
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<(String, List<String>)> _resolveReply(
    String text,
    List<Map<String, String>> history,
  ) async {
    try {
      final result = await fetchTravelBuddyAI(text, history);
      final reply = (result['answer'] ?? '').toString();
      final quickReplies =
          List<String>.from(result['quickReplies'] as List? ?? const []);
      if (reply.isEmpty) throw Exception('empty AI answer');
      return (reply, quickReplies);
    } catch (_) {
      // AI call failed (offline, quota, etc.) — fall back to the local
      // keyword-matching engine so the bot still responds.
      final qaList = await (_qaFuture ??= _loadQAList());
      final reply = respondTo(text, qaList, isNight: _isNightNow());
      final quickReplies = getQuickReplies(text, qaList);
      return (reply, quickReplies);
    }
  }

  void _handleQuickReply(String text) {
    // Check if it's a link button
    if (text.contains('🔗')) {
      // Extract the link text and open URL
      if (text.contains('KL The Guide')) {
        UrlService.launchURL('https://www.kltheguide.com.my/');
      }
    } else {
      // Send as normal message
      _send(text);
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool _isNightNow() {
    final h = DateTime.now().hour;
    return h >= 19 || h <= 5;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: palette.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Mascot Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/KLbuddy.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      color: palette.accent,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KL Buddy",
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  "Always here to help! 😊",
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: palette.background,
        child: Column(
          children: [
            // Messages area
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _msgs.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _msgs.length) {
                    return _buildTypingBubble();
                  }
                  final m = _msgs[i];
                  return Column(
                    children: [
                      _buildMessageBubble(m),
                      // Show quick reply buttons only for last bot message
                      if (m.fromBot &&
                          m.quickReplies.isNotEmpty &&
                          i == _msgs.length - 1)
                        _buildQuickReplies(m.quickReplies),
                    ],
                  );
                },
              ),
            ),

            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_Msg msg) {
    final palette = _palette;
    final align = msg.fromBot ? Alignment.centerLeft : Alignment.centerRight;

    return Align(
      alignment: align,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar (left side)
          if (msg.fromBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                color: palette.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/KLbuddy.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.smart_toy,
                      color: palette.accent,
                      size: 18,
                    );
                  },
                ),
              ),
            ),
          ],

          // Message bubble
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.fromBot ? palette.card : palette.accent,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: msg.fromBot
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                  bottomRight: msg.fromBot
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.fromBot ? palette.textPrimary : Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // User avatar (right side)
          if (!msg.fromBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    final palette = _palette;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: BoxDecoration(
              color: palette.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/KLbuddy.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.smart_toy,
                    color: palette.accent,
                    size: 18,
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _TypingDots(color: palette.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(List<String> replies) {
    final palette = _palette;

    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 8, bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.map((text) {
          final isLink = text.contains('🔗');

          return InkWell(
            onTap: () => _handleQuickReply(text),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLink ? Colors.blue[50] : palette.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLink ? Colors.blue[300]! : palette.accent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLink)
                    const Icon(
                      Icons.link,
                      size: 16,
                      color: Colors.blue,
                    ),
                  if (isLink) const SizedBox(width: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: isLink ? Colors.blue[700] : palette.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    final palette = _palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: palette.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: palette.textSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: _isTyping ? null : _send,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Ask about food, places, or activities...",
                    hintStyle: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white.withValues(alpha: _isTyping ? 0.5 : 1),
                ),
                onPressed: _isTyping ? null : () => _send(_ctrl.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Three-dot "bot is typing" indicator, bouncing in sequence.
class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.2) % 1.0;
            final scale = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Msg {
  final String text;
  final bool fromBot;
  final List<String> quickReplies;

  _Msg({
    required this.text,
    required this.fromBot,
    this.quickReplies = const [],
  });
}
