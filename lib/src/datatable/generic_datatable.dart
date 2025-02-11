// generic_datatable.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:universal_html/html.dart' as html;

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredData = widget.tableRowDataList;
    _pageSize = widget.pageSize;
    _initializeTableHeaders();
    _updateTableData();
  }

  Widget _buildDataTable(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: SfDataGridTheme(
            data: SfDataGridThemeData(
              headerColor: const Color(0xFF2196F3),
              gridLineColor: widget.gridLineColor ?? Colors.grey.shade300,
              gridLineStrokeWidth: 1,
            ),
            child: _filteredData.isEmpty
                ? Stack(
              children: [
                SfDataGrid(
                  source: GenericDataSource([]),
                  columns: _tableHeader,
                  rowHeight: 45,
                  headerRowHeight: 45,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columnWidthMode: ColumnWidthMode.fill,
                ),
                Positioned.fill(
                  top: 45, // Height of header
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No data available'
                            : 'No matching records found',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            )
                : SfDataGrid(
              source: GenericDataSource(_tableRowData),
              columns: _tableHeader,
              rowHeight: 45,
              headerRowHeight: 45,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: ColumnWidthMode.fill,
            ),
          ),
        );
      },
    );
  }

// Also update the _initializeTableHeaders method to use proportional widths
  void _initializeTableHeaders() {
    _tableHeader = <GridColumn>[
      GridColumn(
        columnName: 'ID',
        columnWidthMode: ColumnWidthMode.fill,
        minimumWidth: 60,
        maximumWidth: 80,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          child: const Text(
            'ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
      ...widget.tableHeaderDataMap.keys.map((String key) {
        double minimumWidth = 100;
        double maximumWidth = double.infinity;

        return GridColumn(
          columnName: key,
          columnWidthMode: ColumnWidthMode.fill,
          minimumWidth: minimumWidth,
          maximumWidth: maximumWidth,
          label: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
      GridColumn(
        columnName: 'Action',
        columnWidthMode: ColumnWidthMode.fill,
        minimumWidth: 100,
        maximumWidth: 120,
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16),
          child: const Text(
            'Action',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ];
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
          DataGridCell<int>(columnName: 'ID', value: startIndex + index + 1),
          ...widget
              .toMakeTableMapFunction(item)
              .entries
              .map((MapEntry<String, dynamic> entry) {
            return DataGridCell<dynamic>(
              columnName: entry.key,
              value: entry.value ?? '',
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
      sheet.getRangeByIndex(1, 1).setText('ID');
      var columnIndex = 2;
      for (final key in widget.tableHeaderDataMap.keys) {
        sheet.getRangeByIndex(1, columnIndex).setText(key);
        columnIndex++;
      }

      // Add data
      for (var i = 0; i < _filteredData.length; i++) {
        columnIndex = 1;
        sheet.getRangeByIndex(i + 2, columnIndex).setValue(i + 1);
        columnIndex++;

        final rowData = widget.toMakeTableMapFunction(_filteredData[i]);
        for (final value in rowData.values) {
          sheet
              .getRangeByIndex(i + 2, columnIndex)
              .setValue(value?.toString() ?? '');
          columnIndex++;
        }
      }

      // Auto-fit columns
      sheet.autoFitColumn(1);
      for (var i = 1; i <= widget.tableHeaderDataMap.length; i++) {
        sheet.autoFitColumn(i + 1);
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

      final headers = ['ID', ...widget.tableHeaderDataMap.keys];
      final tableData = [
        headers,
        ..._filteredData.asMap().entries.map(
              (entry) => [
            (entry.key + 1).toString(),
            ...widget
                .toMakeTableMapFunction(entry.value)
                .values
                .map((e) => e?.toString() ?? ''),
          ],
        ),
      ];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            pw.TableHelper.fromTextArray(
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
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
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
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            child: const Text('OK'),
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
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File saved successfully!'),
            const SizedBox(height: 8),
            Text('Location: $filePath'),
            Text('Size: ${(fileSize / 1024).toStringAsFixed(2)} KB'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (_filteredData.length / _pageSize).ceil();
    final int currentEntryStart =
    _filteredData.isEmpty ? 0 : (_currentPage * _pageSize) + 1;
    final int currentEntryEnd =
    (_currentPage + 1) * _pageSize > _filteredData.length
        ? _filteredData.length
        : (_currentPage + 1) * _pageSize;

    return Column(
      children: <Widget>[
        _buildTopBar(),
        _buildDataTable(context),
        if (_filteredData.isNotEmpty)
          _buildPagination(currentEntryStart, currentEntryEnd, totalPages),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [

          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    hoverColor: Colors.transparent,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<int>(
                        value: _pageSize,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        iconSize: 20,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return [5, 10, 20, 50].map<Widget>((int value) {
                            return Container(
                              padding: const EdgeInsets.only(right: 8),
                              alignment: Alignment.center,
                              child: Text(
                                '$value',
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: [5, 10, 20, 50].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (size) {
                          if (size != null) {
                            setState(() {
                              _pageSize = size;
                              _currentPage = 0;
                              _updateTableData();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Export',
                style: TextStyle(color: Colors.white),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'excel',
                child: const Text('Export to Excel'),
                onTap: _exportToExcel,
              ),
              PopupMenuItem(
                value: 'pdf',
                child: const Text('Export to PDF'),
                onTap: _exportToPdf,
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(
      int currentEntryStart, int currentEntryEnd, int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $currentEntryStart to $currentEntryEnd of ${_filteredData.length} entries',
            style: const TextStyle(fontSize: 14),
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
                  style: const TextStyle(fontSize: 14),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class GenericDataSource extends DataGridSource {
  GenericDataSource(this._dataSource);

  final List<DataGridRow> _dataSource;

  @override
  List<DataGridRow> get rows => _dataSource;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((DataGridCell cell) {
        if (cell.value is Widget) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: cell.value as Widget,
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            cell.value?.toString() ?? '',
            style: const TextStyle(
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
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    if (a == null || b == null) return 0;

    final aValue = a
        .getCells()
        .firstWhere((cell) => cell.columnName == sortColumn.name)
        .value;
    final bValue = b
        .getCells()
        .firstWhere((cell) => cell.columnName == sortColumn.name)
        .value;

    if (aValue == null || bValue == null) return 0;

    if (aValue is num && bValue is num) {
      return sortColumn.sortDirection == DataGridSortDirection.ascending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    }

    return sortColumn.sortDirection == DataGridSortDirection.ascending
        ? aValue.toString().compareTo(bValue.toString())
        : bValue.toString().compareTo(aValue.toString());
  }
}
