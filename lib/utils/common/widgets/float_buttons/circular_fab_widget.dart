import 'dart:math';

import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/circuler_container.dart';

const double buttonSize = 80;

class TCircularFabWidget extends StatefulWidget {
  const TCircularFabWidget({super.key});

  @override
  State<TCircularFabWidget> createState() => _TCircularFabWidgetState();
}

class _TCircularFabWidgetState extends State<TCircularFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(microseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Flow(
    delegate: FlowMenuDelegate(controller: controller),
    children:
        <IconData>[
          Icons.mail,
          Icons.call,
          Icons.notifications,
          Icons.newspaper,
          Icons.menu,
        ].map<Widget>(buildFAB).toList(),
  );

  Widget buildFAB(IconData icon) => SizedBox(
    width: buttonSize,
    height: buttonSize,
    child: FloatingActionButton(
      onPressed: () {
        if (controller.status == AnimationStatus.completed) {
          controller.reverse();
        } else {
          controller.forward();
        }
      },
      elevation: 0,
      splashColor: Colors.black,
      child: TCirculerContainer(
        // backgroundColor: TColors.primary,
        width: 30,
        height: 30,
        child: Icon(icon, color: Colors.green, size: 20),
      ),
    ),
  );
}

class FlowMenuDelegate extends FlowDelegate {
  final Animation<double> controller;

  const FlowMenuDelegate({required this.controller})
    : super(repaint: controller);
  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - buttonSize;
    final yStart = size.height - buttonSize;

    final n = context.childCount;

    for (int i = 0; i < n; i++) {
      final isLastItem = i == context.childCount - 1;
      setValue(value) => isLastItem ? 0.0 : value;

      final radius = 180 * controller.value;
      final theta = i * pi * 0.5 / (n - 2);
      final x = xStart - setValue(radius * cos(theta));
      final y = yStart - setValue(radius * sin(theta));

      context.paintChild(
        i,
        transform:
            Matrix4.identity()
              ..translate(x, y, 0)
              ..translate(-buttonSize / 2, -buttonSize / 2)
              ..rotateZ(
                isLastItem ? 0.0 : 180 * (1 - controller.value) * pi / 180,
              )
              ..scale(isLastItem ? 1.0 : max(controller.value, 0.5))
              ..translate(-buttonSize / 2, -buttonSize / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}
