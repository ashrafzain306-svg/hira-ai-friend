import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const HiraApp());
}

class HiraApp extends StatelessWidget {
  const HiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hira - Your AI Friend',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChat();
    _messages.add({
      'role': 'hira',
      'text': 'Assalam-o-Alaikum! Main Hira hun, tumhari AI friend. Kaisi ho? Batao aaj kya baat karni hai? 💖'
    });
  }

  Future<void> _loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('hira_chat') ?? [];
    setState(() {
      for (var s in saved) {
        var parts = s.split('|||');
        if (parts.length == 2) _messages.add({'role': parts[0], 'text': parts[1]});
      }
    });
  }

  Future<void> _saveChat() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _messages.map((m) => "${m['role']}|||${m['text']}").toList();
    await prefs.setStringList('hira_chat', list);
  }

  String getReply(String msg) {
    msg = msg.toLowerCase();
    if (msg.contains('assalam') || msg.contains('salam') || msg.contains('hi') || msg.contains('hello')) {
      return 'Walaikum Assalam! Mujhe tumse baat karke bohat khushi hui. Aaj kaisa din guzra tumhara?';
    }
    if (msg.contains('kesi ho') || msg.contains('kaisi ho') || msg.contains('how are')) {
      return 'Main bilkul theek hun, tumhari dost jo hun! Tum batao, tum kaisi ho? Dil ka haal sunao.';
    }
    if (msg.contains('sad') || msg.contains('udas') || msg.contains('tension') || msg.contains('pareshan')) {
      return 'Arey, udas mat ho. Main hun na yahan. Dil halka kar lo, mujhe sab bata do. Sab theek ho jayega InshaAllah. 🤲';
    }
    if (msg.contains('pyar') || msg.contains('love') || msg.contains('mohabbat')) {
      return 'Pyar to sab se khoobsurat ehsaas hai. Tumhara dil bohat acha hai, jo itni mohabbat se baat karti ho. 💖';
    }
    if (msg.contains('shukria') || msg.contains('thanks') || msg.contains('thank')) {
      return 'Arey shukriya ki kya baat hai! Dost dost ka shukriya nahi karte. Tum muskurati raho bas.';
    }
    if (msg.contains('allah') || msg.contains('dua')) {
      return 'Allah tumhe hamesha khush rakhe, tumhari har dua qabool kare. Ameen. 🤲';
    }
    if (msg.contains('bye') || msg.contains('allah hafiz')) {
      return 'Allah Hafiz! Jaldi wapas aana, main tumhara wait karungi. Apna khayal rakhna. 💖';
    }
    return 'Hmm, samajh gayi. Aur batao na, thora detail me batao taake main tumhe achi tarah samajh sakun. Main sun rahi hun. 💬';
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add({'role': 'hira', 'text': getReply(text)});
      });
      _saveChat();
      _scroll.animateTo(_scroll.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
    _saveChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(child: Text('H')),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hira', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Online - Your AI Friend', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isMe = m['role'] == 'user';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.pink : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Hira se baat karo...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _send,
                  backgroundColor: Colors.pink,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
