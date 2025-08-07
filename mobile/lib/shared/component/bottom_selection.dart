// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Shared Components
import 'package:calendar/shared/entity/helper/colors.dart';


// Reusable Selection Field widget
Widget buildSelectionField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required Map<String, String> items,
  required void Function(String id, String value) onSelected,
  String? selectedId, // Add selectedId parameter
  required BuildContext context,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 16, color: HColors.darkgrey)),
      TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          await _showSelectionBottomSheet(
            context: context,
            title: label,
            items: items,
            onSelected: onSelected,
            //  selectedId: selectedEducationTypeId, // Pass current selection
            selectedId: selectedId, // Pass current selection
          );
        },
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(Icons.arrow_drop_down, color: HColors.darkgrey),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          // filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: HColors.darkgrey,
            fontWeight: FontWeight.w400,
          ),
          // hintStyle: TextStyle(color: HColors.darkgrey),
        ),
        // decoration: InputDecoration(
        //   labelText: label,
        //   labelStyle: TextStyle(color: HColors.darkgrey),
        //   border: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(12.0),
        //     borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        //   ),
        //   enabledBorder: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(12.0),
        //     borderSide: BorderSide(color: HColors.darkgrey),
        //   ),
        //   focusedBorder: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(12.0),
        //     borderSide: BorderSide(
        //         color: Theme.of(context).colorScheme.primary, width: 1.0),
        //   ),
        // suffixIcon: Icon(Icons.arrow_drop_down,
        //     color: Theme.of(context).colorScheme.primary),
        //   filled: true,
        // ),
      ),
    ],
  );
}

Future<void> _showSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required Map<String, String> items,
  required Function(String id, String value) onSelected,
  String? selectedId,
}) async {
  // Calculate height based on items
  const double itemHeight = 56.0; // Height per item (padding + text)
  const double headerHeight = 72.0; // Header height
  const double bottomPadding = 20.0; // Bottom padding
  const double maxHeight = 400.0; // Maximum height to prevent overflow

  final calculatedHeight =
      headerHeight + (items.length * itemHeight) + bottomPadding;
  final sheetHeight =
      calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

  await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    constraints: BoxConstraints(maxHeight: sheetHeight),
    builder: (context) {
      return SafeArea(
        child: SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8.0),
                    itemBuilder: (context, index) {
                      final entry = items.entries.elementAt(index);
                      final isSelected = selectedId == entry.key;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onSelected(entry.key, entry.value);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24.0,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
