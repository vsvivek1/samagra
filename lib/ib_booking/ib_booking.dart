import 'package:flutter/material.dart';

class IbBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IB Booking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Action for Vacancy by Ib button
                // Add your logic here
              },
              child: Text('Vacancy by Ib'),
            ),
            ElevatedButton(
              onPressed: () {
                // Action for Vacancy by Date button
                // Add your logic here
              },
              child: Text('Vacancy by Date'),
            ),
            ElevatedButton(
              onPressed: () {
                // Action for Book Ib button
                // Add your logic here
              },
              child: Text('Book Ib'),
            ),
            ElevatedButton(
              onPressed: () {
                // Action for Admin Actions button
                // Add your logic here
              },
              child: Text('Admin Actions'),
            ),
          ],
        ),
      ),
    );
  }
}
