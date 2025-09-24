import "package:flutter/material.dart";

import "curved_edges.dart";

class TCurvedEdgesWidget extends StatelessWidget {
  const TCurvedEdgesWidget({
    Key? key,
    this.child,
  }) : super(key: key);
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TCustomCurvedEdges(),
      child: child,
    );
  }
}
