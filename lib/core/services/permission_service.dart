import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/widgets/common/zuno_loader.dart';
import '../routes/app_routes.dart';

class PermissionServiceScreen extends StatefulWidget {
  const PermissionServiceScreen({super.key});

  @override
  State<PermissionServiceScreen> createState() => _PermissionServiceScreenState();
}

class _PermissionServiceScreenState extends State<PermissionServiceScreen> {
  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
  }

  Future<void> _handleLocationPermission() async {
    // First check current status
    final status = await Permission.location.status;

    if (status.isGranted) {
      _goToSplash();
      return;
    }

    // If not granted, request it (this will show the native system dialog)
    final requestedStatus = await Permission.location.request();

    if (requestedStatus.isGranted) {
      _goToSplash();
    } else {
    }
  }

  void _goToSplash() {
    Get.offAllNamed(Routes.SPLASH);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: ZunoLoader(isVisible: true),
    );
  }
}