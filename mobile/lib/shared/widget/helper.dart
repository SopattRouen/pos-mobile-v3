import 'package:flutter/material.dart';

enum DialogType {
  primary,
  danger,
}

void showConfirmDialog(
  BuildContext context,
  String title,
  String message,
  DialogType type,
  VoidCallback onConfirm,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
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
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                // Icon and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(
                    //   Icons.warning,
                    //   color: type == DialogType.primary ? Colors.blue : Colors.red,
                    //   size: 24,
                    // ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(
                  height: 1,
                  color: isDark 
                    ? Colors.white.withOpacity(0.12) 
                    : Colors.grey.withOpacity(0.2),
                ),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
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
                            'បិត',
                            style: TextStyle(
                              color: isLoading 
                                ? (isDark ? Colors.grey[600] : Colors.grey)
                                : (isDark ? Colors.white70 : Colors.black),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: isDark 
                        ? Colors.white.withOpacity(0.12) 
                        : Colors.grey.withOpacity(0.2),
                    ),
                    // Confirm Button
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
                                  await Future(() => onConfirm());
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
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      type == DialogType.primary ? Colors.blue : Colors.red,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      type == DialogType.primary ? Icons.check : Icons.delete,
                                      color: type == DialogType.primary ? Colors.blue : Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                     'បាទ/ចាស',
                                      style: TextStyle(
                                        color: type == DialogType.primary ? Colors.blue : Colors.red,
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

void showErrorDialog(
  BuildContext context,
  String title,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // Error Icon
            // const Icon(
            //   Icons.warning_rounded,
            //   color: Colors.red,
            //   size: 48,
            // ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Divider(
              height: 1,
              color: isDark 
                ? Colors.white.withOpacity(0.12) 
                : Colors.grey.withOpacity(0.2),
            ),

            // OK Button
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
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
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
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                // Icon and Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(
                    //   Icons.warning,
                    //   color: type == DialogType.primary ? Colors.blue : Colors.red,
                    //   size: 24,
                    // ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(
                  height: 1,
                  color: isDark 
                    ? Colors.white.withOpacity(0.12) 
                    : Colors.grey.withOpacity(0.2),
                ),

                // Buttons
                Row(
                  children: [
                    // Cancel Button
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
                              color: isLoading 
                                ? (isDark ? Colors.grey[600] : Colors.grey)
                                : (isDark ? Colors.white70 : Colors.black),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: isDark 
                        ? Colors.white.withOpacity(0.12) 
                        : Colors.grey.withOpacity(0.2),
                    ),
                    // Confirm Button
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
                                  await Future(() => onConfirm());
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
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      type == DialogType.primary ? Colors.blue : Colors.red,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      type == DialogType.primary ? Icons.check : Icons.delete,
                                      color: type == DialogType.primary ? Colors.blue : Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "បាទ/ចាស",
                                      style: TextStyle(
                                        color: type == DialogType.primary ? Colors.blue : Colors.red,
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
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),

            // Icon and Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(
                //   Icons.warning,
                //   color: type == DialogType.primary ? Colors.blue : Colors.red,
                //   size: 24,
                // ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Custom Widget Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: message,
            ),
            const SizedBox(height: 16),

            // Divider
            Divider(
              height: 1,
              color: isDark 
                ? Colors.white.withOpacity(0.12) 
                : Colors.grey.withOpacity(0.2),
            ),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                       'បិត',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: isDark 
                    ? Colors.white.withOpacity(0.12) 
                    : Colors.grey.withOpacity(0.2),
                ),
                // Confirm Button
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
                            color: type == DialogType.primary ? Colors.blue : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            // AppLang.translate(
                            //   lang: Provider.of<SettingProvider>(context).lang ?? 'kh',
                            //   key: 'yes'
                            // ),,
                            'បាទ/ចាស',
                            style: TextStyle(
                              color: type == DialogType.primary ? Colors.blue : Colors.red,
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