import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/storage_service.dart';

class CourseProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Course> _courses = [];
  bool _isLoading = false;
  String _error = '';

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isEmpty => _courses.isEmpty;

  double get overallProgress {
    if (_courses.isEmpty) return 0.0;
    return _courses.map((course) => course.progress).reduce((a, b) => a + b) / _courses.length;
  }


  int get upcomingDeadlines {
    final now = DateTime.now();
    final oneWeek = now.add(const Duration(days: 7));

    int count = 0;
    for (final course in _courses) {
      // Skip lectures as they don't have deadlines
      for (final assignment in course.assignments) {
        if (assignment.deadline != null &&
            assignment.deadline!.isAfter(now) &&
            assignment.deadline!.isBefore(oneWeek) &&
            !assignment.completed) {
          count++;
        }
      }
      for (final project in course.projects) {
        if (project.deadline != null &&
            project.deadline!.isAfter(now) &&
            project.deadline!.isBefore(oneWeek) &&
            !project.isCompleted) {
          count++;
        }
      }
    }
    return count;
  }

  Future<void> loadCourses() async {
    _setLoading(true);
    try {
      _courses = await _storageService.loadCourses();
      _error = '';
    } catch (e) {
      _error = 'Failed to load courses: $e';
      _courses = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCourse(Course course) async {
    try {
      _courses.add(course);
      await _storageService.saveCourses(_courses);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add course: $e';
      notifyListeners();
    }
  }

  Future<void> updateCourse(Course updatedCourse) async {
    try {
      final index = _courses.indexWhere((course) => course.id == updatedCourse.id);
      if (index != -1) {
        _courses[index] = updatedCourse;
        await _storageService.saveCourses(_courses);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update course: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      _courses.removeWhere((course) => course.id == courseId);
      await _storageService.saveCourses(_courses);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete course: $e';
      notifyListeners();
    }
  }

  Future<void> toggleLecturePhase(String courseId, String lectureId, String phaseId) async {
    try {
      final courseIndex = _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final lectureIndex = course.lectures.indexWhere((lecture) => lecture.id == lectureId);
        if (lectureIndex != -1) {
          final lecture = course.lectures[lectureIndex];
          final phaseIndex = lecture.phases.indexWhere((phase) => phase.id == phaseId);
          if (phaseIndex != -1) {
            final phase = lecture.phases[phaseIndex];
            final updatedPhase = phase.copyWith(completed: !phase.completed);

            final updatedPhases = List<LecturePhase>.from(lecture.phases);
            updatedPhases[phaseIndex] = updatedPhase;

            final updatedLecture = Lecture(
              id: lecture.id,
              title: lecture.title,
              phases: updatedPhases,
              notes: lecture.notes,
            );

            final updatedLectures = List<Lecture>.from(course.lectures);
            updatedLectures[lectureIndex] = updatedLecture;

            final updatedCourse = course.copyWith(lectures: updatedLectures);
            _courses[courseIndex] = updatedCourse;

            await _storageService.saveCourses(_courses);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _error = 'Failed to update lecture phase: $e';
      notifyListeners();
    }
  }

  Future<void> toggleAssignmentCompleted(String courseId, String assignmentId) async {
    try {
      final courseIndex = _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final assignmentIndex = course.assignments.indexWhere((assignment) => assignment.id == assignmentId);
        if (assignmentIndex != -1) {
          final assignment = course.assignments[assignmentIndex];
          final updatedAssignment = assignment.copyWith(completed: !assignment.completed);

          final updatedAssignments = List<Assignment>.from(course.assignments);
          updatedAssignments[assignmentIndex] = updatedAssignment;

          final updatedCourse = course.copyWith(assignments: updatedAssignments);
          _courses[courseIndex] = updatedCourse;

          await _storageService.saveCourses(_courses);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to update assignment: $e';
      notifyListeners();
    }
  }

  Future<void> toggleMilestoneCompleted(String courseId, String projectId, String milestoneId) async {
    try {
      final courseIndex = _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final projectIndex = course.projects.indexWhere((project) => project.id == projectId);
        if (projectIndex != -1) {
          final project = course.projects[projectIndex];
          final milestoneIndex = project.milestones.indexWhere((milestone) => milestone.id == milestoneId);
          if (milestoneIndex != -1) {
            final milestone = project.milestones[milestoneIndex];
            final updatedMilestone = milestone.copyWith(completed: !milestone.completed);

            final updatedMilestones = List<Milestone>.from(project.milestones);
            updatedMilestones[milestoneIndex] = updatedMilestone;

            final updatedProject = Project(
              id: project.id,
              title: project.title,
              description: project.description,
              milestones: updatedMilestones,
              deadline: project.deadline,
            );

            final updatedProjects = List<Project>.from(course.projects);
            updatedProjects[projectIndex] = updatedProject;

            final updatedCourse = course.copyWith(projects: updatedProjects);
            _courses[courseIndex] = updatedCourse;

            await _storageService.saveCourses(_courses);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _error = 'Failed to update milestone: $e';
      notifyListeners();
    }
  }

  Future<void> deleteProject(String courseId, String projectId) async {
    try {
      final courseIndex = _courses.indexWhere((course) => course.id == courseId);
      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final updatedProjects = course.projects.where((project) => project.id != projectId).toList();

        final updatedCourse = course.copyWith(projects: updatedProjects);
        _courses[courseIndex] = updatedCourse;

        await _storageService.saveCourses(_courses);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  List<Course> searchCourses(String query) {
    if (query.isEmpty) return _courses;
    return _courses.where((course) =>
        course.title.toLowerCase().contains(query.toLowerCase()) ||
        course.description.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }


  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}