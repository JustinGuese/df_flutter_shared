import 'package:flutter/material.dart';

class NumberedStepItem {
  final String title;
  final String description;

  const NumberedStepItem({
    required this.title,
    required this.description,
  });
}

class NumberedStepList extends StatelessWidget {
  final List<NumberedStepItem> steps;
  final Color? numberColor;
  final double spacing;

  const NumberedStepList({
    super.key,
    required this.steps,
    this.numberColor,
    this.spacing = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final number = (index + 1).toString();
        
        return Padding(
          padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: numberColor ?? Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
