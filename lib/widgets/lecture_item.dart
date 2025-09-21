import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class LectureItem extends StatefulWidget {
  final Lecture lecture;
  final String courseId;

  const LectureItem({
    super.key,
    required this.lecture,
    required this.courseId,
  });

  @override
  State<LectureItem> createState() => _LectureItemState();
}

class _LectureItemState extends State<LectureItem> {
  @override
  Widget build(BuildContext context) {
    final isOverdue = false; // Lectures don't have deadlines

    return Semantics(
      label: 'Lecture: ${widget.lecture.title}. Progress: ${widget.lecture.progress.round()} percent. ${isOverdue ? 'Overdue' : widget.lecture.isCompleted ? 'Completed' : 'In progress'}',
      child: Card(
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
                    Expanded(
                      child: Text(
                        widget.lecture.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.lecture.isCompleted
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.lecture.progress.round()}%',
                        style: TextStyle(
                          color: widget.lecture.isCompleted
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Lectures don't have deadlines

                // Progress Bar
                LinearProgressIndicator(
                  value: widget.lecture.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.lecture.isCompleted ? Colors.green : Colors.blue,
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 16),

                // Phases
                Text(
                  'Study Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: widget.lecture.phases.map((phase) => _buildPhaseItem(phase)).toList(),
                ),

                // Notes
                if (widget.lecture.notes != null && widget.lecture.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.yellow.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.lecture.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.yellow.shade800,
                            ),
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
      ),
    );
  }

  Widget _buildPhaseItem(LecturePhase phase) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Semantics(
            label: '${phase.name} phase. ${phase.completed ? 'Completed' : 'Not completed'}. Tap to toggle.',
            child: Checkbox(
              value: phase.completed,
              onChanged: (value) {
                context.read<CourseProvider>().toggleLecturePhase(
                  widget.courseId,
                  widget.lecture.id,
                  phase.id,
                );
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              phase.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: phase.completed ? TextDecoration.lineThrough : null,
                color: phase.completed ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(phase.weight * 100).round()}%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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