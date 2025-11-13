import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ispapp/core/config/constants/api.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieServerScreen extends StatefulWidget {
  const MovieServerScreen({super.key});

  @override
  State<MovieServerScreen> createState() => _MovieServerScreenState();
}

class _MovieServerScreenState extends State<MovieServerScreen> {
  final Dio _dio = Dio();
  bool _loading = true;
  String? _error;
  List<MovieServer> _servers = [];

  @override
  void initState() {
    super.initState();
    _fetchServers();
  }

  Future<void> _fetchServers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = '${AppApi.baseUrl}movieservers';

    try {
      final resp = await _dio.get(url);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = resp.data;
        if (data is Map &&
            data['status'] == 'success' &&
            data['data'] is List) {
          final list =
              (data['data'] as List)
                  .map((e) => MovieServer.fromJson(e as Map<String, dynamic>))
                  .toList();
          setState(() {
            _servers = list;
          });
        } else {
          setState(() {
            _error = 'Unexpected response format';
          });
        }
      } else {
        setState(() {
          _error = 'HTTP \\${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching URL: \\$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Servers')),
      body: RefreshIndicator(
        onRefresh: _fetchServers,
        child: Builder(
          builder: (context) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Error: \\${_error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetchServers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (_servers.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No servers found')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _servers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = _servers[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(s.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (s.details.isNotEmpty) Text(s.details),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(s.rating),
                            const SizedBox(width: 12),
                            Text(s.createdAt),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _openUrl(s.url),
                    ),
                    onTap: () => _openUrl(s.url),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MovieServer {
  final String id;
  final String name;
  final String url;
  final String details;
  final String rating;
  final String createdAt;

  MovieServer({
    required this.id,
    required this.name,
    required this.url,
    required this.details,
    required this.rating,
    required this.createdAt,
  });

  factory MovieServer.fromJson(Map<String, dynamic> json) {
    return MovieServer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
