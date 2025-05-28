import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/boxManagerProvider.dart';

class FloatOptions extends StatelessWidget {
  final OptionType designatedFloatOption;
  final Widget optionsWidget;

  const FloatOptions({
    super.key,
    required this.provider,
    required this.designatedFloatOption,
    required this.optionsWidget
  });

  final BoxManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(
                    0.0,
                    0.5,
                  ),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
        child:
            provider.selectedOption == designatedFloatOption
                ? optionsWidget
                : SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

class SizerButton extends StatelessWidget {
  final bool isSize;
  final bool isAdd;

  const SizerButton({
    super.key,
    required this.provider,
    required this.isSize,
    required this.isAdd,
  });

  final BoxManagerProvider provider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Keep transparent or set a background color
      child: InkWell(
        borderRadius: BorderRadius.circular(100), // Optional rounded corners
        onTap: () {
          isSize
              ? provider.updateTrafficSize(provider.selectedTrafficIndex, isAdd)
              : provider.updateTrafficRate(provider.selectedTrafficIndex, isAdd);
        },
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Icon(isAdd ? Icons.add : Icons.remove, size: 20),
        ),
      ),
    );
  }
}
