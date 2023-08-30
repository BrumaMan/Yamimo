import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class PageAnimationWrapper extends PageRouteBuilder {
  PageAnimationWrapper({required this.key, required this.screen})
      : super(
            pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
                screen);

  final ValueKey key;
  final Widget screen;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // TODO: implement buildTransitions
    return SharedAxisTransition(
        key: key,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child);
  }
}
