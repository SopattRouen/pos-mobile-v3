// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:flutter_device_type/flutter_device_type.dart';


Color appBarColor = Colors.grey;

String passwordMatch = "";
// String mainUrlApi = "http://localhost:3000/api/";
String mainUrlApi = "https://calendar-api.dev.camcyber.com/api/";
// String mainUrlApi    =   "http://192.168.152.138:8000/api/";
// String mainUrlFile = "http://127.0.0.1:8003/";
String mainUrlFile = "https://pos-v2-file.uat.camcyber.com/";
String mainUrlAI = 'http://127.0.0.1:8085/api/';
// String mainUrlApi = "https://pos-v2-api.uat.camcyber.com/api/";
// String mainUrlApi = "https://api.sophat123.online/api/";
// String mainUrlFile = "https://file.sophat123.online/";
double iconSize = 30;

double mainWidth = 0;
double mainHeight = 0;
double textBoxHeight = 0.16;
double textboxPadding = 0.030;
double wPaddingAll = 0.025;
double iPadSize = 1;
bool isOffline = false;
bool isIpad = Device.get().isTablet;
