import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'movie_server_controller.dart';

class MovieServerScreen extends StatelessWidget {
  const MovieServerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MovieServerController());

    return Scaffold(
      appBar: AppBar(title: const Text('Movie Servers')),
      body: RefreshIndicator(
        onRefresh: controller.fetchServers,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Error: ${controller.errorMessage.value}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.fetchServers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (controller.servers.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No servers found')),
              ],
            );
          }

          // Grid view with 2 columns for better visual UX
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: controller.servers.length,
            itemBuilder: (context, index) {
              final s = controller.servers[index];
              return GestureDetector(
                onTap: () => controller.openUrl(s.url),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image header
                      SizedBox(
                        height: 110,
                        child:
                            s.image.isNotEmpty
                                ? Image.network(
                                  "https://isppaybd.com/assets/movies/${s.image}",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                                : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.movie,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (s.details.isNotEmpty)
                              Text(
                                s.details,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.rating,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.createdAt,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
