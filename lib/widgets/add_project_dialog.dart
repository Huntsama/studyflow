import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';

class AddProjectDialog extends StatefulWidget {
  final Course course;

  const AddProjectDialog({
    super.key,
    required this.course,
  });

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _isLoading = false;
  final List<String> _milestones = [''];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add New Project',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Project Title *',
                    hintText: 'e.g., Task Manager App',
                    prefixIcon: Icon(Icons.timeline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a project title';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Project Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Brief description of the project',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a project description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Deadline
                InkWell(
                  onTap: _selectDeadline,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Project Deadline',
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedDeadline == null
                          ? 'Select deadline (optional)'
                          : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
                      style: TextStyle(
                        color: _selectedDeadline == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Milestones Section
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Colors.purple.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Project Milestones',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addMilestone,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Milestones List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < _milestones.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.purple.shade300),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _milestones[i],
                                  decoration: InputDecoration(
                                    hintText: 'Milestone ${i + 1}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _milestones[i] = value;
                                  },
                                  validator: i == 0
                                      ? (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'At least one milestone is required';
                                          }
                                          return null;
                                        }
                                      : null,
                                ),
                              ),
                              if (_milestones.length > 1)
                                IconButton(
                                  onPressed: () => _removeMilestone(i),
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red.shade400,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                            ],
                          ),
                        ),
                      if (_milestones.isEmpty)
                        Text(
                          'Add milestones to break down your project into manageable steps',
                          style: TextStyle(
                            color: Colors.purple.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _addProject,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Project'),
        ),
      ],
    );
  }

  void _addMilestone() {
    setState(() {
      _milestones.add('');
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      if (_milestones.length > 1) {
        _milestones.removeAt(index);
      }
    });
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDeadline = date;
      });
    }
  }

  Future<void> _addProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate milestones
    final validMilestones = _milestones
        .where((milestone) => milestone.trim().isNotEmpty)
        .toList();

    if (validMilestones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one milestone'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final project = Project(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        milestones: validMilestones.map((title) => Milestone(
          id: const Uuid().v4(),
          title: title.trim(),
          completed: false,
        )).toList(),
        deadline: _selectedDeadline,
      );

      final updatedProjects = List<Project>.from(widget.course.projects)
        ..add(project);

      final updatedCourse = widget.course.copyWith(projects: updatedProjects);

      await context.read<CourseProvider>().updateCourse(updatedCourse);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.title}" added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add project: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}