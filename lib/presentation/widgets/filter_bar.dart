import 'package:flutter/material.dart';
import 'package:rutccc/core/enums.dart'; // Agora usamos o enum compartilhado

class FilterBar extends StatelessWidget {
  final FilterOption selectedFilter;
  final ValueChanged<FilterOption> onFilterChanged;

  const FilterBar({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  Widget _buildFilterButton(String label, FilterOption option) {
    bool isSelected = selectedFilter == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(option),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE65100) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildFilterButton('Dia', FilterOption.dia),
          SizedBox(width: 8),
          _buildFilterButton('Semana', FilterOption.semana),
          SizedBox(width: 8),
          _buildFilterButton('Mês', FilterOption.mes),
        ],
      ),
    );
  }
}
