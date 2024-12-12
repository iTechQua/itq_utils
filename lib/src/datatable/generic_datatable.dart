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
    required this.widthMode,
    required this.tableHeaderDataMap,
    required this.tableRowDataList,
    required this.toMakeTableMapFunction,
    required this.fileName,
    required this.actionBuilder,
    this.height,
    this.pageSize = 10,
  });

  final double? height;
  final Map<String, dynamic> tableHeaderDataMap;
  final List<T> tableRowDataList;
  final Map<String, dynamic> Function(T) toMakeTableMapFunction;
  final Widget Function(T rowData) actionBuilder;
  final int pageSize;
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

    _tableHeader = <GridColumn>[
      GridColumn(
        columnName: 'ID',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'ID',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      ...widget.tableHeaderDataMap.keys.map((String key) {
        return GridColumn(
          columnName: key,
          label: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
      GridColumn(
        columnName: 'Action',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Action',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ];

    _updateTableData();
  }

  @override
  void didUpdateWidget(covariant GenericDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tableRowDataList != oldWidget.tableRowDataList) {
      _filteredData = widget.tableRowDataList;
      _updateTableData();
    }
  }

  void _updateTableData() {
    final int startIndex = _currentPage * _pageSize;
    final int endIndex = startIndex + _pageSize;
    final List<T> currentPageData = _filteredData.sublist(
      startIndex,
      endIndex.clamp(0, _filteredData.length),
    );

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
              value: entry.value,
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

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
      _updateTableData();
    });
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredData = widget.tableRowDataList.where((item) {
        final map = widget.toMakeTableMapFunction(item);
        return map.values.any(
              (value) => value.toString().toLowerCase().contains(_searchQuery),
        );
      }).toList();
      _currentPage = 0;
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
          sheet.getRangeByIndex(i + 2, columnIndex).setValue(value.toString());
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

      await _saveFile(bytes, 'table_data.xlsx');
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

      final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 8,
      );

      const cellStyle = pw.TextStyle(
        fontSize: 7,
      );

      final cellAlignments = {
        0: pw.Alignment.center,
        for (var i = 1; i < headers.length; i++) i: pw.Alignment.centerLeft,
      };

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            pw.TableHelper.fromTextArray(
              headers: tableData[0],
              data: tableData.sublist(1),
              border: pw.TableBorder.all(),
              headerStyle: headerStyle,
              cellStyle: cellStyle,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue600,
              ),
              cellHeight: 25,
              cellAlignments: cellAlignments,
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName = 'table_data_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _saveFile(bytes, fileName);
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
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _saveFileNative(List<int> bytes, String fileName) async {
    final directory = Platform.isWindows || Platform.isLinux || Platform.isMacOS
        ? await getDownloadsDirectory()
        : await getApplicationDocumentsDirectory();

    if (directory == null) {
      throw Exception('Unable to access system directory');
    }

    final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    _showSuccessDialog(filePath, bytes.length);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
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
            const SizedBox(height: 4),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Top bar with Search, Export and Page Size Selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Page Size Selector
              DropdownButton<int>(
                value: _pageSize,
                items: [5, 10, 20, 50]
                    .map((size) => DropdownMenuItem(
                  value: size,
                  child: Text('$size entries'),
                ))
                    .toList(),
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
              const SizedBox(width: 10),
              // Export Button
              PopupMenuButton<String>(
                child: ElevatedButton(
                  child: const Text('Export'),
                  onPressed: null,
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
              // Search Field
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Table
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double tableWidth = _tableHeader.length * 150.0;

            return SizedBox(
              height: widget.height ?? MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: tableWidth > constraints.maxWidth
                        ? tableWidth
                        : constraints.maxWidth,
                  ),
                  child: SfDataGridTheme(
                    data: SfDataGridThemeData(
                      headerColor: Colors.blue,
                      gridLineColor: Colors.grey,
                      gridLineStrokeWidth: 0.1,
                    ),
                    child: SfDataGrid(
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: widget.widthMode,
                      source: GenericDataSource(_tableRowData),
                      columns: _tableHeader,
                      gridLinesVisibility: GridLinesVisibility.both,
                      headerGridLinesVisibility: GridLinesVisibility.both,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Pagination and Footer
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Showing entries info
              Text(
                'Showing ${(_currentPage * _pageSize) + 1} to ${((_currentPage + 1) * _pageSize).clamp(1, _filteredData.length)} of ${_filteredData.length} entries',
              ),
              // Pagination
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () => _changePage(_currentPage - 1)
                        : null,
                  ),
                  Text('Page ${_currentPage + 1}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                    (_currentPage + 1) * _pageSize < _filteredData.length
                        ? () => _changePage(_currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
          return cell.value as Widget;
        }
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            cell.value.toString(),
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }
}