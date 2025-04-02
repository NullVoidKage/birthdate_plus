import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/premium_service.dart';
import '../../services/in_app_purchase_service.dart';

class PremiumModal extends StatefulWidget {
  final VoidCallback onUpgrade;

  const PremiumModal({
    Key? key,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  _PremiumModalState createState() => _PremiumModalState();
}

class _PremiumModalState extends State<PremiumModal> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    await _purchaseService.initialize();
  }

  Future<void> _handleUpgrade(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _purchaseService.buyPremium();
      // The purchase will be handled by the purchase stream listener
      // and will automatically activate premium when successful
    } catch (e) {
      setState(() {
        _error = 'Error processing purchase: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRestorePurchases(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _purchaseService.restorePurchases();
      // The restore will be handled by the purchase stream listener
      // and will automatically activate premium when successful
    } catch (e) {
      setState(() {
        _error = 'Error restoring purchases: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback to English strings if localization is not available
      return AlertDialog(
        title: Text('Premium Features'),
        content: Text('Unlock all premium features to enhance your experience.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: widget.onUpgrade,
            child: Text('Upgrade'),
          ),
        ],
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple.shade500, Colors.blue.shade500],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.upgradeToPremium,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    icon: Icons.remove_circle_outline,
                    title: l10n.removeWatermark,
                    description: l10n.removeWatermarkDescription,
                    isDarkMode: isDarkMode,
                  ),
                  SizedBox(height: 24),
                  _buildFeatureItem(
                    icon: Icons.high_quality,
                    title: l10n.highQualityExport,
                    description: l10n.highQualityExportDescription,
                    isDarkMode: isDarkMode,
                  ),
                  SizedBox(height: 24),
                  _buildFeatureItem(
                    icon: Icons.block,
                    title: l10n.adFreeExperience,
                    description: l10n.adFreeExperienceDescription,
                    isDarkMode: isDarkMode,
                  ),
                  SizedBox(height: 32),
                  
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  // Upgrade button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : () => _handleUpgrade(context),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.upgradeNowWithPrice,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Restore purchases button
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => _handleRestorePurchases(context),
                      child: Text(
                        l10n.restorePurchases,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.purple.withOpacity(0.2) : Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.purple.shade200 : Colors.purple,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
} 