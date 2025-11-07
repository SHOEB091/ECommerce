// lib/screens/intro_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pc = PageController();
  int _page = 0;
  bool _didPrecache = false;

  final List<_IntroItem> _items = const [
    _IntroItem('assets/intro1.png', 'Discover something new', 'Special new arrivals just for you'),
    _IntroItem('assets/intro2.png', 'Update trendy outfit', 'Favorite brands and hottest trends'),
    _IntroItem('assets/intro3.png', 'Explore your true style', 'Relax and let us bring the style to you'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecache) {
      for (final item in _items) {
        precacheImage(AssetImage(item.image), context);
      }
      _didPrecache = true;
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _items.length - 1) {
      Navigator.pushReplacementNamed(context, '/signup');
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  Widget _assetImage(String path, double targetWidth, double targetHeight) {
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final int cacheW = max(1, (targetWidth * dpr).round());
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheW,
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 260),
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }

  // Mobile full-screen page
  Widget _mobilePage(BuildContext context, _IntroItem item) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double targetHeight = size.height;
    final double targetWidth = width;

    return Stack(
      children: [
        Positioned.fill(child: _assetImage(item.image, targetWidth, targetHeight)),

        // Light gradient overlay for readability
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 160,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.9), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: min(360, size.height * 0.5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.white.withOpacity(0.95)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.35, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.white70, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.35),
              ),
            ],
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_items.length, (i) {
                        final bool active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: active ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active ? Colors.black87 : Colors.black26,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 4,
                    ),
                    child: Text(
                      _page == _items.length - 1 ? 'Get Started' : 'Shop now',
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Desktop layout (light theme)
  Widget _desktopPage(BuildContext context, _IntroItem item, double w, double h) {
    final double leftMax = (w * 0.46).clamp(320.0, 720.0);
    const double imgAspect = 3 / 2;
    final double cardW = leftMax;
    final double cardH = cardW / imgAspect;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200, minHeight: h * 0.7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: cardW + 18,
                  height: cardH + 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 10,
                        top: cardH * 0.12,
                        child: Container(
                          width: max(28, cardW * 0.07),
                          height: cardH * 0.56,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: cardH * 0.12,
                        child: Container(
                          width: max(28, cardW * 0.07),
                          height: cardH * 0.56,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      Positioned(
                        left: 9,
                        top: 6,
                        child: Container(
                          width: cardW,
                          height: cardH,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.hardEdge,
                          child: _assetImage(item.image, cardW, cardH),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 36),
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Text(item.subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4)),
                      const SizedBox(height: 18),
                      Text(
                        'Browse curated collections and newest drops. Save favorites, track orders, and enjoy exclusive deals tailored for you.',
                        style: TextStyle(color: Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Row(
                            children: List.generate(_items.length, (dot) {
                              final bool active = dot == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                width: active ? 16 : 8,
                                height: 8,
                                decoration: BoxDecoration(color: active ? Colors.black87 : Colors.black26, borderRadius: BorderRadius.circular(4)),
                              );
                            }),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              elevation: 6,
                            ),
                            child: Text(
                              _page == _items.length - 1 ? 'Get Started' : 'Shop now',
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final bool large = w >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pc,
        itemCount: _items.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) {
          final item = _items[index];
          if (large) {
            return _desktopPage(context, item, w, h);
          } else {
            return _mobilePage(context, item);
          }
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
