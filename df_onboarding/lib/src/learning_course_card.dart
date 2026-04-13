import 'package:flutter/material.dart';
import 'learning_course_model.dart';

/// Compact card showing a course's emoji, title, risk badge, progress bar,
/// and "last accessed" nudge. Used on the Dashboard and LearningOverview.
class LearningCourseCard extends StatelessWidget {
  const LearningCourseCard({
    super.key,
    required this.course,
    required this.completionRatio,
    required this.onTap,
    this.compact = false,
  });

  final LearningCourseModel course;

  /// 0.0 – 1.0 fraction of sofort-umsetzbar items completed.
  final double completionRatio;

  final VoidCallback onTap;

  /// When true renders a smaller card (for dashboard horizontal list).
  final bool compact;

  String? _lastAccessedLabel() {
    final days = course.daysSinceLastAccess;
    if (days == null) return null;
    if (days <= 7) return null;
    if (days <= 30) return 'vor $days Tagen';
    return 'Lange nicht geprüft';
  }

  Color _badgeColour() {
    final days = course.daysSinceLastAccess;
    if (days == null || days <= 7) return Colors.transparent;
    if (days <= 30) return Colors.amber.shade700;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final label = _lastAccessedLabel();
    final badgeColour = _badgeColour();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 180 : double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: course.gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: course.gradient.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.emoji, style: TextStyle(fontSize: compact ? 24 : 30)),
                  const Spacer(),
                  // Risk badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: course.riskLevelColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: course.riskLevelColor.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      course.riskLevelLabel,
                      style: TextStyle(
                        color: course.riskLevelColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                course.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(
                  course.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionRatio,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${(completionRatio * 100).round()}% erledigt',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (label != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 10, color: badgeColour),
                        const SizedBox(width: 3),
                        Text(
                          label,
                          style: TextStyle(
                            color: badgeColour,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
