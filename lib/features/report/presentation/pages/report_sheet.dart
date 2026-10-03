import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/utils/snackbar_utils.dart';
import 'package:kajani/features/report/presentation/state/report_state.dart';
import 'package:kajani/features/report/presentation/view_model/report_view_model.dart';

const _reasons = [
  'Inappropriate profile photo',
  'Offensive username',
  'Harassment or bullying',
  'Spam or scam',
  'Other',
];

void showReportSheet(BuildContext context, {required String reportedUserId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 👈 so keyboard doesn't cover the text field
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      // push content above the keyboard when it opens
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ReportSheetContent(reportedUserId: reportedUserId),
    ),
  );
}

class _ReportSheetContent extends ConsumerStatefulWidget {
  final String reportedUserId;
  const _ReportSheetContent({required this.reportedUserId});

  @override
  ConsumerState<_ReportSheetContent> createState() => _ReportSheetContentState();
}

class _ReportSheetContentState extends ConsumerState<_ReportSheetContent> {
  bool _showOtherInput = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit(String reason, {String? note}) {
    ref.read(reportViewModelProvider.notifier).submitReport(
          reportedUser: widget.reportedUserId,
          reason: reason,
          note: note,
        );
  }

  Future<void> _confirmAndSubmit(BuildContext context, String reason, {String? note}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Report User', style: TextStyle(color: context.textPrimary)),
      content: Text(
        'Report this user for "$reason"? Our team will review it.',
        style: TextStyle(color: context.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Report', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    _submit(reason, note: note);
  }
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportViewModelProvider);

    ref.listen<ReportState>(reportViewModelProvider, (prev, next) {
      if (next.status == ReportStatus.success) {
        Navigator.pop(context);
        SnackbarUtils.showSuccess(context, 'Report submitted. Thank you.');
        ref.read(reportViewModelProvider.notifier).reset();
      } else if (next.status == ReportStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
        ref.read(reportViewModelProvider.notifier).reset();
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: context.borderColor, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Report User',
                style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              _showOtherInput ? 'Describe the issue' : 'Why are you reporting this user?',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (state.status == ReportStatus.loading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_showOtherInput) ...[
              // ─── "Other" text input ────────────────────────
              TextField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 500,
                style: TextStyle(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tell us what happened...',
                  hintStyle: TextStyle(color: context.textTertiary),
                  filled: true,
                  fillColor: context.inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final note = _noteController.text.trim();
                    if (note.isEmpty) {
                      SnackbarUtils.showError(context, 'Please describe the issue');
                      return;
                    }
                    _confirmAndSubmit(context,'Other', note: note);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child:  Text('Submit Report', style: TextStyle(color:context.textPrimary, fontWeight: FontWeight.w600)),
                ),
              ),
            ] else
              // ─── Reason list ───────────────────────────────
              ..._reasons.map((reason) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason, style: TextStyle(color: context.textPrimary, fontSize: 14)),
                    trailing: Icon(Icons.chevron_right, color: context.textTertiary),
                    onTap: () {
                      if (reason == 'Other') {
                        setState(() => _showOtherInput = true); // 
                      } else {
                        _confirmAndSubmit(context, reason); 
                      }
                    },
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}