import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key, this.calls = false});
  final bool calls;
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool searching = false;
  String query = '';
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return AppPage(
      title: 'Message',
      tab: 2,
      actions: [
        IconButton(
          tooltip: 'Search messages',
          onPressed: () => setState(() => searching = !searching),
          icon: const Icon(Icons.search, color: null),
        ),
        const SizedBox(width: 18),
      ],
      children: [
        ChoiceRow(
          const ['Chat', 'Call'],
          widget.calls ? 'Call' : 'Chat',
          (v) => Navigator.pushReplacementNamed(
            context,
            v == 'Chat' ? '/messages' : '/calls',
          ),
        ),
        if (searching) ...[
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => query = v.toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Search contacts',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ],
        const SizedBox(height: 24),
        for (var i = 0; i < contacts.length; i++)
          if (contacts[i].toLowerCase().contains(query))
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  s.chatContact = contacts[i];
                  go(context, widget.calls ? '/call' : '/chat');
                },
                child: Row(
                  children: [
                    Avatar(index: i + 1, size: 60),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contacts[i],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.calls
                                ? (i % 2 == 0
                                      ? '↗ Outgoing · Today'
                                      : '↙ Incoming · Yesterday')
                                : (s.chats[contacts[i]]?.last.text ??
                                      [
                                        'Hi Good Morning',
                                        'Good luck Bro.',
                                        'Omg this amazing',
                                        'How are you',
                                        'I just finished it',
                                        'Wow, this really epic',
                                      ][i]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (widget.calls)
                      const Icon(Icons.phone_outlined, color: blue)
                    else
                      Column(
                        children: [
                          if (i < 2)
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: blue,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            i < 2 ? '10:29' : 'Yesterday',
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.support = false});
  final bool support;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final scroll = ScrollController();
  @override
  void dispose() {
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    final s = AppScope.of(context);
    if (controller.text.trim().isEmpty) return;
    s.chatContact = widget.support ? 'Customer Service' : s.chatContact;
    s.sendMessage(controller.text);
    controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        contact = widget.support
            ? 'Customer Service'
            : AppScope.of(context).chatContact;
    final messages = s.messages(contact);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Avatar(index: widget.support ? 2 : 3, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Local demo conversation',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            onPressed: () => go(context, '/call'),
            icon: const Icon(Icons.phone_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: [
                const Center(child: Tag('Today')),
                const SizedBox(height: 28),
                for (final m in messages)
                  Align(
                    alignment: m.mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .74,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: m.mine
                            ? blue
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(m.mine ? 16 : 3),
                          bottomRight: Radius.circular(m.mine ? 3 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            m.text,
                            style: TextStyle(
                              color: m.mine ? Colors.white : null,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            m.mine ? '10:32  ✓✓' : '10:30',
                            style: TextStyle(
                              color: m.mine ? Colors.white70 : muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('message-input'),
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => send(),
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: send,
                    style: IconButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.send_outlined),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CallPage extends StatefulWidget {
  const CallPage({super.key});
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  bool mute = false, speaker = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const Spacer(),
            const Avatar(index: 3, size: 140),
            const SizedBox(height: 28),
            Text(
              AppScope.of(context).chatContact,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            const Text(
              'Demo call preview',
              style: TextStyle(color: muted, fontSize: 17),
            ),
            const SizedBox(height: 14),
            const Text(
              'No call is placed in this local demo.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Mute',
                  onPressed: () => setState(() => mute = !mute),
                  icon: Icon(mute ? Icons.mic_off : Icons.mic),
                ),
                IconButton.filled(
                  tooltip: 'End call',
                  onPressed: () => Navigator.maybePop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(24),
                  ),
                  icon: const Icon(Icons.call_end, color: Colors.white),
                ),
                IconButton.filledTonal(
                  tooltip: 'Speaker',
                  onPressed: () => setState(() => speaker = !speaker),
                  icon: Icon(speaker ? Icons.volume_up : Icons.volume_off),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    ),
  );
}
