import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/course.dart';

class StorageService {
  static const String _coursesKey = 'courses';

  Future<List<Course>> loadCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString(_coursesKey);

      if (coursesJson == null) {
        return [];
      }

      final List<dynamic> coursesList = jsonDecode(coursesJson);
      return coursesList.map((courseData) => Course.fromJson(courseData)).toList();
    } catch (e) {
      throw Exception('Failed to load courses from storage: $e');
    }
  }

  Future<void> saveCourses(List<Course> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = jsonEncode(courses.map((course) => course.toJson()).toList());
      await prefs.setString(_coursesKey, coursesJson);
    } catch (e) {
      throw Exception('Failed to save courses to storage: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_coursesKey);
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}