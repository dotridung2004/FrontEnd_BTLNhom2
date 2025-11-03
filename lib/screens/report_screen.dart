import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting

// 👇 Import models and service
import '../api_service.dart';
import '../table/report_data.dart'; // Make sure this path is correct

class ReportScreen extends StatefulWidget {
  // 👇 ADD userId
  final int userId;
  const ReportScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // --- State Variables ---
  String selectedReportType = 'Báo cáo giảng dạy'; // Keep for UI, backend might ignore
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  bool isCardView = true;
  bool _isBarChart = true; // State for chart type

  final List<String> reportTypes = [
    'Báo cáo giảng dạy',
    'Báo cáo chuyên cần',
    'Báo cáo tổng hợp',
  ];

  // API Service and Data State
  final ApiService _apiService = ApiService();
  ReportData? _reportData; // Store fetched data (nullable)
  bool _isLoading = false;
  String? _errorMessage;

  // Colors for charts (consistent mapping)
  final Map<String, Color> _chartColors = {
    'Tổng buổi': const Color(0xFF3b82f6), // Blue
    'Nghỉ': const Color(0xFFef4444), // Red
    'Dạy bù': const Color(0xFFf59e0b), // Amber
    // Add more colors if your backend chart_data includes more labels
  };
  final Color _defaultChartColor = Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
    // Load initial report for the default date range upon entering the screen
    // <<< SỬA: Không tự động tải lúc khởi động, chờ người dùng nhấn nút
    // _loadReportData();
  }

  // --- API Call Function ---
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error
      _reportData = null; // Clear previous data while loading new data
    });
    try {
      final data =
      await _apiService.fetchReportData(widget.userId, startDate, endDate);
      if (mounted) {
        setState(() {
          _reportData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        final cleanedMessage =
        e.toString().replaceFirst('Exception: ', '').replaceAll('❌ ', '');
        setState(() {
          _errorMessage = cleanedMessage;
        });
        // <<< SỬA: Không hiển thị dialog, chỉ hiển thị lỗi inline
        // _showErrorDialog(cleanedMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Error Dialog (Giữ lại để tham khảo, nhưng không dùng) ---
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.error, color: Colors.red), SizedBox(width: 8), Text("Lỗi!")]),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Đóng", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Keep gradient background
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
              _buildHeader(), // Header remains static
              Expanded(
                child: Container(
                  // White content area
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  // Use RefreshIndicator for pull-to-refresh
                  child: RefreshIndicator(
                    onRefresh: _loadReportData, // Reload data on pull
                    child: SingleChildScrollView(
                      physics:
                      const AlwaysScrollableScrollPhysics(), // Ensure scroll
                      child: Column(
                        children: [
                          _buildFilters(), // Filters remain mostly static

                          // --- SỬA: Thay đổi logic hiển thị ---
                          // Logic mới: Luôn hiển thị các khối UI.
                          // Các hàm con sẽ tự xử lý việc hiển thị placeholder hoặc dữ liệu.

                          _buildStatsCards(), // Luôn hiển thị (sẽ tự xử lý placeholder)

                          _buildChartSection(), // Luôn hiển thị (sẽ tự xử lý placeholder)

                          _buildScheduleSection(), // Luôn hiển thị (sẽ tự xử lý placeholder)

                          // Hiển thị loading hoặc thông báo (nếu có) ở dưới cùng
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_reportData == null && !_isLoading)
                          // Trạng thái ban đầu hoặc lỗi
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 50.0, horizontal: 20.0),
                              child: Center(
                                child: Text(
                                  _errorMessage ??
                                      'Chọn bộ lọc và nhấn "Xem báo cáo" để tải dữ liệu.',
                                  style: TextStyle(
                                      color: _errorMessage != null
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                      fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header (No change needed) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        // Simplified header
        mainAxisAlignment: MainAxisAlignment.center, // Center title
        children: [
          Text(
            'Báo cáo thống kê',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- Filters (Update Button Action) ---
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Type Dropdown (Keep as is)
          const Text('Loại báo cáo',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
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
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xFF1e293b)),
                items: reportTypes.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => selectedReportType = newValue!);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Date Range (Keep as is)
          const Text('Thời gian',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildDateField(startDate, true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child:
                Text('-', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(child: _buildDateField(endDate, false)),
            ],
          ),
          const SizedBox(height: 20),
          // View Report Button (Update onPressed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loadReportData, // 👈 Call API here
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4f46e5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : const Text('Xem báo cáo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Date Field Picker (Keep as is)
  Widget _buildDateField(DateTime date, bool isStart) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          locale: const Locale('vi', 'VN'), // Set locale
        );
        if (picked != null && picked != date) {
          setState(() {
            if (isStart) {
              // Ensure start date is not after end date
              if (picked.isAfter(endDate)) {
                startDate = picked;
                endDate = picked; // Adjust end date if needed
              } else {
                startDate = picked;
              }
            } else {
              // Ensure end date is not before start date
              if (picked.isBefore(startDate)) {
                endDate = picked;
                startDate = picked; // Adjust start date if needed
              } else {
                endDate = picked;
              }
            }
            // Clear data when date changes, forcing reload
            _reportData = null;
            _errorMessage = null;
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
        child: Text(DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // --- SỬA: Stats Cards (Xử lý `_reportData == null`) ---
  Widget _buildStatsCards() {
    // 1. Nếu có dữ liệu, hiển thị dữ liệu
    if (_reportData != null) {
      final summary = _reportData!.summary;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: const Color(0xFFf8fafc), // Light gray background for contrast
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
                summary.totalSessions.toString(),
                'Tổng buổi',
                _chartColors['Tổng buổi'] ?? _defaultChartColor),
            _buildStatCard(summary.absencesCount.toString(), 'Nghỉ',
                _chartColors['Nghỉ'] ?? _defaultChartColor),
            _buildStatCard(
                summary.makeupsCount.toString(),
                'Dạy bù',
                _chartColors['Dạy bù'] ?? _defaultChartColor),
            _buildStatCard('${summary.attendanceRate.toStringAsFixed(1)}%',
                'Chuyên cần', const Color(0xFF10b981)),
          ],
        ),
      );
    }

    // 2. Nếu `_reportData == null`, hiển thị placeholder
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
          _buildStatCardPlaceholder(), // Helper for placeholder
          _buildStatCardPlaceholder(),
          _buildStatCardPlaceholder(),
          _buildStatCardPlaceholder(),
        ],
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildStatCard` (CĂN GIỮA) ---
  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // <<< SỬA ĐỔI ĐỂ CĂN GIỮA
        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- MỚI: Helper cho placeholder của thẻ thống kê (CĂN GIỮA) ---
  Widget _buildStatCardPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // <<< SỬA ĐỔI ĐỂ CĂN GIỮA
        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
        children: [
          Container(
            height: 28, // Giống font size
            width: 50, // xấp xỉ
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16, // Giống font size
            width: 80, // xấp xỉ
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6)),
          ),
        ],
      ),
    );
  }

  // --- SỬA: Chart Section (Xử lý `_reportData == null`) ---
  Widget _buildChartSection() {
    // Kiểm tra dữ liệu bên trong
    final bool hasData =
        _reportData != null && _reportData!.chartData.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biểu đồ thống kê',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b))),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8)),
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
              // Pass dynamic chart data to builders
              child: hasData
                  ? (_isBarChart
                  ? _buildBarChart(_reportData!.chartData)
                  : _buildPieChart(_reportData!.chartData))
                  : _buildChartPlaceholder(), // Hiển thị placeholder
            ),
          ),
        ],
      ),
    );
  }

  // --- MỚI: Helper cho placeholder của biểu đồ ---
  Widget _buildChartPlaceholder() {
    return Center(
      child: Icon(
        _isBarChart ? Icons.bar_chart_outlined : Icons.pie_chart_outline,
        size: 80,
        color: Colors.grey.shade300,
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildChartToggleButton` (thay thế /* ... */) ---
  Widget _buildChartToggleButton(String title, bool isSelected, bool isFirst) {
    return GestureDetector(
      onTap: () => setState(() => _isBarChart = isFirst),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1e293b) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- Bar Chart (Use Dynamic Data) ---
  Widget _buildBarChart(List<ChartDataItem> chartData) {
    // ... (code _buildBarChart giữ nguyên)
    double maxY = 0;
    if (chartData.isNotEmpty) {
      maxY = chartData
          .map((d) => d.value.toDouble())
          .reduce((a, b) => a > b ? a : b);
    }
    maxY = (maxY == 0) ? 10 : (maxY * 1.2).ceilToDouble();

    final barGroups = chartData.asMap().entries.map((entry) {
      int index = entry.key;
      ChartDataItem data = entry.value;
      return _makeGroupData(index, data.value.toDouble(),
          _chartColors[data.label] ?? _defaultChartColor);
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length)
                  return const SizedBox();
                final String text = chartData[index].label;
                final shortText =
                text.length > 8 ? '${text.substring(0, 6)}...' : text;
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(shortText,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: (maxY / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > maxY) return const SizedBox();
                return Text(value.toInt().toString(),
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
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        barGroups: barGroups,
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  // Helper makeGroupData (Keep as is)
  BarChartGroupData _makeGroupData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 22,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }

  // --- Pie Chart (Use Dynamic Data) ---
  Widget _buildPieChart(List<ChartDataItem> chartData) {
    // ... (code _buildPieChart giữ nguyên)
    final pieChartItems =
    chartData.where((d) => d.label != 'Chuyên cần').toList();
    if (pieChartItems.isEmpty)
      return const Center(child: Text("Không có dữ liệu cho biểu đồ tròn"));

    final pieSections = pieChartItems.asMap().entries.map((entry) {
      ChartDataItem data = entry.value;
      return PieChartSectionData(
          value: data.value.toDouble().abs(),
          color: _chartColors[data.label] ?? _defaultChartColor,
          title: data.value.toStringAsFixed(0),
          radius: 60,
          titleStyle: const TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold));
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: pieSections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: true),
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: pieChartItems
              .map((data) => _buildIndicator(
              data.label, _chartColors[data.label] ?? _defaultChartColor))
              .toList(),
        )
      ],
    );
  }

  // Pie chart indicator helper (Keep as is)
  Widget _buildIndicator(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Take minimum space
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // --- SỬA: Schedule Section (Xử lý `_reportData == null`) ---
  Widget _buildScheduleSection() {
    // 1. Dữ liệu có và chi tiết không rỗng
    if (_reportData != null && _reportData!.details.isNotEmpty) {
      final details = _reportData!.details;
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            _buildSectionHeader(), // Header with toggle
            isCardView
                ? _buildCardView(details)
                : _buildTableView(details),
          ],
        ),
      );
    }

    // 2. Dữ liệu có nhưng chi tiết rỗng (đã tải thành công nhưng không có lịch)
    if (_reportData != null && _reportData!.details.isEmpty) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Center(
              child: Text(
                  "Không có lịch dạy chi tiết trong khoảng thời gian này.",
                  style: TextStyle(color: Colors.grey))));
    }

    // 3. Dữ liệu là null (trạng thái ban đầu/placeholder)
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(), // Hiển thị header
          // Hiển thị placeholder cho nội dung
          Container(
            height: 150,
            child: Center(
              child: Icon(
                isCardView
                    ? Icons.list_alt_outlined
                    : Icons.table_rows_outlined,
                size: 60,
                color: Colors.grey.shade300,
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildSectionHeader` (thay thế /* ... */) ---
  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFf1f5f9), // Nền xám nhạt cho header
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Lịch trình chi tiết',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b))),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildToggleButton('Thẻ', isCardView, true), // "Card"
                _buildToggleButton('Bảng', !isCardView, false), // "Table"
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildToggleButton` (thay thế /* ... */) ---
  Widget _buildToggleButton(String label, bool isActive, bool isFirst) {
    return GestureDetector(
      onTap: () => setState(() => isCardView = isFirst),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1e293b) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- Card View (Use Dynamic Data) ---
  Widget _buildCardView(List<ReportDetailItem> details) {
    // ... (code _buildCardView giữ nguyên)
    Map<String, List<ReportDetailItem>> groupedByDate = {};
    for (var item in details) {
      (groupedByDate[item.dateString] ??= []).add(item);
    }
    final sortedKeys = groupedByDate.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sortedKeys.map((dateKey) {
          final itemsForDate = groupedByDate[dateKey]!;
          String dayName = "Thứ ?";
          try {
            final dateParts = dateKey.split('/');
            if (dateParts.length == 2) {
              final year = startDate.year;
              final parsedDate = DateTime.parse(
                  '$year-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}');
              dayName = DateFormat('EEEE', 'vi_VN').format(parsedDate);
            }
          } catch (e) {
            /* Ignore */
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildDayCard(
                dateKey,
                dayName,
                "${itemsForDate.length} buổi",
                "Trung bình",
                Colors.grey.shade300,
                Colors.grey.shade700,
                itemsForDate),
          );
        }).toList(),
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildDayCard` (thay thế /* ... */) ---
  Widget _buildDayCard(
      String date,
      String dayName,
      String totalPeriods,
      String workload,
      Color workloadBg,
      Color workloadColor,
      List<ReportDetailItem> classes,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF1e293b), Color(0xFF334155)]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(dayName,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFFcbd5e1))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(totalPeriods,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: workloadBg,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(workload,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: workloadColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Map through ReportDetailItem list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: classes.map((item) => _buildClassItem(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildClassItem` (thay thế /* ... */) ---
  Widget _buildClassItem(ReportDetailItem item) {
    final subjectColor = _getColorForSubject(item.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Align top
            children: [
              // Subject Chip
              Flexible(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      subjectColor.withOpacity(0.2),
                      subjectColor.withOpacity(0.3)
                    ]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: subjectColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Class Code Chip
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                  item.courseCode.replaceAll('(', '').replaceAll(')', ''),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748b)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Tiết:', item.lessons),
          _buildDetailRow('Phòng:', item.location),
          // Student / Attendance Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SV:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      fontSize: 13)),
              Row(
                children: [
                  Text(item.students,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1e293b),
                          fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFdbeafe),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(item.attendance,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1e40af))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SỬA: Hoàn thiện `_buildDetailRow` (thay thế /* ... */) ---
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                  fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1e293b),
                  fontSize: 13)),
        ],
      ),
    );
  }

  // Helper to get consistent color for subjects (Keep as is)
  Color _getColorForSubject(String subjectName) {
    int hashCode = subjectName.hashCode;
    return Color((hashCode & 0x00FFFFFF) | 0xFF000000).withOpacity(1.0);
  }

  // --- Table View (Use Dynamic Data) ---
  Widget _buildTableView(List<ReportDetailItem> details) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Important for wide tables
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF1e293b)),
        columns: const [
          DataColumn(
              label: Text('Ngày',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Môn học',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Lớp',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Tiết',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Phòng',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('SV',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('%CC',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
        // Build rows dynamically
        rows: details
            .map((item) => _buildDataRow(
            item.dateString,
            item.title,
            item.courseCode.replaceAll('(', '').replaceAll(')', ''),
            item.lessons,
            item.location,
            item.students, // Placeholder from backend
            item.attendance // Placeholder from backend
        ))
            .toList(),
      ),
    );
  }

  // Data Row Helper (Keep as is)
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
}