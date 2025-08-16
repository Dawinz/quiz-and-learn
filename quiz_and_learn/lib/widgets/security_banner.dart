import 'package:flutter/material.dart';
import '../security/security_guard.dart';

class SecurityBanner extends StatefulWidget {
  final Widget child;
  final bool showWhenSecure;

  const SecurityBanner({
    super.key,
    required this.child,
    this.showWhenSecure = false,
  });

  @override
  State<SecurityBanner> createState() => _SecurityBannerState();
}

class _SecurityBannerState extends State<SecurityBanner> {
  SecurityStatus? _securityStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    try {
      final securityGuard = SecurityGuard();
      await securityGuard.initialize();
      final status = securityGuard.getSecurityStatus();

      if (mounted) {
        setState(() {
          _securityStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    final shouldShowBanner = widget.showWhenSecure
        ? _securityStatus?.isSecure == false
        : _securityStatus?.isSecure == false;

    if (!shouldShowBanner) {
      return widget.child;
    }

    return Column(
      children: [
        _buildSecurityBanner(),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Limited functionality due to device integrity',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: _showSecurityDetails,
            icon: Icon(
              Icons.info_outline,
              color: Colors.orange.shade700,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showSecurityDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Status'),
        content: _buildSecurityDetails(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityDetails() {
    if (_securityStatus == null) {
      return const Text('Security status not available');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusRow('Overall Security', _securityStatus!.isSecure),
        const SizedBox(height: 8),
        _buildStatusRow('Environment Safe', _securityStatus!.isEnvironmentSafe),
        _buildStatusRow(
            'Attestation Valid', _securityStatus!.isAttestationValid),
        _buildStatusRow(
            'Requires Integrity', _securityStatus!.requiresIntegrity),
        if (_securityStatus!.environmentIssues.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Environment Issues:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ..._securityStatus!.environmentIssues.map((issue) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text('• $issue'),
              )),
        ],
        if (_securityStatus!.lastAttestationTime != null) ...[
          const SizedBox(height: 12),
          Text(
            'Last Attestation: ${_securityStatus!.lastAttestationTime!.toString().substring(0, 19)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Row(
      children: [
        Icon(
          status ? Icons.check_circle : Icons.error,
          color: status ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          status ? 'Pass' : 'Fail',
          style: TextStyle(
            color: status ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
