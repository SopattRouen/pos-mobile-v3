// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/network_provider.dart';
import 'package:provider/provider.dart';

class NetworkMiddleware extends StatefulWidget {
  final Widget child;
  const NetworkMiddleware({super.key, required this.child});

  @override
  State<NetworkMiddleware> createState() => _NetworkMiddlewareState();
}

class _NetworkMiddlewareState extends State<NetworkMiddleware> {
  bool _wasDisconnected = false;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void _showNoConnectionSnackBar() {
    _scaffoldMessenger?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No Internet Connection",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Check your connection and try again",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        duration: Duration(days: 1), // Persist until manually dismissed
        behavior: SnackBarBehavior.floating,
        
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top + 10, 
          left: 16, 
          right: 16
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        action: SnackBarAction(
          label: "Retry",
          textColor: Colors.white,
          onPressed: () {
            Provider.of<NetworkProvider>(context, listen: false).checkConnection();
          },
        ),
      ),
    );
  }

  void _showConnectionRestoredSnackBar() {
    _scaffoldMessenger?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              "Connection restored",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top + 10, 
          left: 16, 
          right: 16
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, network,  _) {
        // Handle connection state changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!network.isConnected && !_wasDisconnected) {
            // Connection lost
            _wasDisconnected = true;
            _showNoConnectionSnackBar();
          } else if (network.isConnected && _wasDisconnected) {
            // Connection restored
            _wasDisconnected = false;
            _scaffoldMessenger?.hideCurrentSnackBar();
            _showConnectionRestoredSnackBar();
          }
        });

        // If no connection, overlay the child with a blocking layer
        if (!network.isConnected) {
          return Stack(
            children: [
              // Original child widget
              widget.child,
              // Blocking overlay
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: AbsorbPointer(
                    absorbing: true,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return widget.child;
      },
    );
  }
}