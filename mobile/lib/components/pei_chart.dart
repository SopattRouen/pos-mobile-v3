import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar/entity/helper/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DonutPie extends StatelessWidget {
  final List<DonutPieData> data;
  final String title;

  const DonutPie({super.key, required this.data, this.title = 'Product Types'});

  @override
  Widget build(BuildContext context) {
    final TooltipBehavior tooltip = TooltipBehavior(enable: true);

    return SfCircularChart(
      tooltipBehavior: tooltip,
      series: <CircularSeries<DonutPieData, String>>[
        DoughnutSeries<DonutPieData, String>(
          dataSource: data,
          xValueMapper: (DonutPieData data, _) => data.x,
          yValueMapper: (DonutPieData data, _) => data.y,
          pointColorMapper: (DonutPieData data, _) => data.color,
          dataLabelMapper: (DonutPieData data, _) =>
              NumberFormat.decimalPattern().format(data.y),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          name: title,
          startAngle: 270,
          endAngle: 90,
        ),
      ],
      legend: const Legend(
        isVisible: true,

        position: LegendPosition.bottom,
        alignment: ChartAlignment.center,
        overflowMode: LegendItemOverflowMode.wrap,
        itemPadding: 5, // Reduced to minimize spacing
        padding: 0, // Added to reduce gap between chart and legend
      ),
    );
  }
}

class DonutPieData {
  final String x;
  final double y;
  final Color color;

  DonutPieData(this.x, this.y, this.color);
}

class StatisticChat extends StatefulWidget {
  final List<ChartData> data; // Use a generic ChartData class
  const StatisticChat({super.key, required this.data, required salesData});

  @override
  StatisticChatState createState() => StatisticChatState();
}

class StatisticChatState extends State<StatisticChat> {
  late final TooltipBehavior _tooltip = TooltipBehavior(enable: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Find the maximum value in the data
    double maxYValue =
        widget.data.isNotEmpty
            ? widget.data
                .map((data) => data.y)
                .reduce(max) // Using `max` directly for clarity
            : 100; // Default value if the data list is empty

    // Ensure a positive interval
    double interval = maxYValue / 10;
    interval =
        interval > 0 ? interval : 100; // Ensuring a fallback positive interval

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: SfCartesianChart(
             primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0), // Disable grid lines on X-axis
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: maxYValue,
              interval: interval,
              numberFormat: NumberFormat.currency(
                locale: 'km',
                symbol: '',

                decimalDigits: 0,
              ),
            ),
            tooltipBehavior: _tooltip,
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: widget.data,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'calendar',

                dataLabelSettings: DataLabelSettings(
                  textStyle: TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    fontSize: 8,
                   
                  ),
                ),
                color: HColors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ChartData class definition
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
