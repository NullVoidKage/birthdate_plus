import 'package:flutter/material.dart';
import '../utils/date_calculator.dart';

class RelationshipStats extends StatelessWidget {
  final DateTime anniversaryDate;
  final DateTime currentDate;

  const RelationshipStats({
    Key? key,
    required this.anniversaryDate,
    required this.currentDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = DateCalculator.calculateDuration(anniversaryDate);
    final totalDays = duration['totalDays']!;
    final totalWeeks = duration['totalWeeks']!;
    final totalMonths = (totalDays / 30.44).floor();
    final totalYears = (totalDays / 365.25).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow('Total Days', totalDays.toString()),
        _buildStatRow('Total Weeks', totalWeeks.toString()),
        _buildStatRow('Total Months', totalMonths.toString()),
        _buildStatRow('Total Years', totalYears.toString()),
        SizedBox(height: 8),
        Text(
          DateCalculator.getTimeAgo(anniversaryDate),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 