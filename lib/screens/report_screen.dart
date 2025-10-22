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
    _loadReportData();
  }

  // --- API Call Function ---
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error
      _reportData = null; // Clear previous data while loading new data
    });
    try {
      final data = await _apiService.fetchReportData(widget.userId, startDate, endDate);
      if (mounted) {
        setState(() {
          _reportData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        final cleanedMessage = e.toString().replaceFirst('Exception: ', '').replaceAll('❌ ', '');
        setState(() {
          _errorMessage = cleanedMessage;
        });
        _showErrorDialog(cleanedMessage); // Show dialog on error
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Error Dialog ---
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
                      physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even when content is short
                      child: Column(
                        children: [
                          _buildFilters(), // Filters remain mostly static

                          // --- Dynamic Content Area ---
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          // Don't show error message here, rely on dialog and empty state
                          // else if (_errorMessage != null) ...
                          else if (_reportData != null) ...[ // Show data only if loaded
                            _buildStatsCards(),
                            _buildChartSection(),
                            _buildScheduleSection(),
                            const SizedBox(height: 30), // Reduce bottom padding a bit
                          ]
                          else // Initial state or after error (data is null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
                              child: Center(
                                  child: Text(
                                    _errorMessage ?? 'Chọn bộ lọc và nhấn "Xem báo cáo" hoặc kéo xuống để tải lại.', // Show error or prompt
                                    style: TextStyle(color: _errorMessage != null ? Colors.red : Colors.grey.shade600, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  )
                              ),
                            ),
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
      child: const Row( // Simplified header
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
          const Text('Loại báo cáo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
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
                style: const TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Color(0xFF1e293b)),
                items: reportTypes.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => selectedReportType = newValue!);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Date Range (Keep as is)
          const Text('Thời gian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
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
          // View Report Button (Update onPressed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loadReportData, // 👈 Call API here
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4f46e5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Xem báo cáo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
              if(picked.isAfter(endDate)) {
                startDate = picked;
                endDate = picked; // Adjust end date if needed
              } else {
                startDate = picked;
              }
            } else {
              // Ensure end date is not before start date
              if(picked.isBefore(startDate)) {
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
        child: Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // --- Stats Cards (Use Dynamic Data) ---
  Widget _buildStatsCards() {
    // Ensure data is available before building
    if (_reportData == null) return const SizedBox.shrink();
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
        childAspectRatio: 1.4, // Adjust aspect ratio if needed
        children: [
          // Use data from summary object
          _buildStatCard(summary.totalSessions.toString(), 'Tổng buổi', _chartColors['Tổng buổi'] ?? _defaultChartColor),
          _buildStatCard(summary.absencesCount.toString(), 'Nghỉ', _chartColors['Nghỉ'] ?? _defaultChartColor),
          _buildStatCard(summary.makeupsCount.toString(), 'Dạy bù', _chartColors['Dạy bù'] ?? _defaultChartColor),
          _buildStatCard('${summary.attendanceRate.toStringAsFixed(1)}%', 'Chuyên cần', const Color(0xFF10b981)), // Specific color for rate
        ],
      ),
    );
  }
  // Stat Card helper (Keep as is)
  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFf1f5f9)),
        boxShadow: [ BoxShadow( /* ... */ ) ],
      ),
      child: Column( /* ... content ... */ ),
    );
  }

  // --- Chart Section (Use Dynamic Data) ---
  Widget _buildChartSection() {
    // Ensure data is available
    if (_reportData == null || _reportData!.chartData.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow( /* ... */ ) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biểu đồ thống kê', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
              // Toggle buttons (keep as is)
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
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
              child: _isBarChart
                  ? _buildBarChart(_reportData!.chartData)
                  : _buildPieChart(_reportData!.chartData),
            ),
          ),
        ],
      ),
    );
  }
  // Chart toggle button helper (Keep as is)
  Widget _buildChartToggleButton(String title, bool isSelected, bool isFirst) {
    return GestureDetector(
      onTap: () => setState(() => _isBarChart = isFirst),
      child: Container( /* ... style ... */ ),
    );
  }

  // --- Bar Chart (Use Dynamic Data) ---
  Widget _buildBarChart(List<ChartDataItem> chartData) {

    // Find max value for maxY scaling
    double maxY = 0;
    if (chartData.isNotEmpty) {
      maxY = chartData.map((d) => d.value.toDouble()).reduce((a, b) => a > b ? a : b);
    }
    // Ensure maxY is at least a small number to avoid division by zero or weird scales
    maxY = (maxY == 0) ? 10 : (maxY * 1.2).ceilToDouble(); // Add 20% buffer or default to 10

    final barGroups = chartData.asMap().entries.map((entry) {
      int index = entry.key;
      ChartDataItem data = entry.value;
      return _makeGroupData(
          index,
          data.value.toDouble(),
          _chartColors[data.label] ?? _defaultChartColor // Use mapped color
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY, // Dynamic maxY
        barTouchData: BarTouchData(enabled: true), // Enable touch for tooltips
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) return const SizedBox();
                final String text = chartData[index].label; // Use dynamic label
                // Abbreviate long labels if needed
                final shortText = text.length > 8 ? '${text.substring(0, 6)}...' : text;
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(shortText, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              // Calculate interval dynamically, ensuring at least 1
              interval: (maxY / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > maxY) return const SizedBox();
                return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        barGroups: barGroups, // Use dynamic groups
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
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }

  // --- Pie Chart (Use Dynamic Data) ---
  Widget _buildPieChart(List<ChartDataItem> chartData) {
    // Filter out items not suitable for sum pie (like percentages)
    final pieChartItems = chartData.where((d) => d.label != 'Chuyên cần').toList();
    // If no data left after filtering, show empty
    if (pieChartItems.isEmpty) return const Center(child: Text("Không có dữ liệu cho biểu đồ tròn"));


    final pieSections = pieChartItems.asMap().entries.map((entry) {
      // int index = entry.key; // Not needed directly for sections
      ChartDataItem data = entry.value;
      return PieChartSectionData(
          value: data.value.toDouble().abs(), // Use absolute value for chart size
          color: _chartColors[data.label] ?? _defaultChartColor,
          title: data.value.toStringAsFixed(0), // Show integer value
          radius: 60,
          titleStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: pieSections, // Use dynamic sections
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: true), // Enable touch
            ),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        const SizedBox(height: 16),
        // Dynamic Indicators
        Wrap( // Use Wrap for flexibility if many items
          alignment: WrapAlignment.center,
          spacing: 16, // Horizontal space
          runSpacing: 8, // Vertical space if wraps
          children: pieChartItems.map((data) =>
              _buildIndicator(data.label, _chartColors[data.label] ?? _defaultChartColor)
          ).toList(),
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

  // --- Schedule Section (Use Dynamic Data) ---
  Widget _buildScheduleSection() {
    // Ensure data is available
    if (_reportData == null || _reportData!.details.isEmpty) {
      // Show a message if details are empty
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [ BoxShadow( /* ... */ ) ],
          ),
          child: const Center(child: Text("Không có lịch dạy chi tiết trong khoảng thời gian này.", style: TextStyle(color: Colors.grey)))
      );
    }
    final details = _reportData!.details;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow( /* ... */ ) ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(), // Header with toggle (keep as is)
          // Conditional view based on toggle and dynamic data
          isCardView
              ? _buildCardView(details)
              : _buildTableView(details),
        ],
      ),
    );
  }
  // Section header helper (Keep as is)
  Widget _buildSectionHeader() {
    return Container( /* ... original style ... */
      child: Row( /* ... original content ... */ ),
    );
  }
  // Toggle button helper (Keep as is)
  Widget _buildToggleButton(String label, bool isActive, bool isFirst) {
    return GestureDetector(
      onTap: () => setState(() => isCardView = isFirst),
      child: Container( /* ... original style ... */ ),
    );
  }


  // --- Card View (Use Dynamic Data) ---
  Widget _buildCardView(List<ReportDetailItem> details) {
    // --- Grouping by Date ---
    Map<String, List<ReportDetailItem>> groupedByDate = {};
    for (var item in details) {
      // Use dateString (dd/mm) as the key for grouping cards
      (groupedByDate[item.dateString] ??= []).add(item);
    }
    // Sort keys if needed (optional, depends on backend order)
    final sortedKeys = groupedByDate.keys.toList(); // ..sort(...);


    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        // Build cards dynamically based on grouped data
        children: sortedKeys.map((dateKey) {
          final itemsForDate = groupedByDate[dateKey]!;
          // Get full day name from the first item (assuming backend provides consistent format)
          // This requires parsing the date - might be better if backend provided day name directly
          String dayName = "Thứ ?"; // Default
          try {
            // Assuming backend uses d/m format for dateString - adjust if different
            final dateParts = dateKey.split('/');
            if (dateParts.length == 2) {
              // We need year for DateTime parsing - use the selected range's start year as approximation
              final year = startDate.year;
              final parsedDate = DateTime.parse('$year-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}');
              dayName = DateFormat('EEEE', 'vi_VN').format(parsedDate);
            }
          } catch (e) { /* Ignore parsing errors, keep default */}


          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildDayCard(
                dateKey, // Use dd/mm from group key
                dayName, // Derived day name
                "${itemsForDate.length} buổi", // Count of sessions
                // Workload placeholders - Adapt if backend provides data
                "Trung bình", Colors.grey.shade300, Colors.grey.shade700,
                itemsForDate // Pass the list of items for this date
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Day Card (Adapt to use ReportDetailItem) ---
  Widget _buildDayCard(
      String date,
      String dayName,
      String totalPeriods, // Now represents session count
      String workload,
      Color workloadBg,
      Color workloadColor,
      List<ReportDetailItem> classes, // Use ReportDetailItem
      ) {
    // Keep outer structure
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Column(
        children: [
          // Header section (keep as is, uses passed-in values)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1e293b), Color(0xFF334155)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row( /* ... original header content using passed params ... */ ),
          ),
          // Map through ReportDetailItem list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: classes.map((item) => _buildClassItem(item)).toList(), // Pass ReportDetailItem
            ),
          ),
        ],
      ),
    );
  }

  // --- Class Item (Adapt to use ReportDetailItem) ---
  // Remove the separate ClassInfo class definition at the bottom
  Widget _buildClassItem(ReportDetailItem item) { // Use ReportDetailItem
    // Define subject color based on title or use a default
    final subjectColor = _getColorForSubject(item.title); // Use helper for color

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: [ BoxShadow( /* ... */ ) ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Align top
            children: [
              // Subject Chip (Allow wrapping)
              Flexible( // Wrap to prevent overflow
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [subjectColor.withOpacity(0.2), subjectColor.withOpacity(0.3)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.title, // Use item.title
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subjectColor),
                    // overflow: TextOverflow.ellipsis, // Let Flexible handle wrapping
                  ),
                ),
              ),
              const SizedBox(width: 8), // Add spacing
              // Class Code Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration( color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(8) ),
                child: Text(
                  item.courseCode.replaceAll('(', '').replaceAll(')', ''), // Use item.courseCode (remove brackets)
                  style: const TextStyle( fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748b)), // Slightly smaller
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Tiết:', item.lessons), // Use item.lessons
          _buildDetailRow('Phòng:', item.location), // Use item.location
          // Student / Attendance Row (Using placeholders from backend for now)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SV:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13)),
              Row(
                children: [
                  Text(item.students, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1e293b), fontSize: 13)), // Use item.students
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFdbeafe), borderRadius: BorderRadius.circular(12)),
                    child: Text(item.attendance, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1e40af))), // Use item.attendance
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  // Detail Row Helper (Keep as is)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row( /* ... original ... */ ),
    );
  }
  // Helper to get consistent color for subjects (example)
  Color _getColorForSubject(String subjectName) {
    // Simple hash-based color generation for consistency
    int hashCode = subjectName.hashCode;
    return Color((hashCode & 0x00FFFFFF) | 0xFF000000).withOpacity(1.0);
  }


  // --- Table View (Use Dynamic Data) ---
  Widget _buildTableView(List<ReportDetailItem> details) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Important for wide tables
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFF1e293b)),
        columns: const [ // Keep columns definitions
          DataColumn(label: Text('Ngày', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Môn học', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Lớp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Tiết', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Phòng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('SV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), // Placeholder
          DataColumn(label: Text('%CC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), // Placeholder
        ],
        // Build rows dynamically
        rows: details.map((item) => _buildDataRow(
            item.dateString,
            item.title,
            item.courseCode.replaceAll('(', '').replaceAll(')', ''),
            item.lessons,
            item.location,
            item.students, // Placeholder from backend
            item.attendance // Placeholder from backend
        )).toList(),
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
      DataCell(Text(attendance, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
    ]);
  }

}

// Remove the standalone ClassInfo class definition
// class ClassInfo { /* ... */ }