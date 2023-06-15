import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPlaceholder extends StatelessWidget {
  const LoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SpinKitFadingCube(
      color: Theme.of(context).colorScheme.primary,
      size: 50.0,
    ));
  }
}
