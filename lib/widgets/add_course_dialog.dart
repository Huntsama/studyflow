import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _semesterController = TextEditingController();
  final _creditsController = TextEditingController();

  String _selectedColor = '#3B82F6'; // Default blue color
  bool _isLoading = false;

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Blue', 'value': '#3B82F6', 'color': const Color(0xFF3B82F6)},
    {'name': 'Green', 'value': '#10B981', 'color': const Color(0xFF10B981)},
    {'name': 'Purple', 'value': '#8B5CF6', 'color': const Color(0xFF8B5CF6)},
    {'name': 'Orange', 'value': '#F59E0B', 'color': const Color(0xFFF59E0B)},
    {'name': 'Red', 'value': '#EF4444', 'color': const Color(0xFFEF4444)},
    {'name': 'Pink', 'value': '#EC4899', 'color': const Color(0xFFEC4899)},
    {'name': 'Teal', 'value': '#14B8A6', 'color': const Color(0xFF14B8A6)},
    {'name': 'Indigo', 'value': '#6366F1', 'color': const Color(0xFF6366F1)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _semesterController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add New Course',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
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
                // Course Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Course Title *',
                    hintText: 'e.g., Advanced React Development',
                    prefixIcon: Icon(Icons.school),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a course title';
                    }
                    if (value.trim().length < 3) {
                      return 'Course title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Course Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of the course content',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Semester and Credits Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _semesterController,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          hintText: 'e.g., Fall 2024',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _creditsController,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          hintText: '3',
                          prefixIcon: Icon(Icons.star),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final credits = int.tryParse(value);
                            if (credits == null || credits < 1 || credits > 10) {
                              return 'Enter 1-10';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Color Selection
                const Text(
                  'Course Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorOptions.map((colorOption) {
                    final isSelected = _selectedColor == colorOption['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = colorOption['value'];
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorOption['color'],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorOption['color'].withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_colorOptions.firstWhere((c) => c['value'] == _selectedColor)['name']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
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
          onPressed: _isLoading ? null : _addCourse,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Course'),
        ),
      ],
    );
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final course = Course(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        semester: _semesterController.text.trim().isNotEmpty
            ? _semesterController.text.trim()
            : 'Current Semester',
        credits: _creditsController.text.isNotEmpty
            ? int.parse(_creditsController.text)
            : 3,
      );

      await context.read<CourseProvider>().addCourse(course);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course "${course.title}" added successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to course detail
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add course: $e'),
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