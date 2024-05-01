import 'dart:async';
import 'package:flutter/material.dart';
import '/models/questions.dart';
import '/screens/result_screen.dart';
import '/widgets/answer_card.dart';
import '/widgets/next_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key});

  @override
  State<StatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedAnswerIndex;
  int questionIndex = 0;
  int score = 0;
  late Timer _questionTimer;
  late Stopwatch _totalTimeStopwatch;
  late int _remainingTimeInSeconds;

  @override
  void initState() {
    super.initState();
    _totalTimeStopwatch = Stopwatch();
    _remainingTimeInSeconds = 15;
    startQuestionTimer();
  }

  @override
  void dispose() {
    _questionTimer.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  void startQuestionTimer() {
    _questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        setState(() {
          if (_remainingTimeInSeconds > 0) {
            _remainingTimeInSeconds--;
          } else {
            timer.cancel();
            goToNextQuestion();
          }
        });
      }
    });
  }

  void resetQuestionTimer() {
    _remainingTimeInSeconds = 15;
    _questionTimer.cancel();
    startQuestionTimer();
  }

  void goToNextQuestion() {
    if (questionIndex < questions.length - 1) {
      questionIndex++;
      selectedAnswerIndex = null;
      resetQuestionTimer();
      setState(() {});
    } else {
      _totalTimeStopwatch.stop();
      int totalTimeInSeconds = _totalTimeStopwatch.elapsed.inSeconds;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            totalTimeInSeconds: totalTimeInSeconds,
          ),
        ),
      );
    }
  }

  void pickAnswer(int value) {
    selectedAnswerIndex = value;
    final question = questions[questionIndex];
    if (selectedAnswerIndex == question.correctAnswerIndex) {
      score++;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[questionIndex];
    _totalTimeStopwatch.start();
    bool isLastQuestion = questionIndex == questions.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App for Class'),
        actions: [
          Text('Time: $_remainingTimeInSeconds'),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 21,
              ),
              textAlign: TextAlign.center,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: selectedAnswerIndex == null
                      ? () => pickAnswer(index)
                      : null,
                  child: AnswerCard(
                    currentIndex: index,
                    question: question.options[index],
                    isSelected: selectedAnswerIndex == index,
                    selectedAnswerIndex: selectedAnswerIndex,
                    correctAnswerIndex: question.correctAnswerIndex,
                  ),
                );
              },
            ),
            // Next Button
            isLastQuestion
                ? RectangularButton(
                    onPressed: () {
                      goToNextQuestion();
                    },
                    label: 'Finish',
                  )
                : RectangularButton(
                    onPressed:
                        selectedAnswerIndex != null ? goToNextQuestion : null,
                    label: 'Next',
                  ),
          ],
        ),
      ),
    );
  }
}
