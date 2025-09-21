enum LecturePhaseStatus {
  notStarted,
  todoRead,
  understoodPracticed,
  finalized,
  completed,
}

class Course {
  final String id;
  final String title;
  final String description;
  final String color;
  final String semester;
  final int credits;
  final List<Lecture> lectures;
  final List<Project> projects;
  final List<Assignment> assignments;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.semester,
    required this.credits,
    this.lectures = const [],
    this.projects = const [],
    this.assignments = const [],
  });

  double get progress {
    final totalTasks = lectures.length + projects.length + assignments.length;
    if (totalTasks == 0) return 0.0;

    final completedLectures = lectures.where((l) => l.isCompleted).length;
    final completedProjects = projects.where((p) => p.isCompleted).length;
    final completedAssignments = assignments.where((a) => a.completed).length;

    final completedTasks = completedLectures + completedProjects + completedAssignments;
    return (completedTasks / totalTasks) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'semester': semester,
      'credits': credits,
      'lectures': lectures.map((l) => l.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      color: json['color'],
      semester: json['semester'],
      credits: json['credits'],
      lectures: (json['lectures'] as List<dynamic>?)
          ?.map((l) => Lecture.fromJson(l))
          .toList() ?? [],
      projects: (json['projects'] as List<dynamic>?)
          ?.map((p) => Project.fromJson(p))
          .toList() ?? [],
      assignments: (json['assignments'] as List<dynamic>?)
          ?.map((a) => Assignment.fromJson(a))
          .toList() ?? [],
    );
  }

  Course copyWith({
    String? title,
    String? description,
    String? color,
    String? semester,
    int? credits,
    List<Lecture>? lectures,
    List<Project>? projects,
    List<Assignment>? assignments,
  }) {
    return Course(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      lectures: lectures ?? this.lectures,
      projects: projects ?? this.projects,
      assignments: assignments ?? this.assignments,
    );
  }
}

class Lecture {
  final String id;
  final String title;
  final List<LecturePhase> phases;
  final String? notes;

  Lecture({
    required this.id,
    required this.title,
    List<LecturePhase>? phases,
    this.notes,
  }) : phases = phases ?? _createDefaultPhases();

  static List<LecturePhase> _createDefaultPhases() {
    return [
      LecturePhase(
        id: 'todo_read',
        name: 'To-do / Read',
        completed: false,
        weight: 1.0,
      ),
      LecturePhase(
        id: 'understood_practiced',
        name: 'Understood & Practiced',
        completed: false,
        weight: 1.0,
      ),
      LecturePhase(
        id: 'finalized',
        name: 'Finalized',
        completed: false,
        weight: 1.0,
      ),
    ];
  }

  bool get isCompleted => phases.every((phase) => phase.completed);

  double get progress {
    if (phases.isEmpty) return 0.0;
    final completedWeight = phases
        .where((phase) => phase.completed)
        .fold(0.0, (sum, phase) => sum + phase.weight);
    final totalWeight = phases.fold(0.0, (sum, phase) => sum + phase.weight);
    return totalWeight > 0 ? (completedWeight / totalWeight) * 100 : 0.0;
  }

  LecturePhaseStatus get currentPhase {
    if (phases.isEmpty) return LecturePhaseStatus.notStarted;

    if (!phases[0].completed) return LecturePhaseStatus.todoRead;
    if (!phases[1].completed) return LecturePhaseStatus.understoodPracticed;
    if (!phases[2].completed) return LecturePhaseStatus.finalized;

    return LecturePhaseStatus.completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'phases': phases.map((p) => p.toJson()).toList(),
      'notes': notes,
    };
  }

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      phases: (json['phases'] as List<dynamic>?)
          ?.map((p) => LecturePhase.fromJson(p))
          .toList() ?? [],
      notes: json['notes'],
    );
  }
}

class LecturePhase {
  final String id;
  final String name;
  final bool completed;
  final double weight;

  LecturePhase({
    required this.id,
    required this.name,
    required this.completed,
    required this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'completed': completed,
      'weight': weight,
    };
  }

  factory LecturePhase.fromJson(Map<String, dynamic> json) {
    return LecturePhase(
      id: json['id'],
      name: json['name'],
      completed: json['completed'],
      weight: json['weight'].toDouble(),
    );
  }

  LecturePhase copyWith({
    bool? completed,
  }) {
    return LecturePhase(
      id: id,
      name: name,
      completed: completed ?? this.completed,
      weight: weight,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final List<Milestone> milestones;
  final DateTime? deadline;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.milestones,
    this.deadline,
  });

  bool get isCompleted => milestones.every((milestone) => milestone.completed);

  double get progress {
    if (milestones.isEmpty) return 0.0;
    final completedCount = milestones.where((m) => m.completed).length;
    return (completedCount / milestones.length) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'deadline': deadline?.millisecondsSinceEpoch,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      milestones: (json['milestones'] as List<dynamic>?)
          ?.map((m) => Milestone.fromJson(m))
          .toList() ?? [],
      deadline: json['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deadline'])
          : null,
    );
  }
}

class Milestone {
  final String id;
  final String title;
  final bool completed;
  final DateTime? deadline;

  Milestone({
    required this.id,
    required this.title,
    required this.completed,
    this.deadline,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'deadline': deadline?.millisecondsSinceEpoch,
    };
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
      deadline: json['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deadline'])
          : null,
    );
  }

  Milestone copyWith({
    bool? completed,
  }) {
    return Milestone(
      id: id,
      title: title,
      completed: completed ?? this.completed,
      deadline: deadline,
    );
  }
}

class Assignment {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final DateTime? deadline;
  final String priority;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    this.deadline,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'deadline': deadline?.millisecondsSinceEpoch,
      'priority': priority,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      deadline: json['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deadline'])
          : null,
      priority: json['priority'],
    );
  }

  Assignment copyWith({
    bool? completed,
  }) {
    return Assignment(
      id: id,
      title: title,
      description: description,
      completed: completed ?? this.completed,
      deadline: deadline,
      priority: priority,
    );
  }
}

