import 'package:flutter/material.dart';

class HistoryFilterBar extends StatelessWidget {
  final String selectedFilter;
  final String selectedSort;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;

  const HistoryFilterBar({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Chest', 'Back', 'Legs', 'Core'];

    final sortOptions = ['Newest', 'Oldest', 'Longest', 'Shortest'];

    return Row(
      children: [
        Expanded(
          child: _DropdownBox(
            value: selectedFilter,
            items: filters,
            onChanged: onFilterChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DropdownBox(
            value: selectedSort,
            items: sortOptions,
            onChanged: onSortChanged,
          ),
        ),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
