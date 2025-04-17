// ui/widgets/ad_container.dart
import 'package:flutter/material.dart';

class AdContainer extends StatelessWidget {
  final double height;

  const AdContainer({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Advertisement',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
