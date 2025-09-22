import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(course.color);
    final totalTasks = course.lectures.length + course.projects.length + course.assignments.length;
    final completedTasks = course.lectures.where((l) => l.isCompleted).length +
        course.projects.where((p) => p.isCompleted).length +
        course.assignments.where((a) => a.completed).length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 240, // Fixed height for consistent card sizing
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: color,
                width: 5,
              ),
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            course.semester,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description - Always show with consistent spacing
                const SizedBox(height: 8),
                SizedBox(
                  height: 32, // Fixed height for description area
                  child: course.description.isNotEmpty
                      ? Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),

                // Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${course.progress.round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: course.progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(context, Icons.book, '${course.lectures.length}'),
                    _buildStat(context, Icons.assignment, '$completedTasks/$totalTasks'),
                    if (course.credits > 0)
                      Text(
                        '${course.credits} credits',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),

                // Upcoming deadlines - Use remaining space
                const Spacer(),
                if (_getUpcomingDeadlines().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getUpcomingDeadlines().first,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<String> _getUpcomingDeadlines() {
    final now = DateTime.now();
    final upcoming = <String>[];

    // Check assignments only (lectures don't have due dates)
    for (final assignment in course.assignments) {
      if (assignment.deadline != null && assignment.deadline!.isAfter(now) && !assignment.completed) {
        final days = assignment.deadline!.difference(now).inDays;
        if (days == 0) {
          upcoming.add('${assignment.title} (due today)');
        } else if (days == 1) {
          upcoming.add('${assignment.title} (due tomorrow)');
        } else {
          upcoming.add('${assignment.title} (${days}d)');
        }
      }
    }

    // Check projects only
    for (final project in course.projects) {
      if (project.deadline != null && project.deadline!.isAfter(now) && !project.isCompleted) {
        final days = project.deadline!.difference(now).inDays;
        if (days == 0) {
          upcoming.add('${project.title} (due today)');
        } else if (days == 1) {
          upcoming.add('${project.title} (due tomorrow)');
        } else {
          upcoming.add('${project.title} (${days}d)');
        }
      }
    }

    // Sort by due date (items due sooner appear first)
    upcoming.sort((a, b) {
      if (a.contains('due today')) return -1;
      if (b.contains('due today')) return 1;
      if (a.contains('due tomorrow')) return -1;
      if (b.contains('due tomorrow')) return 1;
      return a.compareTo(b);
    });

    return upcoming.take(1).toList(); // Show only the most urgent deadline
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}