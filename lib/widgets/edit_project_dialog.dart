import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';

class EditProjectDialog extends StatefulWidget {
  final Course course;
  final Project project;

  const EditProjectDialog({
    super.key,
    required this.course,
    required this.project,
  });

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _isLoading = false;
  final List<String> _milestones = [];

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with existing project data
    _titleController.text = widget.project.title;
    _descriptionController.text = widget.project.description;
    _selectedDeadline = widget.project.deadline;

    // Pre-populate milestones
    _milestones.clear();
    _milestones.addAll(widget.project.milestones.map((m) => m.title));
    if (_milestones.isEmpty) {
      _milestones.add('');
    }
  }

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
        'Edit Project',
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
                    hintText: 'e.g., Final Web App',
                    prefixIcon: Icon(Icons.work),
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
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
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
                      labelText: 'Deadline',
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
                const Text(
                  'Project Milestones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add key milestones to track your progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Milestone Fields
                ...List.generate(
                  _milestones.length,
                  (index) => _buildMilestoneField(index),
                ),

                // Add Milestone Button
                if (_milestones.length < 5)
                  Center(
                    child: TextButton.icon(
                      onPressed: _addMilestone,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Milestone'),
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
          onPressed: _isLoading ? null : _updateProject,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Update Project'),
        ),
      ],
    );
  }

  Widget _buildMilestoneField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _milestones[index],
              decoration: InputDecoration(
                labelText: 'Milestone ${index + 1}',
                hintText: 'e.g., Complete user authentication',
                prefixIcon: const Icon(Icons.flag, size: 16),
                isDense: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                _milestones[index] = value;
              },
              validator: index == 0
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
              onPressed: () => _removeMilestone(index),
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.red.shade400,
                size: 20,
              ),
              tooltip: 'Remove milestone',
            ),
        ],
      ),
    );
  }

  void _addMilestone() {
    if (_milestones.length < 5) {
      setState(() {
        _milestones.add('');
      });
    }
  }

  void _removeMilestone(int index) {
    if (_milestones.length > 1) {
      setState(() {
        _milestones.removeAt(index);
      });
    }
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDeadline = date;
      });
    }
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create milestones from the text fields
      final milestones = <Milestone>[];
      for (int i = 0; i < _milestones.length; i++) {
        final milestoneTitle = _milestones[i].trim();
        if (milestoneTitle.isNotEmpty) {
          // Find existing milestone to preserve completion status
          final matchingMilestones = widget.project.milestones
              .where((m) => m.title == milestoneTitle);
          final existingMilestone = matchingMilestones.isNotEmpty
              ? matchingMilestones.first
              : null;

          milestones.add(Milestone(
            id: existingMilestone?.id ?? const Uuid().v4(),
            title: milestoneTitle,
            completed: existingMilestone?.completed ?? false,
            deadline: null, // Milestones don't have individual deadlines for now
          ));
        }
      }

      final updatedProject = Project(
        id: widget.project.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        milestones: milestones,
        deadline: _selectedDeadline,
      );

      final updatedProjects = widget.course.projects
          .map((p) => p.id == widget.project.id ? updatedProject : p)
          .toList();

      final updatedCourse = widget.course.copyWith(projects: updatedProjects);

      await context.read<CourseProvider>().updateCourse(updatedCourse);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${updatedProject.title}" updated successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update project: $e'),
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