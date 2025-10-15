import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedReportType = 'Báo cáo giảng dạy';
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  bool isCardView = true;
  bool _isBarChart = true; // State để quản lý loại biểu đồ

  final List<String> reportTypes = [
    'Báo cáo giảng dạy',
    'Báo cáo chuyên cần',
    'Báo cáo tổng hợp',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFilters(),
                        _buildStatsCards(),
                        _buildChartSection(), // Widget biểu đồ đã được thêm ở đây
                        _buildScheduleSection(),
                        // _buildActionButtons(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Báo cáo thống kê',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              _buildIconButton(Icons.filter_list),
              const SizedBox(width: 12),
              _buildIconButton(Icons.more_vert),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại báo cáo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFf9fafb),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe5e7eb), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedReportType,
                isExpanded: true,
                style: const TextStyle(
                  fontFamily: 'Roboto', // Thêm font family để nhất quán
                  fontSize: 16,
                  color: Color(0xFF1e293b),
                ),
                items: reportTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedReportType = newValue!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Thời gian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildDateField(startDate, true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('-', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(child: _buildDateField(endDate, false)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang tạo báo cáo...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4f46e5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Xem báo cáo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(DateTime date, bool isStart) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null && picked != date) {
          setState(() {
            if (isStart) {
              startDate = picked;
            } else {
              endDate = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFf9fafb),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFe5e7eb), width: 2),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: const Color(0xFFf8fafc),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _buildStatCard('124', 'Tổng giờ', const Color(0xFF3b82f6)),
          _buildStatCard('2', 'Nghỉ', const Color(0xFFef4444)),
          _buildStatCard('1', 'Dạy bù', const Color(0xFFf59e0b)),
          _buildStatCard('99%', 'Chuyên cần', const Color(0xFF10b981)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748b),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// WIDGET CHÍNH CHO PHẦN BIỂU ĐỒ
  Widget _buildChartSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biểu đồ thống kê',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildChartToggleButton('Cột', _isBarChart, true),
                    _buildChartToggleButton('Tròn', !_isBarChart, false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isBarChart ? _buildBarChart() : _buildPieChart(),
            ),
          ),
        ],
      ),
    );
  }

  /// NÚT CHUYỂN ĐỔI GIỮA BIỂU ĐỒ CỘT VÀ TRÒN
  Widget _buildChartToggleButton(String title, bool isSelected, bool isFirst) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBarChart = isFirst;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            )
          ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// WIDGET HIỂN THỊ BIỂU ĐỒ CỘT
  Widget _buildBarChart() {
    final barGroups = [
      _makeGroupData(0, 124, const Color(0xFF3b82f6)),
      _makeGroupData(1, 2, const Color(0xFFef4444)),
      _makeGroupData(2, 1, const Color(0xFFf59e0b)),
      _makeGroupData(3, 99, const Color(0xFF10b981)),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 140,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Tổng giờ';
                    break;
                  case 1:
                    text = 'Nghỉ';
                    break;
                  case 2:
                    text = 'Dạy bù';
                    break;
                  case 3:
                    text = 'Chuyên cần';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                    axisSide: meta.axisSide, child: Text(text, style: style));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > 140) return const SizedBox();
                return Text('${value.toInt()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10));
              },
            ),
          ),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        barGroups: barGroups,
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  /// HÀM HỖ TRỢ TẠO DỮ LIỆU CỘT
  BarChartGroupData _makeGroupData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }

  /// WIDGET HIỂN THỊ BIỂU ĐỒ TRÒN
  Widget _buildPieChart() {
    final pieSections = [
      PieChartSectionData(
          value: 124,
          color: const Color(0xFF3b82f6),
          title: '124',
          radius: 60,
          titleStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(
          value: 2,
          color: const Color(0xFFef4444),
          title: '2',
          radius: 60,
          titleStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(
          value: 1,
          color: const Color(0xFFf59e0b),
          title: '1',
          radius: 60,
          titleStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: pieSections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIndicator('Tổng giờ', const Color(0xFF3b82f6)),
            const SizedBox(width: 16),
            _buildIndicator('Nghỉ', const Color(0xFFef4444)),
            const SizedBox(width: 16),
            _buildIndicator('Dạy bù', const Color(0xFFf59e0b)),
          ],
        )
      ],
    );
  }

  /// WIDGET TẠO CHÚ THÍCH CHO BIỂU ĐỒ TRÒN
  Widget _buildIndicator(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(),
          isCardView ? _buildCardView() : _buildTableView(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFf8fafc), Color(0xFFe2e8f0)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lịch giảng dạy chi tiết',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFe2e8f0),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                _buildToggleButton('Cards', isCardView, true),
                _buildToggleButton('Table', !isCardView, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, bool isFirst) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCardView = isFirst;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF4f46e5) : const Color(0xFF64748b),
          ),
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDayCard(
            '12/9',
            'Thứ 2',
            '6 tiết',
            'Cao',
            const Color(0xFFfed7aa),
            const Color(0xFFc2410c),
            [
              ClassInfo(
                subject: 'Toán Cao Cấp A1',
                classCode: '20CT1',
                period: '1-3 (7:00-9:30)',
                room: 'A301',
                students: '45/50',
                attendance: '90%',
                subjectColor: const Color(0xFF1e40af),
              ),
              ClassInfo(
                subject: 'Toán Cao Cấp A1',
                classCode: '20CT2',
                period: '4-6 (9:45-12:15)',
                room: 'A301',
                students: '48/50',
                attendance: '96%',
                subjectColor: const Color(0xFF1e40af),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDayCard(
            '13/9',
            'Thứ 3',
            '9 tiết',
            'Rất cao',
            const Color(0xFFfecaca),
            const Color(0xFFdc2626),
            [
              ClassInfo(
                subject: 'Vật Lý Đại Cương',
                classCode: '20VL1',
                period: '1-3 (7:00-9:30)',
                room: 'B205',
                students: '52/60',
                attendance: '87%',
                subjectColor: const Color(0xFF7c2d12),
              ),
              ClassInfo(
                subject: 'Toán Cao Cấp A2',
                classCode: '19CT3',
                period: '4-6 (9:45-12:15)',
                room: 'A302',
                students: '38/45',
                attendance: '84%',
                subjectColor: const Color(0xFF1e40af),
              ),
              ClassInfo(
                subject: 'Xác Suất Thống Kê',
                classCode: '20TK1',
                period: '7-9 (13:30-16:00)',
                room: 'C103',
                students: '35/40',
                attendance: '88%',
                subjectColor: const Color(0xFF1e40af),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
      String date,
      String dayName,
      String totalPeriods,
      String workload,
      Color workloadBg,
      Color workloadColor,
      List<ClassInfo> classes,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1e293b), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalPeriods,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: workloadBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        workload,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: workloadColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: classes
                  .map((classInfo) => _buildClassItem(classInfo))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem(ClassInfo classInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      classInfo.subjectColor.withOpacity(0.2),
                      classInfo.subjectColor.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  classInfo.subject,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: classInfo.subjectColor,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFf1f5f9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  classInfo.classCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748b),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Tiết:', classInfo.period),
          _buildDetailRow('Phòng:', classInfo.room),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SV:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Text(
                    classInfo.students,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1e293b),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFdbeafe),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      classInfo.attendance,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1e40af),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF1e293b),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF1e293b)),
        columns: const [
          DataColumn(
            label: Text('Ngày',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Môn học',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Lớp',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Tiết',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Phòng',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('SV',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('%CC',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
        rows: [
          _buildDataRow(
              '12/9', 'Toán Cao Cấp A1', '20CT1', '1-3', 'A301', '45/50', '90%'),
          _buildDataRow(
              '12/9', 'Toán Cao Cấp A1', '20CT2', '4-6', 'A301', '48/50', '96%'),
          _buildDataRow('13/9', 'Vật Lý Đại Cương', '20VL1', '1-3', 'B205',
              '52/60', '87%'),
          _buildDataRow(
              '13/9', 'Toán Cao Cấp A2', '19CT3', '4-6', 'A302', '38/45', '84%'),
          _buildDataRow('13/9', 'Xác Suất Thống Kê', '20TK1', '7-9', 'C103',
              '35/40', '88%'),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String date, String subject, String classCode,
      String period, String room, String students, String attendance) {
    return DataRow(cells: [
      DataCell(Text(date, style: const TextStyle(fontSize: 12))),
      DataCell(Text(subject, style: const TextStyle(fontSize: 12))),
      DataCell(Text(classCode, style: const TextStyle(fontSize: 12))),
      DataCell(Text(period, style: const TextStyle(fontSize: 12))),
      DataCell(Text(room, style: const TextStyle(fontSize: 12))),
      DataCell(Text(students, style: const TextStyle(fontSize: 12))),
      DataCell(Text(attendance,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
    ]);
  }

  // Widget _buildActionButtons() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: ElevatedButton.icon(
  //             onPressed: () {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text('Đang xuất Excel...')),
  //               );
  //             },
  //             icon: const Icon(Icons.file_download, size: 18),
  //             label: const Text('Xuất Excel'),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF059669),
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               elevation: 4,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: OutlinedButton.icon(
  //             onPressed: () {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text('Đang chia sẻ...')),
  //               );
  //             },
  //             icon: const Icon(Icons.share, size: 18),
  //             label: const Text('Chia sẻ'),
  //             style: OutlinedButton.styleFrom(
  //               foregroundColor: const Color(0xFF4f46e5),
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               side: const BorderSide(color: Color(0xFFe5e7eb), width: 2),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildBottomNav() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 20,
  //           offset: const Offset(0, -4),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 12),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             _buildNavItem(Icons.bar_chart, 'Báo cáo', true),
  //             _buildNavItem(Icons.calendar_today, 'Lịch', false),
  //             _buildNavItem(Icons.home, 'Trang chủ', false),
  //             _buildNavItem(Icons.person, 'Hồ sơ', false),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4f46e5).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4f46e5) : const Color(0xFF64748b),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
              isActive ? const Color(0xFF4f46e5) : const Color(0xFF64748b),
            ),
          ),
        ],
      ),
    );
  }
}

class ClassInfo {
  final String subject;
  final String classCode;
  final String period;
  final String room;
  final String students;
  final String attendance;
  final Color subjectColor;

  ClassInfo({
    required this.subject,
    required this.classCode,
    required this.period,
    required this.room,
    required this.students,
    required this.attendance,
    required this.subjectColor,
  });
}