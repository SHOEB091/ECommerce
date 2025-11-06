// lib/screens/chat_screen.dart
import 'package:ecommerce/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, String>> _messages = []; // newest at index 0
  final ScrollController _scroll = ScrollController();
  bool _loading = false;
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';
    _chat_service_init(apiKey, model);
    // optional welcome message
    _messages.insert(0, {'role': 'bot', 'text': 'Hi — I am your assistant. Ask me anything.', 'time': DateTime.now().toIso8601String()});
  }

  void _chat_service_init(String apiKey, String model) {
    _chat_service_create(apiKey, model);
  }

  void _chat_service_create(String apiKey, String model) {
    _chatService = ChatService(apiKey: apiKey, model: model);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    setState(() {
      _messages.insert(0, {'role': 'user', 'text': text, 'time': now.toIso8601String()});
      _loading = true;
      _ctrl.clear();
    });

    _scrollToTop();

    try {
      final reply = await _chatService.sendPrompt(text);
      final replyTime = DateTime.now();
      setState(() {
        _messages.insert(0, {'role': 'bot', 'text': reply, 'time': replyTime.toIso8601String()});
      });
      _scrollToTop();
    } catch (e) {
      setState(() {
        _messages.insert(0, {'role': 'bot', 'text': 'Error: ${e.toString()}', 'time': DateTime.now().toIso8601String()});
      });
      _scrollToTop();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _scrollToTop() {
    // Because ListView is reversed, top = newest
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return '';
    }
  }

  Widget _buildMessage(Map<String, String> m) {
    final isUser = (m['role'] ?? '') == 'user';
    final text = m['text'] ?? '';
    final time = m['time'] != null ? _formatTime(m['time']!) : '';
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.smart_toy, size: 18, color: Colors.blueAccent),
              ),
            )
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                // copy text
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue.shade700 : Colors.grey.shade100,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      text,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87, height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser) Icon(Icons.check_circle, size: 12, color: Colors.green.shade400),
                        if (!isUser) const SizedBox(width: 6),
                        Text(time, style: TextStyle(fontSize: 10, color: isUser ? Colors.white70 : Colors.black45)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade700,
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
            )
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 18, backgroundColor: Colors.transparent, child: Icon(Icons.smart_toy, color: Colors.blueAccent)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Gemini Assistant', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 16)),
                // small subtitle can be added if needed
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Chatbot'),
                  content: const Text('This chat is powered by Gemini (for dev use only).'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: _messages.isEmpty
                    ? Center(child: Text('No messages yet — say hi!', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black45)))
                    : ListView.builder(
                        controller: _scroll,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final m = _messages[index];
                          return _buildMessage(m);
                        },
                      ),
              ),
            ),
            if (_loading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: const [
                    SizedBox(width: 8),
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Thinking...', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final isEmpty = _ctrl.text.trim().isEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      color: Colors.white,
      child: Row(
        children: [
          // optional attachment / mic icon
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attachment not implemented')));
            },
            icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendIfNotEmpty(),
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (!isEmpty)
                    GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        setState(() {});
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: isEmpty || _loading ? null : _send,
            mini: true,
            backgroundColor: isEmpty || _loading ? Colors.grey.shade400 : Colors.blue.shade700,
            child: Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _sendIfNotEmpty() {
    if (_ctrl.text.trim().isNotEmpty && !_loading) _send();
  }
}
