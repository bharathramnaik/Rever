import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/data/models/learning_object_model.dart';
import 'package:rever/src/data/providers/concept_providers.dart';

/// AI Tutor modes — from Initial flow.txt §23
enum TutorMode {
  explain('Explain', Icons.psychology),
  simplify('Simplify', Icons.compress),
  goDeeper('Go deeper', Icons.layers),
  example('Give example', Icons.lightbulb),
  showVisually('Show visually', Icons.bubble_chart),
  compare('Compare', Icons.compare),
  challenge('Challenge this', Icons.gpp_maybe),
  quizMe('Quiz me', Icons.quiz),
  helpRemember('Help me remember', Icons.replay),
  apply('Apply this', Icons.build),
  analogy('Create analogy', Icons.compare_arrows),
  followUp('Ask follow-up', Icons.chat);

  final String label;
  final IconData icon;
  const TutorMode(this.label, this.icon);
}

/// Simple chat message model
class _ChatMessage {
  final String content;
  final bool isUser;
  final TutorMode? mode;
  final DateTime timestamp;

  _ChatMessage({
    required this.content,
    required this.isUser,
    this.mode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiTutorScreen extends ConsumerStatefulWidget {
  final String? conceptId;
  const AiTutorScreen({super.key, this.conceptId});

  @override
  ConsumerState<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends ConsumerState<AiTutorScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(_ChatMessage(
      content:
          'Hi! I\'m your AI Tutor. Ask me anything about what you\'re learning, '
          'or pick a mode below to guide our conversation.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text, {TutorMode? mode}) {
    if (text.trim().isEmpty && mode == null) return;

    final userMessage = mode != null
        ? '${mode.label}: ${text.isNotEmpty ? text : "Tell me more"}'
        : text;

    setState(() {
      _messages.add(_ChatMessage(content: userMessage, isUser: true, mode: mode));
      _isThinking = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Resolve concept RAG context (slug -> concept -> learning objects).
    final slug = widget.conceptId;
    if (slug == null || slug.isEmpty) {
      _replyWithoutContext(userMessage);
      return;
    }
    _replyWithContext(slug, userMessage);
  }

  Future<void> _replyWithContext(String slug, String userMessage) async {
    final buf = StringBuffer();
    try {
      final concept = await ref.read(conceptBySlugProvider(slug).future);
      if (concept != null) {
        buf.writeln('Concept: ${concept.title}');
        if (concept.summary?.isNotEmpty == true) {
          buf.writeln('Summary: ${concept.summary}');
        }
        final objects = await ref.read(learningObjectsProvider(concept.id).future);
        for (final obj in objects.take(6)) {
          final rendered = _objectText(obj);
          if (rendered.isNotEmpty) buf.writeln(rendered);
        }
      }
    } catch (e, st) {
      debugPrint('[tutor] RAG context fetch failed: $e\n$st');
    }
    _getReply(userMessage, context: buf.toString());
  }

  void _replyWithoutContext(String userMessage) {
    _getReply(userMessage, context: '');
  }

  void _getReply(String userMessage, {required String context}) {
    final llm = ref.read(llmServiceProvider);
    final system = LlmMessage(
      role: 'system',
      content: _systemPrompt(context),
    );
    // Tail the history to bound context window.
    final history = _buildHistoryTail();
    llm.complete([system, ...history, LlmMessage(role: 'user', content: userMessage)])
        .then((result) {
      if (!mounted) return;
      final reply = switch (result) {
        LlmOk(:final text) => text,
        LlmUnavailable(:final reason) =>
          'The AI tutor backend is not available right now ($reason). '
          'Try switching topics or checking your API key.',
      };
      // Ensure no emojis in the response per house style.
      final cleanReply = _stripEmojis(reply);
      setState(() {
        _messages.add(_ChatMessage(content: cleanReply, isUser: false));
        _isThinking = false;
      });
      _scrollToBottom();
    }).catchError((Object e, StackTrace st) {
      debugPrint('[tutor] LLM call failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          content:
            'Sorry, I hit an error while generating a response. '
            'Please try again.',
          isUser: false,
        ));
        _isThinking = false;
      });
      _scrollToBottom();
    });
  }

  List<LlmMessage> _buildHistoryTail() {
    // Keep only the last 8 chat messages to limit token count on free tier.
    final tail = _messages.length > 8 ? _messages.sublist(_messages.length - 8) : _messages;
    return tail
        .where((m) => m.content.trim().isNotEmpty)
        .map((m) => LlmMessage(role: m.isUser ? 'user' : 'assistant', content: m.content))
        .toList();
  }

  /// Extract readable text from a LearningObject's JSON content map.
  String _objectText(LearningObjectModel obj) {
    final Map<String, dynamic> content = obj.content;
    for (final key in ['text', 'body', 'content', 'html', 'description']) {
      final val = content[key];
      if (val is String && val.trim().isNotEmpty) return val.trim();
    }
    final buf = StringBuffer();
    for (final e in content.entries) {
      if (e.value is String) buf.writeln(e.value);
    }
    return buf.toString();
  }

  String _systemPrompt(String context) {
    final persona = "You are Rever, a friendly AI tutor. You help users learn "
        "deeply by explaining clearly and asking guiding questions. "
        "Answer in plain, confident prose (no bullets unless essential). "
        "Never use emoji. Do not mention being an AI model or limitations "
        "unless asked.";
    final contextSection = context.trim().isEmpty
        ? 'No extra context is available for this topic.'
        : 'Use the following source material to ground your answer:\n\n$context';
    return '$persona\n\n$contextSection';
  }

  String _stripEmojis(String input) {
    // Free-tier LLMs sometimes inject unicode emoji; strip to honor house style.
    return input.replaceAll(RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F1E6}-\u{1F1FF}]', unicode: true), '').trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_awesome,
                  color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('AI Tutor'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(
                  content: 'Chat cleared. How can I help you learn?',
                  isUser: false,
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tutor mode chips — scrollable horizontally
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: TutorMode.values.map((mode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(mode.icon, size: 16),
                    label: Text(mode.label, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _sendMessage('', mode: mode),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isThinking) {
                  return _ThinkingBubble(theme: theme);
                }
                final msg = _messages[index];
                return _ChatBubble(message: msg, theme: theme);
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (v) => _sendMessage(v),
                    decoration: InputDecoration(
                      hintText: 'Ask AI Tutor...',
                      filled: true,
                      fillColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final ThemeData theme;

  const _ChatBubble({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  final ThemeData theme;
  const _ThinkingBubble({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text('Thinking...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ],
        ),
      ),
    );
  }
}
