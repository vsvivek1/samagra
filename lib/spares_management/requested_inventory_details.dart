import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';

class RequestedInventoryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> inventory;

  RequestedInventoryDetailsPage({required this.inventory});

  @override
  _RequestedInventoryDetailsPageState createState() =>
      _RequestedInventoryDetailsPageState();
}

class _RequestedInventoryDetailsPageState
    extends State<RequestedInventoryDetailsPage> {
  final Dio dio = Dio();
  List<dynamic> interestedPeople = [];
  List<dynamic> comments = [];
  TextEditingController commentController = TextEditingController();
  bool isLoadingInterest = true;
  bool isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    fetchInterestedPeople();
    fetchComments();
  }

  Future<void> fetchInterestedPeople() async {
    try {
      String apiUrl =
          'http://192.168.100.106:8000/api/requested_inventories/${widget.inventory['id']}/interested';
      final response = await dio.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          interestedPeople = response.data;
          isLoadingInterest = false;
        });
      } else {
        throw Exception('Failed to load interested people');
      }
    } catch (e) {
      setState(() {
        isLoadingInterest = false;
      });
    }
  }

  Future<void> fetchComments() async {
    try {
      String commentsUrl =
          'http://192.168.100.106:8000/api/requested_inventories/${widget.inventory['id']}/comments';
      final response = await dio.get(commentsUrl);

      if (response.statusCode == 200) {
        setState(() {
          comments = response.data;
          isLoadingComments = false;
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      setState(() {
        isLoadingComments = false;
      });
    }
  }

  Future<void> expressInterest() async {
    try {
      String interestUrl =
          'http://192.168.100.106:8000/api/requested_inventories/${widget.inventory['id']}/express-interest';
      final response = await dio.post(interestUrl);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Interest expressed successfully')),
        );
        fetchInterestedPeople(); // Refresh the list of interested people
      } else {
        throw Exception('Failed to express interest');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to express interest')),
      );
    }
  }

  Future<void> submitComment() async {
    if (commentController.text.trim().isEmpty) return;
    try {
      String commentsUrl =
          'http://192.168.100.106:8000/api/requested_inventories/${widget.inventory['id']}/comments';
      final response = await dio.post(
        commentsUrl,
        data: {'comment': commentController.text.trim()},
      );

      if (response.statusCode == 200) {
        setState(() {
          comments.add(response.data);
          commentController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment added successfully')),
        );
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = widget.inventory['images'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inventory['inventory_name'] ?? 'Inventory Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              images.length > 1
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                      ),
                      items: images.map((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            final String imageUrl = image['asset_url'] ?? '';
                            return imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Icon(Icons.image, size: 100);
                          },
                        );
                      }).toList(),
                    )
                  : Image.network(
                      images[0]['asset_url'],
                      height: 200.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
            else
              Icon(Icons.image, size: 100),
            SizedBox(height: 20),
            Text(
              'Name: ${widget.inventory['inventory_name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Location: ${widget.inventory['location'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: expressInterest,
              child: Text('Express Interest'),
            ),
            SizedBox(height: 20),
            if (isLoadingInterest)
              CircularProgressIndicator()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interested People:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...interestedPeople.map((person) {
                    return ListTile(
                      title: Text(person['name']),
                      subtitle: Text('Contact: ${person['contact']}'),
                    );
                  }).toList(),
                ],
              ),
            SizedBox(height: 20),
            Text(
              'Comments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: submitComment,
                ),
              ),
            ),
            SizedBox(height: 10),
            if (isLoadingComments)
              CircularProgressIndicator()
            else
              ...comments.map((comment) {
                return ListTile(
                  title: Text(comment['comment']),
                  subtitle: Text('By: ${comment['user_name'] ?? 'Unknown'}'),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
