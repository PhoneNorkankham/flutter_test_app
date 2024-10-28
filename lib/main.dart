import 'package:flutter/material.dart';

// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

//building the app.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Dock(
                  items: const [
                    Icons.person,
                    Icons.message,
                    Icons.call,
                    Icons.camera,
                    Icons.photo,
                  ],
                  builder: (icon, isHovered) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: isHovered ? 64 : 48,
                      width: isHovered ? 64 : 48,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors
                            .primaries[icon.hashCode % Colors.primaries.length],
                      ),
                      child: Icon(icon,
                          color: Colors.white, size: isHovered ? 36 : 24),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Dock of the reorderable[items].
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<IconData> items;
  final Widget Function(IconData, bool) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items = widget.items;
  IconData? _draggedIcon;
  int? _draggedIndex;
  bool _isDragging = false;
  int _hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      height: 72,
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        // Drag horizontally like Dock
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return MouseRegion(
              onEnter: (_) => setState(() => _hoverIndex = index),
              onExit: (_) => setState(() => _hoverIndex = -1),
              child: Draggable<IconData>(
                key: ValueKey(_items[index]),
                data: _items[index],
                onDragStarted: () {
                  setState(() {
                    _isDragging = true;
                    _draggedIcon = _items[index];
                    _draggedIndex = index;
                  });
                },
                onDraggableCanceled: (_, __) {
                  setState(() {
                    _draggedIcon = null;
                    _draggedIndex = null;
                    _isDragging = false;
                  });
                },
                onDragEnd: (_) {
                  setState(() {
                    _draggedIcon = null;
                    _draggedIndex = null;
                    _isDragging = false;
                  });
                },
                feedback: Material(
                  color: Colors.transparent,
                  child: AnimatedScale(
                    scale: 1.2,
                    duration: const Duration(milliseconds: 300),
                    child: widget.builder(_items[index], true),
                  ),
                ),
                childWhenDragging: const SizedBox.shrink(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    key: ValueKey(_items[index]),
                    onTap: () {
                      if (!_isDragging) return;
                    },
                    child: CustomReorderableDelayedDragStartListener(
                      index: index,
                      child:
                          widget.builder(_items[index], _hoverIndex == index),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CustomReorderableDelayedDragStartListener extends StatelessWidget {
  // Creates a listener for an drag following a long press event over the
  // given child widget.
  //
  // This is most commonly used to wrap an entire list item in a reorderable
  // list.
  const CustomReorderableDelayedDragStartListener({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: child,
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: child,
    );
  }
}
