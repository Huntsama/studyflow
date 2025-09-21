import 'package:flutter/material.dart';
import '../models/course.dart';

class AssignmentItem extends StatefulWidget {
  final Assignment assignment;

  const AssignmentItem({
    super.key,
    required this.assignment,
  });

  @override
  State<AssignmentItem> createState() => _AssignmentItemState();
}

class _AssignmentItemState extends State<AssignmentItem> {
  @override
  Widget build(BuildContext context) {
    final isOverdue = widget.assignment.deadline != null &&
        widget.assignment.deadline!.isBefore(DateTime.now()) &&
        !widget.assignment.completed;

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isOverdue
              ? Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Checkbox(
                    value: widget.assignment.completed,
                    onChanged: (value) {
                      // TODO: Implement assignment toggle
                      setState(() {
                        // This would normally update the assignment in a state manager
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.assignment.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: widget.assignment.completed ? TextDecoration.lineThrough : null,
                        color: widget.assignment.completed ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  _buildPriorityBadge(widget.assignment.priority),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              if (widget.assignment.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    widget.assignment.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Deadline
              if (widget.assignment.deadline != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isOverdue ? Colors.red : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${_formatDate(widget.assignment.deadline!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Completion Status
              if (widget.assignment.completed) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    MaterialColor color;
    String text;

    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        text = 'HIGH';
        break;
      case 'medium':
        color = Colors.orange;
        text = 'MEDIUM';
        break;
      case 'low':
        color = Colors.green;
        text = 'LOW';
        break;
      default:
        color = Colors.grey;
        text = priority.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue by ${-difference} days';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }
}