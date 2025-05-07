import 'package:flutter/material.dart';
import 'package:samagra/Ask/topic_details_screen.dart';

class TopicsScreen extends StatefulWidget {
  @override
  _TopicsScreenState createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  List<Map<String, dynamic>> topics = [
    {
      'topicId': 't1',
      'name': 'Flutter State Management',
      'tags': ['Flutter', 'State'],
      'answers': 5,
      'views': 150,
      'likes': 42,
    },
    {
      'topicId': 't2',
      'name': 'Best Backend for Mobile Apps',
      'tags': ['Backend', 'Mobile'],
      'answers': 3,
      'views': 90,
      'likes': 25,
    },
    {
      'topicId': 't3',
      'name': 'Null Safety in Dart',
      'tags': ['Dart', 'NullSafety'],
      'answers': 2,
      'views': null, // Still works because of ?? 0
      'likes': 11,
    },
  ];

  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredTopics = topics
        .where((topic) =>
            topic['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Topics'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search topic...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  query = val;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.help_outline),
              label: Text("Ask New Doubt"),
              onPressed: () {
                // TODO: Navigate to Ask Doubt screen
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    title: Text(
                      topic['name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: topic['tags'].map<Widget>((tag) {
                            return GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Clicked on #$tag')),
                                );
                              },
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.question_answer, size: 16),
                            SizedBox(width: 4),
                            Text('Answers: ${topic['answers'] ?? 0}'),
                            SizedBox(width: 12),
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 4),
                            Text('Views: ${topic['views'] ?? 0}'),
                            SizedBox(width: 12),
                            Icon(Icons.thumb_up, size: 16),
                            SizedBox(width: 4),
                            Text('Likes: ${topic['likes'] ?? 0}'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicDetailsScreen(topic: topic),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
