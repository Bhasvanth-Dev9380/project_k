import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FacultyDashboard extends StatelessWidget {
  final int assignmentsGiven;
  final int meetingsTaken;
  final int quizzesConducted;

  FacultyDashboard({
    Key? key,
  })  : assignmentsGiven = Random().nextInt(81) + 20, // random between 20 and 100
        meetingsTaken = Random().nextInt(81) + 20,
        quizzesConducted = Random().nextInt(81) + 20,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DashboardCard(
                      title: 'Assignments Given',
                      count: assignmentsGiven,
                      color: Colors.blueAccent,
                      icon: Icons.assignment,
                    ),
                    DashboardCard(
                      title: 'Meetings Taken',
                      count: meetingsTaken,
                      color: Colors.pinkAccent,
                      icon: Icons.video_call,
                    ),
                    DashboardCard(
                      title: 'Quizzes Conducted',
                      count: quizzesConducted,
                      color: Colors.orangeAccent,
                      icon: Icons.quiz,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Radar Chart for Comparison in August, September, October
              Text(
                'Monthly Comparison (Aug, Sep, Oct)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.3,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RadarChart(
                      RadarChartData(
                        radarTouchData: RadarTouchData(
                          touchCallback: (FlTouchEvent event, response) {
                            if (!event.isInterestedForInteractions) return;
                          },
                        ),
                        dataSets: [
                          RadarDataSet(
                            fillColor: Colors.blueAccent.withOpacity(0.3),
                            borderColor: Colors.blueAccent,
                            borderWidth: 2,
                            entryRadius: 4,
                            dataEntries: [
                              RadarEntry(value: Random().nextInt(40) + 20), // Assignments in Aug
                              RadarEntry(value: Random().nextInt(40) + 20), // Assignments in Sep
                              RadarEntry(value: Random().nextInt(40) + 20), // Assignments in Oct
                            ],
                          ),
                          RadarDataSet(
                            fillColor: Colors.pinkAccent.withOpacity(0.3),
                            borderColor: Colors.pinkAccent,
                            borderWidth: 2,
                            entryRadius: 4,
                            dataEntries: [
                              RadarEntry(value: Random().nextInt(40) + 20), // Meetings in Aug
                              RadarEntry(value: Random().nextInt(40) + 20), // Meetings in Sep
                              RadarEntry(value: Random().nextInt(40) + 20), // Meetings in Oct
                            ],
                          ),
                          RadarDataSet(
                            fillColor: Colors.orangeAccent.withOpacity(0.3),
                            borderColor: Colors.orangeAccent,
                            borderWidth: 2,
                            entryRadius: 4,
                            dataEntries: [
                              RadarEntry(value: Random().nextInt(40) + 20), // Quizzes in Aug
                              RadarEntry(value: Random().nextInt(40) + 20), // Quizzes in Sep
                              RadarEntry(value: Random().nextInt(40) + 20), // Quizzes in Oct
                            ],
                          ),
                        ],
                        radarBackgroundColor: Colors.transparent,
                        titleTextStyle: TextStyle(color: Colors.white, fontSize: 14),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0:
                              return RadarChartTitle(text: 'Aug');
                            case 1:
                              return RadarChartTitle(text: 'Sep');
                            case 2:
                              return RadarChartTitle(text: 'Oct');
                            default:
                              return const RadarChartTitle(text: '');
                          }
                        },
                        tickCount: 4,
                        ticksTextStyle: TextStyle(color: Colors.white, fontSize: 10),
                        tickBorderData: BorderSide(color: Colors.white.withOpacity(0.5)),
                        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.8), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Text(
                'Performance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.5,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [BarChartRodData(toY: assignmentsGiven.toDouble(), color: Colors.blueAccent)],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [BarChartRodData(toY: meetingsTaken.toDouble(), color: Colors.pinkAccent)],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [BarChartRodData(toY: quizzesConducted.toDouble(), color: Colors.orangeAccent)],
                          ),
                        ],
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Text(
                'Distribution of Activities',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.2,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.blueAccent,
                            value: assignmentsGiven.toDouble(),
                            title: 'Assignments',
                            titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            color: Colors.pinkAccent,
                            value: meetingsTaken.toDouble(),
                            title: 'Meetings',
                            titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            color: Colors.orangeAccent,
                            value: quizzesConducted.toDouble(),
                            title: 'Quizzes',
                            titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 100,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Yearly Overview with Line Charts for Assignments, Quizzes, and Meetings
              Text(
                'Yearly Overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                height: 500,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      YearlyOverviewChart(title: 'Assignments', color: Color(0xFF88B2AC)),
                      YearlyOverviewChart(title: 'Quizzes', color: Colors.orangeAccent),
                      YearlyOverviewChart(title: 'Meetings', color: Colors.pinkAccent),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YearlyOverviewChart extends StatelessWidget {
  final String title;
  final Color color;

  YearlyOverviewChart({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title Overview",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            12,
                                (index) => FlSpot(index.toDouble(), Random().nextDouble() * 100 + 20),
                          ),
                          isCurved: true,
                          color: color,
                          belowBarData: BarAreaData(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withOpacity(0.5),
                                Colors.transparent
                              ],
                            ),
                            show: true,
                          ),
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 20),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                              ];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(months[value.toInt()]),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
