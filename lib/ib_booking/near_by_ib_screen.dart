import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:samagra/local_url.dart';

class NearbyIbsScreen extends StatefulWidget {
  const NearbyIbsScreen({Key? key}) : super(key: key);

  @override
  State<NearbyIbsScreen> createState() => _NearbyIbsScreenState();
}

class _NearbyIbsScreenState extends State<NearbyIbsScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '$localUrl/api'));
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _ibs = [];

  Future<void> _determinePositionAndFetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Request permissions if needed
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }
      if (perm == LocationPermission.deniedForever) {
        throw 'Location permissions permanently denied';
      }

      // 2. Get current position
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Fetch nearby IBs
      final resp = await _dio.get(
        '/ibbooking/ibs/nearby',
        queryParameters: {
          'lat': pos.latitude,
          'lng': pos.longitude,
        },
      );
      final data = List<Map<String, dynamic>>.from(resp.data);

      setState(() {
        _ibs = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _determinePositionAndFetch,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_ibs.isEmpty) {
      body = Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.my_location),
          label: const Text('Find IBs Near Me'),
          onPressed: _determinePositionAndFetch,
        ),
      );
    } else {
      body = ListView.separated(
        itemCount: _ibs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ib = _ibs[index];
          final name = ib['name'] as String? ?? 'Unknown IB';
          final distance = (ib['distance'] as num?)?.toDouble() ?? 0.0;
          return ListTile(
            title: Text(name),
            subtitle: Text('${distance.toStringAsFixed(2)} km away'),
            onTap: () {
              // navigate to details or booking screen
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('IBs Near Me')),
      body: body,
    );
  }
}
