import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Live Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _BlinkingDot(),
                  const SizedBox(width: 12),
                  Text(
                    'LIVE AUDITORIUM LEADERBOARD',
                    style: TextStyle(
                      color: Colors.redAccent.shade400,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Table Headers
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 48.0),
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                border: const Border(bottom: BorderSide(color: Colors.white24, width: 2)),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 1, child: Text('RANK', style: _headerStyle)),
                  Expanded(flex: 3, child: Text('STUDENT NAME', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('ROLL NUMBER', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('HIGH SCORE', style: _headerStyle, textAlign: TextAlign.right)),
                ],
              ),
            ),

            // Live Data Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('bestScore', descending: true)
                    .limit(15)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  
                  if (docs.isEmpty) {
                    return const Center(child: Text('NO SCORES YET', style: TextStyle(color: Colors.white54, fontSize: 24)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _LeaderboardRow(
                        index: index,
                        name: data['name'] ?? data['displayName'] ?? 'Unknown Student',
                        rollNumber: data['rollNumber'] ?? '---',
                        score: data['bestScore'] ?? 0,
                      );
                    },
                  );
                },
              ),
            ),

            // Footer Participant Counter
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'TOTAL PARTICIPANTS: $count',
                    style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 1.5),
                  ),
                );
              }
            )
          ],
        ),
      ),
    );
  }
}

const _headerStyle = TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2);

class _LeaderboardRow extends StatelessWidget {
  final int index;
  final String name;
  final String rollNumber;
  final int score;

  const _LeaderboardRow({
    required this.index,
    required this.name,
    required this.rollNumber,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.white;
    Widget? icon;

    if (index == 0) {
      bgColor = Colors.amber.withValues(alpha: 0.2);
      textColor = Colors.amber;
      icon = const Icon(Icons.workspace_premium, color: Colors.amber, size: 28);
    } else if (index == 1) {
      bgColor = Colors.blueGrey.shade300.withValues(alpha: 0.2);
      textColor = Colors.blueGrey.shade300;
      icon = Icon(Icons.workspace_premium, color: Colors.blueGrey.shade300, size: 28);
    } else if (index == 2) {
      bgColor = Colors.brown.shade400.withValues(alpha: 0.2);
      textColor = Colors.brown.shade400;
      icon = Icon(Icons.workspace_premium, color: Colors.brown.shade400, size: 28);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: index < 3 ? textColor.withValues(alpha: 0.5) : Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                if (icon != null) ...[icon, const SizedBox(width: 8)],
                Text(
                  '#${index + 1}',
                  style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              name.toUpperCase(),
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rollNumber,
              style: const TextStyle(color: Colors.white70, fontSize: 20, fontFamily: 'Courier'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              score.toString(),
              style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
