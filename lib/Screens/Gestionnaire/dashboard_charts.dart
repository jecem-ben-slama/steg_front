import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pfa/Utils/text_strokes.dart'; // Assuming this file exists and provides TextStroke
import 'dart:math';

// New, softer, more professional color palette
// Inspired by Material Design's light shades and earthy tones.
List<Color> _chartColors = [
  const Color(0xFF64B5F6), // Light Blue
  const Color(0xFFA5D6A7), // Light Green
  const Color(0xFFFFCC80), // Orange (light)
  const Color(0xFFBBDEFB), // Lighter Blue
  const Color(0xFFE1BEE7), // Light Purple
  const Color(0xFFFFF176), // Yellow
  const Color(0xFFBCAAA4), // Brown (lighter)
  const Color(0xFFC5E1A5), // Pale Green
  const Color(0xFFFFAB91), // Deep Orange (lighter)
  const Color(0xFF80CBC4), // Teal (lighter)
  const Color(0xFF90CAF9), // Blue-Grey (lighter)
  const Color(0xFFF48FB1), // Pink (lighter)
];

Color getChartColor(int index) {
  return _chartColors[index % _chartColors.length];
}

class CustomPieChart extends StatefulWidget {
  final String title;
  final Map<String, int> data;

  const CustomPieChart({Key? key, required this.title, required this.data})
    : super(key: key);

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Card(
        elevation: 1, // Even flatter card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Slightly less rounded
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removed as content is centered
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15, // Smaller title
                  fontWeight: FontWeight.w600, // Medium bold
                  color: Colors.black87, // Darker for contrast
                ),
              ),
              // Updated: Removed Expanded and added icon
              Expanded(
                // Keep Expanded here to fill the Card's height, as the Card itself will be constrained by the outer SizedBox in Statistics
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12.0), // Reduced padding
                        child: Text(
                          'No data available for this chart.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13, // Smaller message
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = widget.data.values.fold(0, (sum, item) => sum + item);

    return Card(
      elevation: 1, // Even flatter card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10), // Reduced spacing
            SizedBox(
              height: 180, // **Significantly reduced height**
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2, // Chart gets more space
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(total),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2, // Small space
                        centerSpaceRadius: 60, // **Larger donut hole**
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), // Reduced space for legend
                  Expanded(
                    flex: 1, // Legend gets less space
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildIndicators(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(int total) {
    int i = 0;
    return widget.data.entries.map((entry) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 12 : 9; // Even smaller font sizes
      final double radius = isTouched
          ? 65
          : 60; // Base radius, adjusted by touch
      final color = getChartColor(i);
      final percentage = total == 0 ? 0.0 : (entry.value / total) * 100;

      // Decide whether to show percentage based on size
      Widget? titleWidget;

      titleWidget = TextStroke(
        text: '${percentage.toStringAsFixed(0)}%',
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        strokeColor: Colors.black.withOpacity(0.4), // Softer stroke
        strokeWidth: 0.6, // Thinner stroke
      );

      final sectionData = PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '', // <--- ADD THIS LINE to explicitly hide default title/value
        badgeWidget: titleWidget,
        radius: radius,
        titlePositionPercentageOffset: 0.55,
      );
      i++;
      return sectionData;
    }).toList();
  }

  List<Widget> _buildIndicators() {
    int i = 0;
    return widget.data.entries.map((entry) {
      final color = getChartColor(i);
      final isTouched = i == touchedIndex;
      final textColor = isTouched ? color : Colors.black54; // Softer text
      final fontWeight = isTouched ? FontWeight.bold : FontWeight.normal;

      final indicator = Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2.0,
        ), // Even more compact vertical spacing
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12, // Smaller color box
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isTouched
                    ? Border.all(color: Colors.black54, width: 1.0)
                    : null, // Subtle border on touch
              ),
            ),
            const SizedBox(width: 6), // Reduced space
            Flexible(
              child: Text(
                '${entry.key} (${entry.value})', // Combine label and count
                style: TextStyle(
                  fontSize: 11, // Smaller font
                  fontWeight: fontWeight,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
      i++;
      return indicator;
    }).toList();
  }
}

class CustomBarChart extends StatelessWidget {
  final String title;
  final Map<String, int> data;

  const CustomBarChart({Key? key, required this.title, required this.data})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removed as content is centered
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              // Updated: Removed Expanded and added icon
              Expanded(
                // Keep Expanded here to fill the Card's height, as the Card itself will be constrained by the outer SizedBox in Statistics
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'No data available for this chart.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<String> barTitles = data.keys.toList();
    final List<int> barValues = data.values.toList();
    final double maxY =
        (barValues.isNotEmpty ? barValues.reduce(max).toDouble() : 0.0) *
        1.05; // 5% buffer

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200, // **Significantly reduced height**
              child: BarChart(
                BarChartData(
                  barGroups: _buildBarGroups(barValues),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ), // Even lighter border
                      left: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ), // Even lighter border
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade50, // Barely visible grid lines
                      strokeWidth: 0.5,
                    ),
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 ||
                              value.toInt() >= barTitles.length) {
                            return const Text('');
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0, // Reduced space
                            child: Text(
                              barTitles[value.toInt()],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                fontSize: 9, // Even smaller font
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        reservedSize: 35, // Reduced reserved size
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade500, // Softer text color
                              fontSize: 9, // Even smaller font
                            ),
                            textAlign: TextAlign.right,
                          );
                        },
                        reservedSize: 25, // Reduced reserved size
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // Darker, more muted tooltip
                      tooltipPadding: const EdgeInsets.all(
                        5,
                      ), // Reduced padding
                      tooltipBorderRadius: BorderRadius.circular(
                        8,
                      ), // Slightly less rounded
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${barTitles[group.x.toInt()]}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11, // Smaller tooltip text
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${rod.toY.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13, // Smaller value text
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<int> values) {
    return List.generate(values.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index].toDouble(),
            color: getChartColor(index),
            width: 15, // Thinner bars
            borderRadius: BorderRadius.circular(4), // Good rounded corners
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: values.reduce(max).toDouble() * 1.05,
              color: Colors.grey.shade50,
            ),
          ),
        ],
      );
    });
  }
}
// Assuming this file exists and provides TextStroke

class CustomLineChart extends StatelessWidget {
  final String title;
  final Map<String, double> data; // Data for line chart (e.g., year -> amount)
  final String? xAxisTitle;
  final String? yAxisTitle;

  const CustomLineChart({
    Key? key,
    required this.title,
    required this.data,
    this.xAxisTitle,
    this.yAxisTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'No data available for this chart.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort data by year for proper line chart display
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    final List<FlSpot> spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final List<String> xTitles = sortedEntries.map((e) => e.key).toList();
    final double minY = 0;
    final double maxY =
        (spots.isNotEmpty ? spots.map((s) => s.y).reduce(max) : 0.0) *
        1.1; // 10% buffer

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: xAxisTitle != null
                          ? Text(
                              xAxisTitle!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      axisNameSize: xAxisTitle != null
                          ? 20
                          : 0, // Space for title
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // Show all year labels
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < xTitles.length) {
                            return SideTitleWidget(
                              meta: meta,
                              space: 4.0,
                              child: Text(
                                xTitles[index],
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 9,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 35,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: yAxisTitle != null
                          ? Text(
                              yAxisTitle!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      axisNameSize: yAxisTitle != null ? 20 : 0,
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(
                              0,
                            ), // Show integer values for amount
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.right,
                          );
                        },
                        reservedSize:
                            40, // Increased reserved size for potentially larger numbers
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true, // Show vertical lines for years
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade50, strokeWidth: 0.5),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: Colors.grey.shade50, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color:
                          _chartColors[0], // Use the first color from the palette
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _chartColors[0].withOpacity(
                          0.3,
                        ), // Soft fill below the line
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final year = xTitles[touchedSpot.spotIndex];
                          final amount = touchedSpot.y.toStringAsFixed(2);
                          return LineTooltipItem(
                            '$year\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text: 'TND $amount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
