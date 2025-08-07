// =======================>> Flutter Core
import 'package:flutter/material.dart';

void showCustomBottomSheet({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  Color? backgroundColor,
  ShapeBorder? shape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
  ),
  Color? barrierColor,
  bool enableDrag = true,
  double? elevation,
  bool isDismissible = true,
  bool? showDragHandle,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: backgroundColor ?? Colors.white,
    shape: shape,
    barrierColor: barrierColor,
    enableDrag: enableDrag,
    elevation: elevation ?? 8.0,
    isDismissible: isDismissible,

    builder: (context) {
      return SafeArea(top: false, child: builder(context));
    },
  );
}
