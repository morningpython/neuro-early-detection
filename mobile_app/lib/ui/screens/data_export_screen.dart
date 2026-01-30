/// Data Export Screen
/// STORY-029: Data Export Functionality
///
/// 데이터 내보내기 화면입니다.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/data_export_service.dart';

/// 데이터 내보내기 화면
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final DataExportService _exportService = DataExportService();
  
  ExportFormat _selectedFormat = ExportFormat.csv;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includePatientInfo = true;
  bool _anonymize = false;
  bool _isExporting = false;
  
  List<ExportedFile> _exportedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadExportedFiles();
  }

  Future<void> _loadExportedFiles() async {
    final files = await _exportService.getExportedFiles();
    setState(() {
      _exportedFiles = files;
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart 
        ? _startDate ?? DateTime.now().subtract(const Duration(days: 30))
        : _endDate ?? DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _exportScreenings() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // TODO: 실제 스크리닝 데이터 조회
      final options = ExportOptions(
        format: _selectedFormat,
        startDate: _startDate,
        endDate: _endDate,
        includePatientInfo: _includePatientInfo,
        anonymize: _anonymize,
      );

      // 시뮬레이션 데이터로 테스트
      final result = await _exportService.exportScreenings(
        [], // TODO: 실제 데이터
        options: options,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.recordCount}건 내보내기 완료'),
            action: SnackBarAction(
              label: '열기',
              onPressed: () {
                // TODO: 파일 공유/열기
              },
            ),
          ),
        );
        _loadExportedFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? '내보내기 실패'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 내보내기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExportOptions(),
            const SizedBox(height: 24),
            _buildExportButtons(),
            const SizedBox(height: 32),
            _buildExportedFilesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '내보내기 옵션',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 형식 선택
            Text(
              '형식',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ExportFormat.values.map((format) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(format.label),
                    selected: _selectedFormat == format,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFormat = format;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            
            const Divider(height: 32),
            
            // 날짜 범위
            Text(
              '날짜 범위',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate != null 
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : '시작일',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _endDate != null 
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : '종료일',
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // 추가 옵션
            SwitchListTile(
              title: const Text('환자 정보 포함'),
              subtitle: const Text('이름, 나이, 성별'),
              value: _includePatientInfo,
              onChanged: (value) {
                setState(() {
                  _includePatientInfo = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('익명화'),
              subtitle: const Text('개인정보 마스킹 처리'),
              value: _anonymize,
              onChanged: (value) {
                setState(() {
                  _anonymize = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportScreenings,
          icon: _isExporting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: const Text('스크리닝 데이터 내보내기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isExporting ? null : () {
            // TODO: 의뢰 데이터 내보내기
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('의뢰 데이터 내보내기'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildExportedFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '내보낸 파일',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _loadExportedFiles,
              child: const Text('새로고침'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_exportedFiles.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '내보낸 파일이 없습니다',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_exportedFiles.map((file) => _buildFileItem(file))),
      ],
    );
  }

  Widget _buildFileItem(ExportedFile file) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: file.format == ExportFormat.csv 
              ? Colors.green.withAlpha(30)
              : Colors.orange.withAlpha(30),
          child: Icon(
            file.format == ExportFormat.csv 
                ? Icons.table_chart
                : Icons.code,
            color: file.format == ExportFormat.csv 
                ? Colors.green
                : Colors.orange,
          ),
        ),
        title: Text(
          file.name,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${file.sizeFormatted} • ${DateFormat('yyyy-MM-dd HH:mm').format(file.createdAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('공유'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('삭제', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('파일 삭제'),
                  content: const Text('이 파일을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _exportService.deleteExportedFile(file.path);
                _loadExportedFiles();
              }
            } else if (value == 'share') {
              // TODO: 파일 공유
            }
          },
        ),
      ),
    );
  }
}
