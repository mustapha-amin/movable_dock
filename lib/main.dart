import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});
  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  double _calculateScale(int index) {
    if (_hoveredIndex == null) return 1.0;
    final diff = (_hoveredIndex! - index).abs();
    if (diff > 1) return 1.0;
    return 1.2 - (diff * 0.1);
  }

  double _calculateYOffset(double scale) {
    return -10 * (scale - 1.0);
  }

  void _reorderItems(int from, int to) {
    if (from == to) return;

    setState(() {
      final item = _items.removeAt(from);
      _items.insert(to, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            final icon = _items[index];
            final scale = _calculateScale(index);
            final yOffset = _calculateYOffset(scale);

            return LongPressDraggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 1.3,
                  child: _buildIcon(
                    icon,
                    Colors.primaries[index % Colors.primaries.length],
                  ),
                ),
              ),
              childWhenDragging: const SizedBox(),
              onDragStarted: () => setState(() => _hoveredIndex = null),
              child: DragTarget<int>(
                onAcceptWithDetails:
                    (fromIndex) => _reorderItems(fromIndex.data, index),
                builder: (context, _, _) {
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      transform:
                          Matrix4.identity()
                            ..translate(0.0, yOffset)
                            ..scale(scale, scale),
                      transformAlignment: Alignment.center,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
