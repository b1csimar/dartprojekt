import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Card Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MemoryGameScreen(),
    );
  }
}

class Card {
  final String id;
  final String symbol;
  bool isFlipped;
  bool isMatched;

  Card({
    required this.id,
    required this.symbol,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<Card> cards;
  late int moves;
  late int matchedPairs;
  late Duration elapsedTime;
  late Timer gameTimer;
  bool isGameRunning = false;
  bool isGameOver = false;

  final List<String> symbols = [
    '🐶', '🐱', '🐭', '🐹',
    '🐰', '🦊', '🐻', '🐼',
  ];

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    moves = 0;
    matchedPairs = 0;
    elapsedTime = Duration.zero;
    isGameRunning = false;
    isGameOver = false;


    cards = [];
    for (int i = 0; i < symbols.length; i++) {
      cards.add(Card(id: '${i}a', symbol: symbols[i]));
      cards.add(Card(id: '${i}b', symbol: symbols[i]));
    }


    cards.shuffle();
  }

  void startGame() {
    if (!isGameRunning) {
      setState(() {
        isGameRunning = true;
      });

      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          elapsedTime = Duration(seconds: elapsedTime.inSeconds + 1);
        });
      });
    }
  }

  void onCardTapped(int index) {
    if (!isGameRunning) {
      startGame();
    }

    if (isGameOver || cards[index].isMatched || cards[index].isFlipped) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
    });

    List<int> flippedIndices =
        cards.asMap().entries
            .where((e) => e.value.isFlipped && !e.value.isMatched)
            .map((e) => e.key)
            .toList();

    if (flippedIndices.length == 2) {
      if (cards[flippedIndices[0]].symbol == cards[flippedIndices[1]].symbol) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            cards[flippedIndices[0]].isMatched = true;
            cards[flippedIndices[1]].isMatched = true;
            matchedPairs++;

            if (matchedPairs == symbols.length) {
              isGameOver = true;
              gameTimer.cancel();
            }
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            cards[flippedIndices[0]].isFlipped = false;
            cards[flippedIndices[1]].isFlipped = false;
          });
        });
      }

      setState(() {
        moves++;
      });
    }
  }

  void resetGame() {
    gameTimer.cancel();
    setState(() {
      initializeGame();
    });
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Memory Card Game'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '⏱️',
                        '${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        'Idő',
                      ),
                      _buildStatItem(
                        '👞',
                        moves.toString(),
                        'Lépések',
                      ),
                      _buildStatItem(
                        '✨',
                        '${matchedPairs}/${symbols.length}',
                        'Párok',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onCardTapped(index),
                    child: AnimatedCardWidget(
                      card: cards[index],
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              if (isGameOver)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎉 Gratulálunk!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Játék befejezve ${moves} lépésben\n${elapsedTime.inMinutes} perc ${elapsedTime.inSeconds % 60} másodperc alatt',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Új játék'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class AnimatedCardWidget extends StatefulWidget {
  final Card card;

  const AnimatedCardWidget({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AnimatedCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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
      builder: (context, child) {
        final angle = _controller.value * 3.14159;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: Container(
            decoration: BoxDecoration(
              color: widget.card.isFlipped || widget.card.isMatched
                  ? Colors.white
                  : Colors.blue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.card.isMatched
                    ? Colors.green
                    : Colors.blue.shade700,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.card.isFlipped || widget.card.isMatched
                ? Center(
                    child: Text(
                      widget.card.symbol,
                      style: const TextStyle(fontSize: 40),
                    ),
                  )
                : const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 40,
                  ),
          ),
        );
      },
    );
  }
}
