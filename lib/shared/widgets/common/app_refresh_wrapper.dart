import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppRefreshWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget? child;
  final List<Widget>? slivers;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const AppRefreshWrapper({
    super.key,
    required this.onRefresh,
    this.child,
    this.slivers,
    this.padding,
    this.physics,
    this.controller,
  }) : assert(child != null || slivers != null);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          refreshTriggerPullDistance: 110,
          refreshIndicatorExtent: 70,
        ),
        if (slivers != null)
          ...slivers!
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: child,
              ),
            ),
          ),
      ],
    );
  }
}
