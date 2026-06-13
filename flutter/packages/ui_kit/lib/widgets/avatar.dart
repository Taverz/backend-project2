import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.url, this.size = 40, this.initials});

  final String? url;
  final double size;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Text(
              (initials ?? '?').substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: size * 0.4),
            )
          : null,
    );
  }
}
