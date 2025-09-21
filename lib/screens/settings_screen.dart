import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/course_provider.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Display Preferences',
                children: [
                  _buildSwitchTile(
                    title: 'Show Overall Progress',
                    subtitle: 'Display aggregate progress across all courses',
                    value: settings.showOverallProgress,
                    onChanged: (value) => settings.setShowOverallProgress(value),
                    icon: Icons.trending_up,
                  ),
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme for better night viewing',
                    value: settings.isDarkMode,
                    onChanged: (value) => settings.setDarkMode(value),
                    icon: Icons.dark_mode,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Accessibility',
                children: [
                  _buildSwitchTile(
                    title: 'High Contrast',
                    subtitle: 'Improve visibility with enhanced contrast',
                    value: settings.highContrast,
                    onChanged: (value) => settings.setHighContrast(value),
                    icon: Icons.contrast,
                  ),
                  _buildSliderTile(
                    title: 'Text Size',
                    subtitle: 'Adjust text size for better readability',
                    value: settings.textSizeScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    onChanged: (value) => settings.setTextSizeScale(value),
                    icon: Icons.text_fields,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Data Management',
                children: [
                  _buildActionTile(
                    title: 'Export Data',
                    subtitle: 'Save all your data to a backup file',
                    icon: Icons.download,
                    onTap: () => _exportData(context),
                  ),
                  const Divider(height: 1),
                  _buildActionTile(
                    title: 'Import Data',
                    subtitle: 'Restore data from a backup file',
                    icon: Icons.upload,
                    onTap: () => _importData(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildActionButton(
                title: 'Reset to Defaults',
                subtitle: 'Restore all settings to their default values',
                icon: Icons.restore,
                onTap: () => _showResetDialog(context, settings),
              ),
              const SizedBox(height: 24),
              _buildInfoSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(value * 100).round()}%'),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                const Text(
                  'StudyFlow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'A minimalistic task manager designed for college students to track course progress, manage assignments, and schedule study sessions.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              settings.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
        ),
      );

      final backupService = BackupService();
      final exportData = await backupService.exportAllData();
      final filePath = await backupService.saveExportToFile(exportData);

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your data has been exported successfully!'),
              const SizedBox(height: 12),
              Text(
                'File saved to: $filePath',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                'Total: ${exportData['metadata']['total_courses']} courses, ${exportData['metadata']['total_assignments']} assignments, ${exportData['metadata']['total_projects']} projects, ${exportData['metadata']['total_lectures']} lectures',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      if (context.mounted) Navigator.pop(context);

      // Show error dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Failed'),
          content: Text('Failed to export data: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Show confirmation dialog first
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text(
            'This will replace ALL your current data with the data from the backup file. This action cannot be undone.\n\nAre you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final backupService = BackupService();
      final filePath = await backupService.pickImportFile();

      if (filePath == null) {
        // User cancelled file picker
        return;
      }

      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Importing data...'),
            ],
          ),
        ),
      );

      final importData = await backupService.loadImportData(filePath);
      await backupService.importAllData(importData);

      // Reload providers
      if (!context.mounted) return;
      final courseProvider = context.read<CourseProvider>();
      final settingsProvider = context.read<SettingsProvider>();

      await courseProvider.loadCourses();
      await settingsProvider.loadSettings();

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your data has been imported successfully!'),
              const SizedBox(height: 12),
              Text(
                'Imported: ${importData['metadata']['total_courses']} courses, ${importData['metadata']['total_assignments']} assignments, ${importData['metadata']['total_projects']} projects, ${importData['metadata']['total_lectures']} lectures',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      if (context.mounted) Navigator.pop(context);

      // Show error dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Failed'),
          content: Text('Failed to import data: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}