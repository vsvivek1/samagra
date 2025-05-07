import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopicDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> topic;

  const TopicDetailsScreen({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulated answers data (ideally fetched from backend using topicId)
    List<Map<String, dynamic>> allAnswers = [
      {
        'topicId': 't1',
        'answer': 'Use Provider or Riverpod for scalable state management.',
        'answeredBy': 'Alice',
        'time': DateTime.now().subtract(Duration(hours: 2)),
        'upvotes': 20,
        'downvotes': 2,
      },
      {
        'topicId': 't1',
        'answer': 'Bloc is best for event-driven architecture.',
        'answeredBy': 'Bob',
        'time': DateTime.now().subtract(Duration(hours: 4)),
        'upvotes': 15,
        'downvotes': 3,
      },
      {
        'topicId': 't2',
        'answer': 'Firebase is a quick and scalable option.',
        'answeredBy': 'Carol',
        'time': DateTime.now().subtract(Duration(hours: 1)),
        'upvotes': 5,
        'downvotes': 0,
      },
    ];

    // Filter answers for this topic
    List<Map<String, dynamic>> topicAnswers = allAnswers
        .where((a) => a['topicId'] == topic['topicId'])
        .toList();

    // Sort by upvotes descending
    topicAnswers.sort((a, b) => b['upvotes'].compareTo(a['upvotes']));

    return Scaffold(
      appBar: AppBar(
        title: Text(topic['name']),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: topicAnswers.isEmpty
            ? Center(child: Text("No answers yet for this topic."))
            : ListView.builder(
                itemCount: topicAnswers.length,
                itemBuilder: (context, index) {
                  final answer = topicAnswers[index];
                  final isTopAnswer = index == 0;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isTopAnswer ? Colors.amber[50] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isTopAnswer)
                            Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    color: Colors.amber[800]),
                                SizedBox(width: 6),
                                Text(
                                  'Top Answer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800]),
                                ),
                              ],
                            ),
                          if (isTopAnswer) SizedBox(height: 8),
                          Text(
                            answer['answer'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.person, size: 16),
                              SizedBox(width: 4),
                              Text(answer['answeredBy']),
                              SizedBox(width: 12),
                              Icon(Icons.access_time, size: 16),
                              SizedBox(width: 4),
                              Text(DateFormat('MMM d, h:mm a')
                                  .format(answer['time'])),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.thumb_up_alt, size: 16),
                              SizedBox(width: 4),
                              Text('${answer['upvotes']}'),
                              SizedBox(width: 16),
                              Icon(Icons.thumb_down_alt, size: 16),
                              SizedBox(width: 4),
                              Text('${answer['downvotes']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
