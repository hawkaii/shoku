import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The chosen mark: a plate with rim, a tomato and a leaf.
/// Same file as the launcher icon, so the brand is one drawing everywhere.
class PlateMark extends StatelessWidget {
  final double size;
  final String asset;

  const PlateMark(
      {super.key, this.size = 64, this.asset = 'assets/brand/mark.svg'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => SizedBox(width: size, height: size),
      ),
    );
  }
}
