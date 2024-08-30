import 'package:flutter/material.dart';

void main() {
  runApp(FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizFlash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Flashcard> flashcards = [];

  void _startQuiz(String subject) {
    final subjectFlashcards = flashcards
        .where((flashcard) => flashcard.subject == subject)
        .toList();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QuizModeScreen(flashcards: subjectFlashcards),
    ));
  }

  void _showFlashcardDetail(Flashcard flashcard) {
    final subjectFlashcards = flashcards
        .where((fc) => fc.subject == flashcard.subject)
        .toList();
    final initialIndex = subjectFlashcards.indexOf(flashcard);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(flashcard.subject),
        content: Container(
          height: 300,
          width: double.maxFinite,
          child: PageView.builder(
            itemCount: subjectFlashcards.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              final currentFlashcard = subjectFlashcards[index];
              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentFlashcard.question,
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      currentFlashcard.answer,
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Edit'),
            onPressed: () {
              Navigator.of(context).pop();
              _showEditFlashcardDialog(flashcard);
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteFlashcard(flashcard);
            },
          ),
          TextButton(
            child: Text('Quiz Mode'),
            onPressed: () {
              Navigator.of(context).pop();
              _startQuiz(flashcard.subject);
            },
          ),
        ],
      ),
    );
  }

  void _showEditFlashcardDialog(Flashcard flashcard) {
    String subject = flashcard.subject;
    String question = flashcard.question;
    String answer = flashcard.answer;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Question'),
              controller: TextEditingController(text: question),
              onChanged: (value) => question = value,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Answer'),
              controller: TextEditingController(text: answer),
              onChanged: (value) => answer = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              setState(() {
                flashcard.question = question;
                flashcard.answer = answer;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAddFlashcardDialog({String? prefilledSubject}) {
    String subject = prefilledSubject ?? '';
    String question = '';
    String answer = '';
    String newSubject = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Flashcard'),
        content: Container(
          height: 200,
          width: 200,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subject.isEmpty)
                  DropdownButtonFormField<String>(
                    hint: Text('Select Subject'),
                    items: flashcards
                        .map((flashcard) => flashcard.subject)
                        .toSet()
                        .map((subject) => DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    ))
                        .toList(),
                    onChanged: (value) {
                      subject = value ?? '';
                    },
                  ),
                if (subject.isEmpty)
                  TextField(
                    decoration: InputDecoration(hintText: 'Or Add New Subject'),
                    onChanged: (value) => newSubject = value,
                  ),
                TextField(
                  decoration: InputDecoration(hintText: 'Question'),
                  maxLines: null,
                  onChanged: (value) => question = value,
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Answer'),
                  maxLines: null,
                  onChanged: (value) => answer = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              setState(() {
                flashcards.add(Flashcard(
                  subject: newSubject.isNotEmpty ? newSubject : subject,
                  question: question,
                  answer: answer,
                ));
              });
              Navigator.of(context).pop();

              // Show Snackbar with "Flashcard added" message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Flashcard added'),
                  duration: Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFlashcard(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              setState(() {
                flashcards.remove(flashcard);
              });
              Navigator.of(context).pop();

              // Show Snackbar with "Flashcard deleted" message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Flashcard deleted'),
                  duration: Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Flashcard>> flashcardsBySubject = {};

    for (var flashcard in flashcards) {
      if (!flashcardsBySubject.containsKey(flashcard.subject)) {
        flashcardsBySubject[flashcard.subject] = [];
      }
      flashcardsBySubject[flashcard.subject]!.add(flashcard);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('QuizFlash'),
      ),
      body: flashcardsBySubject.isEmpty
          ? Center(child: Text('No flashcards available.'))
          : ListView(
        children: flashcardsBySubject.keys.map((subject) {
          return ExpansionTile(
            title: Text(subject),
            children: [
              ...flashcardsBySubject[subject]!
                  .map((flashcard) => ListTile(
                title: Text(flashcard.question),
                onTap: () => _showFlashcardDetail(flashcard),
              ))
                  .toList(),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Add Flashcard'),
                onTap: () =>
                    _showAddFlashcardDialog(prefilledSubject: subject),
              ),
              ListTile(
                leading: Icon(Icons.quiz),
                title: Text('Start Quiz'),
                onTap: () => _startQuiz(subject),
              ),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddFlashcardDialog,
      ),
    );
  }
}


class Flashcard {
  String subject;
  String question;
  String answer;

  Flashcard({required this.subject, required this.question, required this.answer});
}

class QuizModeScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  QuizModeScreen({required this.flashcards});

  @override
  _QuizModeScreenState createState() => _QuizModeScreenState();
}

class _QuizModeScreenState extends State<QuizModeScreen> {
  late List<Flashcard> _shuffledFlashcards;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  bool _showResult = false;
  bool _isCorrect = false;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shuffledFlashcards = List.from(widget.flashcards)..shuffle();
  }

  void _checkAnswer() {
    setState(() {
      _showResult = true;
      String userAnswer = _answerController.text.trim().toLowerCase();
      String correctAnswer = _shuffledFlashcards[_currentIndex].answer.trim().toLowerCase();
      _isCorrect = userAnswer == correctAnswer;
      if (_isCorrect) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _showResult = false;
      _answerController.clear(); // Clear the text field
      if (_currentIndex >= _shuffledFlashcards.length) {
        _showScore();
        _currentIndex = _shuffledFlashcards.length - 1; // Ensure index doesn't go out of bounds
      }
    });
  }

  void _showScore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Completed'),
        content: Text(
          'You answered $_correctAnswers out of ${_shuffledFlashcards.length} questions correctly.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledFlashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz Mode'),
        ),
        body: Center(
          child: Text('No flashcards available for this subject.'),
        ),
      );
    }

    final currentIndex = _currentIndex.clamp(0, _shuffledFlashcards.length - 1);
    final currentFlashcard = _shuffledFlashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Mode'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${currentIndex + 1} of ${_shuffledFlashcards.length}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              currentFlashcard.question,
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Optional: Use this if you want to update something on text change
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Submit Answer'),
            ),
            if (_showResult) ...[
              SizedBox(height: 20),
              Text(
                _isCorrect ? 'Correct!' : 'Incorrect!',
                style: TextStyle(
                  fontSize: 24,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Correct Answer: ${currentFlashcard.answer}',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentIndex + 1 < _shuffledFlashcards.length ? 'Next Question' : 'Finish Quiz',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
