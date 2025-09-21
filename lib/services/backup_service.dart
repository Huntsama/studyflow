import 'dart:convert';
import 'dart:io';
// import 'package:file_picker/file_picker.dart'; // Temporarily disabled for Windows compatibility
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';

class BackupService {
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all courses data
      final coursesJson = prefs.getString('courses');
      List<Course> courses = [];
      if (coursesJson != null) {
        final List<dynamic> coursesList = jsonDecode(coursesJson);
        courses = coursesList.map((courseData) => Course.fromJson(courseData)).toList();
      }

      // Get all settings
      final settingsData = {
        'show_overall_progress': prefs.getBool('show_overall_progress') ?? true,
        'text_size_scale': prefs.getDouble('text_size_scale') ?? 1.0,
        'is_dark_mode': prefs.getBool('is_dark_mode') ?? false,
        'high_contrast': prefs.getBool('high_contrast') ?? false,
      };

      // Create export data structure
      final exportData = {
        'app_name': 'StudyFlow',
        'export_version': '1.0',
        'export_timestamp': DateTime.now().toIso8601String(),
        'courses': courses.map((course) => course.toJson()).toList(),
        'settings': settingsData,
        'metadata': {
          'total_courses': courses.length,
          'total_assignments': courses.fold<int>(0, (sum, course) => sum + course.assignments.length),
          'total_projects': courses.fold<int>(0, (sum, course) => sum + course.projects.length),
          'total_lectures': courses.fold<int>(0, (sum, course) => sum + course.lectures.length),
        }
      };

      return exportData;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<String> saveExportToFile(Map<String, dynamic> exportData) async {
    try {
      // Create a compact JSON string
      final jsonString = jsonEncode(exportData);

      // Get the downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'studyflow_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      // Write the file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save export file: $e');
    }
  }

  Future<String?> pickImportFile() async {
    // Temporarily disabled for Windows compatibility
    // TODO: Re-enable file picker when compatible version is available
    throw Exception('File picker temporarily disabled for Windows compatibility');
  }

  Future<Map<String, dynamic>> loadImportData(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate the data structure
      if (!data.containsKey('app_name') ||
          !data.containsKey('export_version') ||
          !data.containsKey('courses') ||
          !data.containsKey('settings')) {
        throw Exception('Invalid backup file format');
      }

      if (data['app_name'] != 'StudyFlow') {
        throw Exception('This backup file is not from StudyFlow');
      }

      return data;
    } catch (e) {
      throw Exception('Failed to load import data: $e');
    }
  }

  Future<void> importAllData(Map<String, dynamic> importData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Import courses
      final coursesData = importData['courses'] as List<dynamic>;
      final courses = coursesData.map((courseData) => Course.fromJson(courseData)).toList();
      final coursesJson = jsonEncode(courses.map((course) => course.toJson()).toList());
      await prefs.setString('courses', coursesJson);

      // Import settings
      final settingsData = importData['settings'] as Map<String, dynamic>;
      await prefs.setBool('show_overall_progress', settingsData['show_overall_progress'] ?? true);
      await prefs.setDouble('text_size_scale', settingsData['text_size_scale']?.toDouble() ?? 1.0);
      await prefs.setBool('is_dark_mode', settingsData['is_dark_mode'] ?? false);
      await prefs.setBool('high_contrast', settingsData['high_contrast'] ?? false);

    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
}