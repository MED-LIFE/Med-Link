import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/main_drawer.dart';
import '../../constants/medico_constants.dart';
import '../../widgets/common/bouncing_card.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = "Enero 2026";
  final List<String> _periods = ["Enero 2026", "Diciembre 2025", "Noviembre 2025"];

  // Mock Data for Charts
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F1), // Cream Background
      appBar: AppBar(
        title: const Text('Reportes Platinum', style: TextStyle(color: Color(0xFF0D1C2E), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFEF9F1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF083866)),
        leading: const BackButton(color: Color(0xFF083866)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _exportToPdf,
              icon: const Icon(Icons.picture_as_pdf_rounded, color: MedicoConstants.primaryColor),
              tooltip: "Exportar PDF",
            ),
          )
        ],
      ),
      drawer: const MainDrawer(role: UserRole.admin),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FILTERS & HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Resumen Ejecutivo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      items: _periods.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _selectedPeriod = v!),
                      icon: const Icon(Icons.calendar_today_rounded, size: 16, color: MedicoConstants.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. FINANCIAL METRICS (NEW)
            Row(
              children: [
                Expanded(child: _buildMetricCard("Ingresos Estimados", "\$ 12.5M", "+15%", Icons.attach_money_rounded, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard("Pacientes Atendidos", "1,240", "+8%", Icons.people_alt_rounded, Colors.blue)),
              ],
            ),
            
            const SizedBox(height: 24),

            // 3. DEMOGRAPHICS PIE CHART (NEW)
            const Text("Distribución Demográfica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
            const SizedBox(height: 16),
            _buildDemographicsChart(),

            const SizedBox(height: 24),

            // 4. ACTIVITY BAR CHART (Refined)
            const Text("Actividad Semanal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
            const SizedBox(height: 16),
            _buildInteractiveBarChart(),

            const SizedBox(height: 24),

            // 5. HEATMAP (Existing but polished)
            const Text("Ocupación de Consultorios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
             const SizedBox(height: 16),
            _buildProfessionalHeatmap(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(trend, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[900])),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDemographicsChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: List.generate(4, (i) {
                  final isTouched = i == touchedIndex;
                  final fontSize = isTouched ? 20.0 : 14.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  const shadows = [BoxShadow(color: Colors.black12, blurRadius: 3)];
                  switch (i) {
                    case 0:
                      return PieChartSectionData(
                        color: Colors.blue, value: 40, title: '40%', radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: shadows),
                      );
                    case 1:
                      return PieChartSectionData(
                        color: Colors.orange, value: 30, title: '30%', radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: shadows),
                      );
                    case 2:
                      return PieChartSectionData(
                        color: Colors.purple, value: 15, title: '15%', radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: shadows),
                      );
                    case 3:
                      return PieChartSectionData(
                        color: Colors.green, value: 15, title: '15%', radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, shadows: shadows),
                      );
                    default:
                      throw Error();
                  }
                }),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(Colors.blue, "PAMI"),
              const SizedBox(height: 8),
              _buildLegend(Colors.orange, "IOMA"),
              const SizedBox(height: 8),
              _buildLegend(Colors.purple, "OSDE"),
              const SizedBox(height: 8),
              _buildLegend(Colors.green, "Particular"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInteractiveBarChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(text: (['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'])[group.x.toInt()], style: const TextStyle(color: Colors.yellow, fontSize: 12)),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(color: Color(0xff7589a2), fontWeight: FontWeight.bold, fontSize: 12);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Lun'; break;
                    case 1: text = 'Mar'; break;
                    case 2: text = 'Mié'; break;
                    case 3: text = 'Jue'; break;
                    case 4: text = 'Vie'; break;
                    case 5: text = 'Sáb'; break;
                    case 6: text = 'Dom'; break;
                    default: text = ''; break;
                  }
                  return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
             _makeGroupData(0, 45, Colors.blue),
             _makeGroupData(1, 78, Colors.blue),
             _makeGroupData(2, 56, Colors.blue),
             _makeGroupData(3, 92, Colors.orange), // Pico critical
             _makeGroupData(4, 65, Colors.blue),
             _makeGroupData(5, 88, Colors.blue),
             _makeGroupData(6, 40, Colors.grey),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: Colors.grey.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildProfessionalHeatmap() {
    // Reusing the nice heatmap but wrapped/refactored if needed
    // ... For brevity I'll copy the existing Logic but simpler
     final days = ["Lun", "Mar", "Mié", "Jue", "Vie"];
     final timeSlots = ["09:00", "11:00", "14:00", "16:00"];

     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              ...days.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))))),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeSlots.length,
            itemBuilder: (context, timeIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text(timeSlots[timeIndex], style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                    ...List.generate(days.length, (dayIndex) {
                      int intensity = (dayIndex * 2 + timeIndex * 3) % 4; 
                      Color color;
                      if (intensity == 0) color = Colors.green.withOpacity(0.2);
                      else if (intensity == 1) color = Colors.orange.withOpacity(0.4);
                      else if (intensity == 2) color = Colors.red.withOpacity(0.6);
                      else color = Colors.red;
                      
                      return Expanded(
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _exportToPdf() {
    // Show snackbar simulating export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Reporte PDF generado exitosamente"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      )
    );
  }
}
