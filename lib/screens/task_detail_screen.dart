import 'package:flutter/material.dart';
import '../models/course.dart';

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final List<TaskItem> tasks;
  final String? filterType;

  const TaskDetailScreen({
    super.key,
    required this.title,
    required this.tasks,
    this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    final groupedTasks = _groupTasksByCourse();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: tasks.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedTasks.keys.length,
              itemBuilder: (context, index) {
                final courseTitle = groupedTasks.keys.elementAt(index);
                final courseTasks = groupedTasks[courseTitle]!;

                return _buildCourseSection(context, courseTitle, courseTasks);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tasks will appear here when available',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSection(BuildContext context, String courseTitle, List<TaskItem> courseTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            courseTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...courseTasks.map((task) => _buildTaskCard(context, task)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task.color.withOpacity(0.1),
          child: Icon(
            task.icon,
            color: task.color,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.deadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDeadline(task.deadline!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: task.isCompleted
            ? Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
              )
            : Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
              ),
      ),
    );
  }

  Map<String, List<TaskItem>> _groupTasksByCourse() {
    final grouped = <String, List<TaskItem>>{};

    for (final task in tasks) {
      if (!grouped.containsKey(task.courseTitle)) {
        grouped[task.courseTitle] = [];
      }
      grouped[task.courseTitle]!.add(task);
    }

    return grouped;
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      final daysPast = now.difference(deadline).inDays;
      if (daysPast == 0) {
        return 'Overdue (today)';
      } else if (daysPast == 1) {
        return 'Overdue (1 day ago)';
      } else {
        return 'Overdue ($daysPast days ago)';
      }
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else if (difference.inDays < 14) {
      return 'Due in 1 week';
    } else {
      return 'Due ${deadline.day}/${deadline.month}/${deadline.year}';
    }
  }
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String courseTitle;
  final Color color;
  final IconData icon;
  final bool isCompleted;
  final DateTime? deadline;
  final String type;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.courseTitle,
    required this.color,
    required this.icon,
    required this.isCompleted,
    this.deadline,
    required this.type,
  });

  factory TaskItem.fromLecture(Lecture lecture, String courseTitle, Color courseColor) {
    return TaskItem(
      id: lecture.id,
      title: lecture.title,
      description: lecture.notes ?? '',
      courseTitle: courseTitle,
      color: courseColor,
      icon: Icons.book,
      isCompleted: lecture.isCompleted,
      deadline: null, // Lectures don't have deadlines
      type: 'lecture',
    );
  }

  factory TaskItem.fromAssignment(Assignment assignment, String courseTitle, Color courseColor) {
    return TaskItem(
      id: assignment.id,
      title: assignment.title,
      description: assignment.description,
      courseTitle: courseTitle,
      color: courseColor,
      icon: Icons.assignment,
      isCompleted: assignment.completed,
      deadline: assignment.deadline,
      type: 'assignment',
    );
  }

  factory TaskItem.fromProject(Project project, String courseTitle, Color courseColor) {
    return TaskItem(
      id: project.id,
      title: project.title,
      description: project.description,
      courseTitle: courseTitle,
      color: courseColor,
      icon: Icons.work,
      isCompleted: project.isCompleted,
      deadline: project.deadline,
      type: 'project',
    );
  }

}