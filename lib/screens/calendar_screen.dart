import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/course_provider.dart';
import '../models/course.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: const Icon(Icons.today),
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          final events = _getEventsForDay(_selectedDay, courseProvider);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8.0),
                child: TableCalendar<dynamic>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day, courseProvider),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red.shade600),
                    holidayTextStyle: TextStyle(color: Colors.red.shade600),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(),
              ),
              Expanded(
                child: events.isEmpty
                    ? _buildEmptyState()
                    : _buildEventsList(events, courseProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime? day, CourseProvider courseProvider) {
    if (day == null) return [];

    final events = <dynamic>[];

    for (final course in courseProvider.courses) {
      // Skip lectures as they don't have deadlines

      // Add assignment deadlines
      for (final assignment in course.assignments) {
        if (assignment.deadline != null && isSameDay(assignment.deadline!, day)) {
          events.add({
            'type': 'assignment_deadline',
            'item': assignment,
            'course': course,
          });
        }
      }

      // Add project deadlines
      for (final project in course.projects) {
        if (project.deadline != null && isSameDay(project.deadline!, day)) {
          events.add({
            'type': 'project_deadline',
            'item': project,
            'course': course,
          });
        }
      }

      // Study sessions removed
    }

    // Sort events by time
    events.sort((a, b) {
      final timeA = _getEventTime(a);
      final timeB = _getEventTime(b);
      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;
      return timeA.compareTo(timeB);
    });

    return events;
  }

  DateTime? _getEventTime(Map<String, dynamic> event) {
    switch (event['type'] as String) {
      case 'assignment_deadline':
        return (event['item'] as Assignment).deadline;
      case 'project_deadline':
        return (event['item'] as Project).deadline;
      default:
        return null;
    }
  }


  Widget _buildEmptyState() {
    final selectedDate = _selectedDay != null
        ? DateFormat('EEEE, MMMM d, y').format(_selectedDay!)
        : 'Selected Date';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No events for $selectedDate',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you have a free day!',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<dynamic> events, CourseProvider courseProvider) {
    final selectedDate = _selectedDay != null
        ? DateFormat('EEEE, MMMM d, y').format(_selectedDay!)
        : 'Selected Date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            selectedDate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event, courseProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, CourseProvider courseProvider) {
    final type = event['type'] as String;
    final course = event['course'] as Course;
    final item = event['item'];
    final eventTime = _getEventTime(event);

    IconData icon;
    Color color;
    String title;
    String courseTitle;
    String timeText;
    String statusText;
    bool isCompleted = false;
    bool isOverdue = false;
    VoidCallback? onTap;
    VoidCallback? onReschedule;

    switch (type) {
      case 'assignment_deadline':
        final assignment = item as Assignment;
        icon = Icons.assignment;
        color = Colors.orange;
        title = assignment.title;
        courseTitle = course.title;
        timeText = eventTime != null ? DateFormat('h:mm a').format(eventTime) : 'No time';
        statusText = assignment.completed ? 'Completed' : 'Due';
        isCompleted = assignment.completed;
        isOverdue = eventTime != null && eventTime.isBefore(DateTime.now()) && !isCompleted;
        break;
      case 'project_deadline':
        final project = item as Project;
        icon = Icons.work;
        color = Colors.red;
        title = project.title;
        courseTitle = course.title;
        timeText = eventTime != null ? DateFormat('h:mm a').format(eventTime) : 'No time';
        statusText = project.isCompleted ? 'Completed' : 'Due';
        isCompleted = project.isCompleted;
        isOverdue = eventTime != null && eventTime.isBefore(DateTime.now()) && !isCompleted;
        break;
      default:
        return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : isOverdue
                          ? Colors.red.withOpacity(0.1)
                          : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green
                        : isOverdue
                            ? Colors.red
                            : color,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : icon,
                  color: isCompleted
                      ? Colors.green
                      : isOverdue
                          ? Colors.red
                          : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseTitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Time and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : isOverdue
                              ? Colors.red.withOpacity(0.1)
                              : theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      timeText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? Colors.green.shade700
                            : isOverdue
                                ? Colors.red.shade700
                                : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? Colors.green.shade600
                          : isOverdue
                              ? Colors.red.shade600
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Quick Actions
              if (onReschedule != null || !isCompleted) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'reschedule':
                        onReschedule?.call();
                        break;
                      case 'toggle':
                        onTap?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onReschedule != null)
                      const PopupMenuItem(
                        value: 'reschedule',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 18),
                            SizedBox(width: 8),
                            Text('Reschedule'),
                          ],
                        ),
                      ),
                    if (onTap != null)
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.undo : Icons.check,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}