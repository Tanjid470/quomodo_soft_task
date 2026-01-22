import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final ShapeBorder? shapeBorder;
  final BorderRadius? borderRadius;

  const ShimmerLoader._({
    this.width,
    this.height,
    this.shapeBorder,
    this.borderRadius,
    Key? key,
  }) : super(key: key);

  factory ShimmerLoader.rect({double? width, double? height, BorderRadius? borderRadius}) {
    return ShimmerLoader._(width: width, height: height, borderRadius: borderRadius ?? BorderRadius.circular(8));
  }

  factory ShimmerLoader.circle({double size = 40}) {
    return ShimmerLoader._(width: size, height: size, shapeBorder: const CircleBorder());
  }

  factory ShimmerLoader.list({int count = 6, double itemWidth = double.infinity, double itemHeight = 150, double spacing = 12}) {
    return ShimmerLoader._(width: itemWidth, height: itemHeight);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    Widget child;
    if (shapeBorder is CircleBorder) {
      child = Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      );
    } else {
      child = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius ?? BorderRadius.circular(8)),
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
