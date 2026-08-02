import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<QuerySnapshot> _leaderboardFuture;
  late Future<QuerySnapshot> _countFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Use .get() instead of .snapshots() — avoids persistent listener that
    // triggers PERMISSION_DENIED when Firestore rules haven't been deployed yet.
    // Also works with Firestore offline cache.
    _leaderboardFuture = FirebaseFirestore.instance
        .collection('users')
        .orderBy('bestScore', descending: true)
        .limit(15)
        .get(GetOptions(source: Source.serverAndCache));
    _countFuture = FirebaseFirestore.instance
        .collection('users')
        .get(GetOptions(source: Source.serverAndCache));
  }

  void _refresh() {
    setState(() => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  const SizedBox(width: 16),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 28),
                    tooltip: 'Refresh leaderboard',
                    onPressed: _refresh,
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
              child: const Row(
                children: [
                  Expanded(flex: 1, child: Text('RANK', style: _headerStyle)),
                  Expanded(flex: 3, child: Text('STUDENT NAME', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('ROLL NUMBER', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('HIGH SCORE', style: _headerStyle, textAlign: TextAlign.right)),
                ],
              ),
            ),

            // Leaderboard data
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _leaderboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  // Handle permission denied or other errors gracefully
                  if (snapshot.hasError) {
                    final err = snapshot.error.toString();
                    final isPermission = err.contains('PERMISSION_DENIED') || err.contains('permission');
                    debugPrint('[Leaderboard] Error: $err');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPermission ? Icons.lock_outline : Icons.wifi_off,
                              color: Colors.white38,
                              size: 64,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isPermission
                                  ? 'LEADERBOARD LOCKED'
                                  : 'CONNECTION ERROR',
                              style: const TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isPermission
                                  ? 'Firestore security rules need to be published.\nGo to Firebase Console → Firestore → Rules\nand click Publish.'
                                  : 'Check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white38, fontSize: 16, height: 1.6),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('RETRY'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('NO SCORES YET', style: TextStyle(color: Colors.white54, fontSize: 24)),
                    );
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
                        score: (data['bestScore'] as num?)?.toInt() ?? 0,
                      );
                    },
                  );
                },
              ),
            ),

            // Footer participant counter
            FutureBuilder<QuerySnapshot>(
              future: _countFuture,
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'TOTAL PARTICIPANTS: $count',
                    style: const TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 1.5),
                  ),
                );
              },
            ),
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
