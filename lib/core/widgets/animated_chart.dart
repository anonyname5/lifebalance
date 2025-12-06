import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Animated bar chart wrapper
class AnimatedBarChart extends StatefulWidget {
  final BarChartData barChartData;
  final Duration duration;
  final Curve curve;

  const AnimatedBarChart({
    super.key,
    required this.barChartData,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Animate bar heights
        final animatedBarGroups = widget.barChartData.barGroups.map((group) {
          return BarChartGroupData(
            x: group.x,
            barRods: group.barRods.map((rod) {
              return BarChartRodData(
                toY: rod.toY * _animation.value,
                color: rod.color,
                width: rod.width,
                borderRadius: rod.borderRadius,
                fromY: rod.fromY,
              );
            }).toList(),
          );
        }).toList();

        return BarChart(
          BarChartData(
            alignment: widget.barChartData.alignment,
            maxY: widget.barChartData.maxY,
            minY: widget.barChartData.minY,
            barTouchData: widget.barChartData.barTouchData,
            titlesData: widget.barChartData.titlesData,
            gridData: widget.barChartData.gridData,
            borderData: widget.barChartData.borderData,
            barGroups: animatedBarGroups,
          ),
        );
      },
    );
  }
}

/// Animated line chart wrapper
class AnimatedLineChart extends StatefulWidget {
  final LineChartData lineChartData;
  final Duration duration;
  final Curve curve;

  const AnimatedLineChart({
    super.key,
    required this.lineChartData,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedLineChart> createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Animate line chart spots
        final animatedLineBarsData = widget.lineChartData.lineBarsData.map((lineBar) {
          return LineChartBarData(
            spots: lineBar.spots.map((spot) {
              return FlSpot(spot.x, spot.y * _animation.value);
            }).toList(),
            isCurved: lineBar.isCurved,
            color: lineBar.color,
            barWidth: lineBar.barWidth,
            dotData: lineBar.dotData,
            belowBarData: lineBar.belowBarData,
          );
        }).toList();

        return LineChart(
          LineChartData(
            minX: widget.lineChartData.minX,
            maxX: widget.lineChartData.maxX,
            minY: widget.lineChartData.minY,
            maxY: widget.lineChartData.maxY,
            titlesData: widget.lineChartData.titlesData,
            gridData: widget.lineChartData.gridData,
            borderData: widget.lineChartData.borderData,
            lineBarsData: animatedLineBarsData,
          ),
        );
      },
    );
  }
}

/// Animated pie chart wrapper
class AnimatedPieChart extends StatefulWidget {
  final PieChartData pieChartData;
  final Duration duration;
  final Curve curve;

  const AnimatedPieChart({
    super.key,
    required this.pieChartData,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Animate pie chart sections
        final animatedSections = widget.pieChartData.sections.map((section) {
          return PieChartSectionData(
            value: section.value * _animation.value,
            title: section.title,
            color: section.color,
            radius: section.radius,
            titleStyle: section.titleStyle,
          );
        }).toList();

        return PieChart(
          PieChartData(
            sectionsSpace: widget.pieChartData.sectionsSpace,
            centerSpaceRadius: widget.pieChartData.centerSpaceRadius,
            sections: animatedSections,
          ),
        );
      },
    );
  }
}
