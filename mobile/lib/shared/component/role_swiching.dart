import 'package:calendar/providers/global/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class RoleSwitcherDialog extends StatelessWidget {
  const RoleSwitcherDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final lang = Provider.of<SettingProvider>(context).lang;

    return AlertDialog(
      title: Text('switch_role'),
      content: FutureBuilder<List<dynamic>?>(
        future: authProvider.getAllRoles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('no_roles_available');
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: snapshot.data!.map((role) {
                return FutureBuilder<Map<String, dynamic>?>(
                  future: authProvider.getCurrentRole(),
                  builder: (context, currentRoleSnapshot) {
                    final isCurrent = currentRoleSnapshot.data?['slug'] == role['slug'];
                    return ListTile(
                      title: Text(role['name'] ?? ''),
                      trailing: isCurrent 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () async {
                        if (!isCurrent) {
                          await authProvider.switchRole(role);
                          Navigator.of(context).pop();
                          // You might want to refresh the UI here
                        }
                      },
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'),
        ),
      ],
    );
  }
}