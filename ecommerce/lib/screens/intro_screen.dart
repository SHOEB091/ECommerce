import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  // Tunable constants for fine-tuning
  static const double cardOverlap = 0.25; // how much image overlaps bottom
  static const double bottomRadius = 20.0;
  static const double dotYOffset = -6.0;

  final List<_IntroItem> _items = const [
    _IntroItem('assets/intro1.png', 'Discover something new', 'Special new arrivals just for you'),
    _IntroItem('assets/intro2.png', 'Update trendy outfit', 'Favorite brands and hottest trends'),
    _IntroItem('assets/intro3.png', 'Explore your true style', 'Relax and let us bring the style to you'),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _items.length - 1) {
      Navigator.pushReplacementNamed(context, '/signup');
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double topArea = screen.height * 0.68; // increased top height
    final double bottomArea = screen.height * 0.32; // smaller footer
    final double cardW = screen.width * 0.68;
    final double cardH = screen.height * 0.50; // larger image card height
    const Color bottomColor = Color(0xFF4A4446);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: PageView.builder(
        controller: _pc,
        itemCount: _items.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) {
          final item = _items[index];

          return Column(
            children: [
              // ---------------- TOP WHITE AREA ----------------
              SizedBox(
                height: topArea,
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 14),

                          // ----------- IMAGE CARD (OVERLAPS BOTTOM) ------------
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final overlapPx = cardH * cardOverlap;
                                final cardTop = constraints.maxHeight - (cardH - overlapPx);

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Left tab behind card
                                    Positioned(
                                      left: 6,
                                      top: cardTop + (cardH * 0.15),
                                      child: Container(
                                        width: 36,
                                        height: cardH * 0.56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEDEDED),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),

                                    // Right tab behind card
                                    Positioned(
                                      right: 6,
                                      top: cardTop + (cardH * 0.15),
                                      child: Container(
                                        width: 36,
                                        height: cardH * 0.56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEDEDED),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),

                                    // Shadow backing behind image card
                                    Positioned(
                                      left: (constraints.maxWidth - (cardW + 18)) / 2,
                                      top: cardTop + 6,
                                      child: Container(
                                        width: cardW + 18,
                                        height: cardH + 12,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Main image card
                                    Positioned(
                                      left: (constraints.maxWidth - cardW) / 2,
                                      top: cardTop,
                                      child: Container(
                                        width: cardW,
                                        height: cardH,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Image.asset(
                                          item.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey[200],
                                            child: const Center(child: Icon(Icons.image, size: 36)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------- BOTTOM DARK AREA ----------------
              SizedBox(
                height: bottomArea,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Rounded dark background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: bottomColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(bottomRadius),
                            topRight: Radius.circular(bottomRadius),
                          ),
                        ),
                      ),
                    ),

                    // Content inside dark area
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Dots
                            Transform.translate(
                              offset: Offset(0, dotYOffset),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_items.length, (dot) {
                                  final bool active = dot == index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    width: active ? 12 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: active ? Colors.white : Colors.white54,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Pill button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _next,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.4),
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                ),
                                child: const Text(
                                  'Shopping now',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top subtle fade/shadow for overlap realism
                    Positioned(
                      top: -6,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.06),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IntroItem {
  final String image;
  final String title;
  final String subtitle;
  const _IntroItem(this.image, this.title, this.subtitle);
}
