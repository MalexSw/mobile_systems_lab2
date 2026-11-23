import 'dart:io';

/// A single mood entry.
class MoodEntry {
  final DateTime createdAt;
  final int score; // 1-10
  final String? note; // null when the user wrote nothing

  MoodEntry({required this.createdAt, required this.score, this.note});

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  String toString() {
    final date =
        '${createdAt.year}-${_two(createdAt.month)}-${_two(createdAt.day)}';
    final time = '${_two(createdAt.hour)}:${_two(createdAt.minute)}';
    return '[$date $time] Score: $score/10 - ${note ?? '(no note)'}';
  }
}

/// Stores entries and provides queries over them.
class MoodLogger {
  final List<MoodEntry> _entries = [];

  /// Adds an entry with the current time.
  /// Returns true if added, false if the score was rejected.
  bool addEntry(int score, String? note) {
    if (score < 1 || score > 10) {
      print('Error: score must be between 1 and 10.');
      return false;
    }

    final trimmed = note?.trim();
    final cleanNote = (trimmed == null || trimmed.isEmpty) ? null : trimmed;

    _entries.add(
      MoodEntry(createdAt: DateTime.now(), score: score, note: cleanNote),
    );
    return true;
  }

  List<MoodEntry> getAllEntries() => List.unmodifiable(_entries);

  /// Average score, or null when there are no entries.
  double? getAverageScore() {
    if (_entries.isEmpty) return null;
    final total = _entries.fold<int>(0, (sum, e) => sum + e.score);
    return total / _entries.length;
  }

  /// Entries with a score at or above [threshold].
  List<MoodEntry> getEntriesAbove(int threshold) {
    return _entries.where((e) => e.score >= threshold).toList();
  }
}

void printMenu() {
  print('');
  print('=== Mood Logger ===');
  print('1. Add mood entry');
  print('2. View all entries');
  print('3. View average mood');
  print('4. Filter by minimum score');
  print('5. Quit');
  print('');
}

/// Prompts the user and returns the trimmed line, or null on end of input.
String? prompt(String message) {
  stdout.write(message);
  return stdin.readLineSync();
}

void main() {
  final logger = MoodLogger();

  while (true) {
    printMenu();
    final choice = prompt('Choose an option: ');

    // null means input ended (e.g. Ctrl+D), so quit gracefully.
    if (choice == null) {
      print('\nGoodbye!');
      break;
    }

    switch (choice.trim()) {
      case '1':
        final score = int.tryParse(prompt('Enter mood score (1-10): ') ?? '');
        if (score == null) {
          print('Error: please enter a whole number.');
          break;
        }
        final note = prompt('Enter a note (or press Enter for none): ');
        if (logger.addEntry(score, note)) {
          print('Entry added!');
        }
        break;

      case '2':
        final entries = logger.getAllEntries();
        if (entries.isEmpty) {
          print('No entries yet. Add some entries first!');
        } else {
          for (final entry in entries) {
            print(entry);
          }
        }
        break;

      case '3':
        final average = logger.getAverageScore();
        if (average == null) {
          print('No entries yet. Add some entries first!');
        } else {
          final count = logger.getAllEntries().length;
          final word = count == 1 ? 'entry' : 'entries';
          print(
            'Average mood score: ${average.toStringAsFixed(1)} '
            '(based on $count $word)',
          );
        }
        break;

      case '4':
        final threshold =
            int.tryParse(prompt('Enter minimum score (1-10): ') ?? '');
        if (threshold == null) {
          print('Error: please enter a whole number.');
          break;
        }
        final matches = logger.getEntriesAbove(threshold);
        if (matches.isEmpty) {
          print('No entries with a score of $threshold or higher.');
        } else {
          for (final entry in matches) {
            print(entry);
          }
        }
        break;

      case '5':
        print('Goodbye!');
        return;

      default:
        print('Invalid option. Please choose 1-5.');
    }
  }
}