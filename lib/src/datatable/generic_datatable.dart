import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:universal_html/html.dart' as html;
import 'package:google_fonts/google_fonts.dart';

class GenericDataTable<T> extends StatefulWidget {
  const GenericDataTable({
    super.key,
    this.headerColor = const Color(0xFF2196F3),
    this.gridLineColor,
    required this.widthMode,
    required this.tableHeaderDataMap,
    required this.tableRowDataList,
    required this.toMakeTableMapFunction,
    required this.fileName,
    required this.actionBuilder,
    this.pageSize = 10,
    this.cellBuilders,
    this.columnSizes,
    this.onSort,
    this.showCheckboxColumn = false,
    this.selectedItems,
    this.onSelectItem,
    this.customHeaderBuilders,
    this.minWidth,
    this.rowHeight = 45,
    this.headerHeight = 45,
  });

  final Map<String, dynamic> tableHeaderDataMap;
  final List<T> tableRowDataList;
  final Map<String, dynamic> Function(T) toMakeTableMapFunction;
  final Widget Function(T rowData) actionBuilder;
  final int pageSize;
  final Color headerColor;
  final Color? gridLineColor;
  final ColumnWidthMode widthMode;
  final String fileName;
  final Map<String, Widget Function(dynamic value, T rowData)>? cellBuilders;
  final Map<String, double>? columnSizes;
  final Function(String column, bool ascending)? onSort;
  final bool showCheckboxColumn;
  final List<T>? selectedItems;
  final Function(bool?, T)? onSelectItem;
  final Map<String, Widget Function(String columnName)>? customHeaderBuilders;
  final double? minWidth;
  final int rowHeight;
  final double headerHeight;

  @override
  GenericDataTableState<T> createState() => GenericDataTableState<T>();
}

class GenericDataTableState<T> extends State<GenericDataTable<T>> {
  late List<DataGridRow> _tableRowData;
  late List<GridColumn> _tableHeader;
  late TextEditingController _searchController;
  int _currentPage = 0;
  int _pageSize = 10;
  String _searchQuery = '';
  late List<T> _filteredData;
  String? _sortColumn;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredData = List.from(widget.tableRowDataList);
    _pageSize = widget.pageSize;
    _initializeTableHeaders();
    _updateTableData();
  }

  void _initializeTableHeaders() {
    _tableHeader = <GridColumn>[
      if (widget.showCheckboxColumn)
        GridColumn(
          columnName: 'checkbox',
          width: 50,
          columnWidthMode: ColumnWidthMode.none,
          label: _buildSelectionHeader(),
        ),
      GridColumn(
        columnName: 'S. No.',
        width: widget.columnSizes?['S. No.'] ?? 100,
        columnWidthMode: widget.widthMode,
        label: _buildHeaderCell('S. No.'),
      ),
      ...widget.tableHeaderDataMap.keys.map((String key) {
        return GridColumn(
          columnName: key,
          width: widget.columnSizes![key]!,
          columnWidthMode: widget.widthMode,
          label: _buildHeaderCell(key),
          allowSorting: true,
        );
      }),
      GridColumn(
        columnName: 'Action',
        width: widget.columnSizes?['Action'] ?? 120,
        columnWidthMode: widget.widthMode,
        label: _buildHeaderCell('Action'),
      ),
    ];
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Checkbox(
        value: _areAllItemsSelected(),
        onChanged: _onSelectAllItems,
        activeColor: widget.headerColor,
      ),
    );
  }

  Widget _buildHeaderCell(String columnName) {
    if (widget.customHeaderBuilders?.containsKey(columnName) ?? false) {
      return widget.customHeaderBuilders![columnName]!(columnName);
    }

    return GestureDetector(
      onTap: () => _handleSort(columnName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                columnName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (_sortColumn == columnName)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  void _updateTableData() {
    if (_filteredData.isEmpty) {
      _tableRowData = [];
      return;
    }

    final int startIndex = _currentPage * _pageSize;
    final int endIndex =
    (startIndex + _pageSize).clamp(0, _filteredData.length);

    if (startIndex >= _filteredData.length) {
      _currentPage = (_filteredData.length - 1) ~/ _pageSize;
      return _updateTableData();
    }

    final List<T> currentPageData = _filteredData.sublist(startIndex, endIndex);

    _tableRowData = currentPageData.asMap().entries.map((entry) {
      final int index = entry.key;
      final T item = entry.value;

      return DataGridRow(
        cells: <DataGridCell>[
          if (widget.showCheckboxColumn)
            DataGridCell<Widget>(
              columnName: 'checkbox',
              value: Checkbox(
                value: widget.selectedItems?.contains(item) ?? false,
                onChanged: (bool? value) {
                  if (widget.onSelectItem != null) {
                    widget.onSelectItem!(value, item);
                  }
                },
              ),
            ),
          DataGridCell<int>(columnName: 'S. No.', value: startIndex + index + 1),
          ...widget.toMakeTableMapFunction(item).entries.map((entry) {
            return DataGridCell<dynamic>(
              columnName: entry.key,
              value: widget.cellBuilders?.containsKey(entry.key) ?? false
                  ? widget.cellBuilders![entry.key]!(entry.value, item)
                  : entry.value,
            );
          }),
          DataGridCell<Widget>(
            columnName: 'Action',
            value: widget.actionBuilder(item),
          ),
        ],
      );
    }).toList();
  }

  bool _areAllItemsSelected() {
    if (widget.selectedItems == null || _filteredData.isEmpty) return false;
    return widget.selectedItems!.length == _filteredData.length &&
        _filteredData.every((item) => widget.selectedItems!.contains(item));
  }

  void _onSelectAllItems(bool? selected) {
    if (selected == null || widget.onSelectItem == null) return;
    for (var item in _filteredData) {
      widget.onSelectItem!(selected, item);
    }
  }

  void _handleSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }

      if (widget.onSort != null) {
        widget.onSort!(_sortColumn!, _sortAscending);
      } else {
        _filteredData.sort((a, b) {
          final aValue = widget.toMakeTableMapFunction(a)[column];
          final bValue = widget.toMakeTableMapFunction(b)[column];

          if (aValue == null || bValue == null) return 0;

          final comparison = aValue.toString().compareTo(bValue.toString());
          return _sortAscending ? comparison : -comparison;
        });
      }

      _updateTableData();
    });
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredData = widget.tableRowDataList.where((item) {
        final map = widget.toMakeTableMapFunction(item);
        return map.values.any(
              (value) =>
          value?.toString().toLowerCase().contains(_searchQuery) ?? false,
        );
      }).toList();
      _currentPage = 0;
      _updateTableData();
    });
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildPageSizeDropdown(),
          const SizedBox(width: 16),
          _buildExportButton(),
          const Spacer(),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildPageSizeDropdown() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<int>(
            value: _pageSize,
            items: [5, 10, 20, 50].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _pageSize = value;
                  _currentPage = 0;
                  _updateTableData();
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6D28D9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Export',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'excel',
          child: Text('Export to Excel', style: GoogleFonts.poppins()),
          onTap: _exportToExcel,
        ),
        PopupMenuItem(
          value: 'pdf',
          child: Text('Export to PDF', style: GoogleFonts.poppins()),
          onTap: _exportToPdf,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _searchController,
        onChanged: _filterData,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final int totalPages = (_filteredData.length / _pageSize).ceil();
    final int startEntry = _currentPage * _pageSize + 1;
    final int endEntry =
    math.min((_currentPage + 1) * _pageSize, _filteredData.length);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $startEntry to $endEntry of ${_filteredData.length} entries',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 0 ? () => _changePage(0) : null,
                tooltip: 'First Page',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => _changePage(_currentPage - 1)
                    : null,
                tooltip: 'Previous Page',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Page ${_currentPage + 1} of $totalPages',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages - 1
                    ? () => _changePage(_currentPage + 1)
                    : null,
                tooltip: 'Next Page',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < totalPages - 1
                    ? () => _changePage(totalPages - 1)
                    : null,
                tooltip: 'Last Page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _changePage(int page) {
    if (page < 0 || page * _pageSize >= _filteredData.length) return;
    setState(() {
      _currentPage = page;
      _updateTableData();
    });
  }

  Future<void> _exportToExcel() async {
    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];

      // Add headers
      sheet.getRangeByIndex(1, 1).setText('S. No.');
      var columnIndex = 2;
      for (final key in widget.tableHeaderDataMap.keys) {
        sheet.getRangeByIndex(1, columnIndex).setText(key);
        columnIndex++;
      }

      // Style headers
      final headerRange = sheet.getRangeByIndex(1, 1, 1, columnIndex - 1);
      headerRange.cellStyle.bold = true;
      headerRange.cellStyle.backColor = '#2196F3';
      headerRange.cellStyle.fontColor = '#FFFFFF';

      // Add data
      for (var i = 0; i < _filteredData.length; i++) {
        columnIndex = 1;
        sheet.getRangeByIndex(i + 2, columnIndex).setValue(i + 1);
        columnIndex++;

        final rowData = widget.toMakeTableMapFunction(_filteredData[i]);
        for (final value in rowData.values) {
          if (value is Widget) {
            sheet.getRangeByIndex(i + 2, columnIndex).setValue('');
          } else {
            sheet
                .getRangeByIndex(i + 2, columnIndex)
                .setValue(value?.toString() ?? '');
          }
          columnIndex++;
        }
      }

      // Auto-fit columns
      for (var i = 1; i <= columnIndex - 1; i++) {
        sheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      await _saveFile(bytes, '${widget.fileName}.xlsx');
    } catch (e) {
      _showErrorDialog('Export Error', e.toString());
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      final headers = ['S. No.', ...widget.tableHeaderDataMap.keys];
      final tableData = [
        headers,
        ..._filteredData.asMap().entries.map(
              (entry) => [
            (entry.key + 1).toString(),
            ...widget
                .toMakeTableMapFunction(entry.value)
                .values
                .map((e) => e is Widget ? '' : e?.toString() ?? ''),
          ],
        ),
      ];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(widget.fileName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: tableData[0],
              data: tableData.sublist(1),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue600,
              ),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.center,
                for (var i = 1; i < headers.length; i++)
                  i: pw.Alignment.centerLeft,
              },
              columnWidths: {
                0: const pw.IntrinsicColumnWidth(flex: 1),
                for (var i = 1; i < headers.length; i++)
                  i: const pw.IntrinsicColumnWidth(flex: 3),
              },
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      await _saveFile(bytes, '${widget.fileName}.pdf');
    } catch (e) {
      _showErrorDialog('PDF Export Error', e.toString());
    }
  }

  Future<void> _saveFile(List<int> bytes, String fileName) async {
    try {
      if (kIsWeb) {
        await _saveFileWeb(bytes, fileName);
      } else {
        await _saveFileNative(bytes, fileName);
      }
    } catch (e) {
      _showErrorDialog('Save Error', e.toString());
    }
  }

  Future<void> _saveFileWeb(List<int> bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _saveFileNative(List<int> bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    _showSuccessDialog(file.path, bytes.length);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Text(message, style: GoogleFonts.poppins()),
        ),
        actions: [
          TextButton(
            child: Text('OK', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String filePath, int fileSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Successful',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File saved successfully!', style: GoogleFonts.poppins()),
            const SizedBox(height: 8),
            Text('Location: $filePath',
                style: GoogleFonts.poppins(fontSize: 12)),
            Text('Size: ${(fileSize / 1024).toStringAsFixed(2)} KB',
                style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate total width based on column sizes
            double totalWidth = (widget.columnSizes?.values.fold<double>(0.0, (sum, width) => sum + width) ?? 0.0);

            return SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: _filteredData.isEmpty
                          ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No data available'
                                : 'No matching records found',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      )
                          : SizedBox(
                        width: totalWidth,
                        child: _buildDataTable(context),
                      ),
                    ),
                  ),
                  if (_filteredData.isNotEmpty) _buildPagination(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200), // Add minimum height
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          headerColor: widget.headerColor,
          gridLineColor: widget.gridLineColor ?? Colors.grey.shade300,
          gridLineStrokeWidth: 1,
        ),
        child: SfDataGrid(
          source: EnhancedDataSource(_tableRowData),
          columns: _tableHeader,
          allowSorting: true,
          rowHeight: widget.rowHeight.toDouble(),
          headerRowHeight: widget.headerHeight,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columnWidthMode: widget.widthMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class EnhancedDataSource<T> extends DataGridSource {
  EnhancedDataSource(
      this._dataSource,
      );

  final List<DataGridRow> _dataSource;

  @override
  List<DataGridRow> get rows => _dataSource;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'checkbox') {
          return Container(
            alignment: Alignment.center,
            child: cell.value,
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: cell.value is Widget
              ? cell.value as Widget
              : Text(
            cell.value?.toString() ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    return true;
  }

  @override
  bool shouldRecalculateColumnWidths() => true;
}
