import 'package:flutter/material.dart';

enum DialogType {
  primary,
  danger,
}

Future<bool> showConfirmDialog(
  BuildContext context,
  String title,
  String message,
  DialogType type,
  Future<void> Function() onConfirm,
) async {
  bool confirmed = false;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "បោះបង់",
                            style: TextStyle(
                              color: isLoading ? Colors.grey : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        onTap: isLoading
                            ? null
                            : () async {
                                setState(() => isLoading = true);
                                try {
                                  await onConfirm();
                                  confirmed = true;
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  confirmed = false;
                                }
                              },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      type == DialogType.primary
                                          ? Icons.check
                                          : Icons.delete,
                                      color: type == DialogType.primary
                                          ? Colors.blue
                                          : Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "បាទ/ចាស",
                                      style: TextStyle(
                                        color: type == DialogType.primary
                                            ? Colors.blue
                                            : Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
  return confirmed;
}

void showErrorDialog(
  BuildContext context,
  String title,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            InkWell(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  "បិទ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showConfirmDialogWithNavigation(
  BuildContext context,
  String title,
  String message,
  DialogType type,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "បោះបង់",
                            style: TextStyle(
                              color: isLoading ? Colors.grey : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        onTap: isLoading
                            ? null
                            : () async {
                                setState(() => isLoading = true);
                                try {
                                  onConfirm();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  setState(() => isLoading = false);
                                }
                              },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      type == DialogType.primary
                                          ? Icons.check
                                          : Icons.delete,
                                      color: type == DialogType.primary
                                          ? Colors.blue
                                          : Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "បាទ/ចាស",
                                      style: TextStyle(
                                        color: type == DialogType.primary
                                            ? Colors.blue
                                            : Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showConfirmDialogWithNavigationOfSaleInvoice(
  BuildContext context,
  String title,
  Widget message,
  DialogType type,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: message,
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text(
                        "បោះបង់",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                    onTap: () {
                      onConfirm();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type == DialogType.primary ? Icons.check : Icons.delete,
                            color: type == DialogType.primary
                                ? Colors.blue
                                : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "បាទ/ចាស",
                            style: TextStyle(
                              color: type == DialogType.primary
                                  ? Colors.blue
                                  : Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}