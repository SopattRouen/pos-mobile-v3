// =======================>> Dart Core
import 'dart:io';

// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Shared Components
import 'package:calendar/shared/entity/enum/e_variable.dart';


class SafeCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackAsset;

  const SafeCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    required this.fallbackAsset,
  });

  Future<bool> _canLoadNetworkImage(String url) async {
    try {
      final response = await HttpClient().headUrl(Uri.parse(url));
      final result = await response.close();
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullUrl = imageUrl?.isNotEmpty == true ? "$mainUrlFile$imageUrl" : "";

    if (fullUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(fallbackAsset),
      );
    }

    return FutureBuilder<bool>(
      future: _canLoadNetworkImage(fullUrl),
      builder: (context, snapshot) {
        final hasImage = snapshot.data ?? false;

        return CircleAvatar(
          radius: radius,
          backgroundImage: hasImage
              ? NetworkImage(fullUrl)
              : AssetImage(fallbackAsset) as ImageProvider,
        );
      },
    );
  }
}
