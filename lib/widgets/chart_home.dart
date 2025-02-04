import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sentinal/widgets/text_app.dart';

class UserRegistrationChart extends StatefulWidget {
  @override
  _UserRegistrationChartState createState() => _UserRegistrationChartState();
}

class _UserRegistrationChartState extends State<UserRegistrationChart> {
  Map<String, int> userCounts = {};
  List<String> days = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String formattedDate = DateFormat('dd-MM').format(date);

      QuerySnapshot usersSnapshot = await firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: date)
          .where('createdAt', isLessThan: date.add(Duration(days: 1)))
          .get();

      int userCount = usersSnapshot.docs.length;

      setState(() {
        userCounts[formattedDate] = userCount;
        days.add(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: getData(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: leftTitles),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: bottomTitles,
                  reservedSize: 40,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              checkToShowHorizontalLine: (value) => value % 10 == 0,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1,
              ),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            groupsSpace: 10,
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> getData() {
    return [
      for (int i = 0; i < days.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: userCounts[days[i]]?.toDouble() ?? 0,
              color: const Color.fromARGB(255, 74, 178, 218),
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
    ];
  }

  Widget leftTitles(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: TextStyle(fontSize: 10.sp, color: Colors.black), // Chỉnh màu đen
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index % 4 == 0 && index < days.length) {
      return Text(
        days[index],
        style: TextStyle(fontSize: 10.sp, color: Colors.black),
      );
    }
    return Text('');
  }
}
