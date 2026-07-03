import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scheme_model.dart';
import '../viewmodels/scheme_list_view_model.dart';
import '../viewmodels/login_view_model.dart';
import '../theme/app_theme.dart';
import '../services/session_manager.dart';
import 'login_screen.dart';
import 'scheme_detail_screen.dart';

/// Returns a greeting string based on current IST (UTC+5:30) time.
String _getISTGreeting() {
  // Compute IST offset: UTC + 5 hours 30 minutes
  final utcNow = DateTime.now().toUtc();
  final ist = utcNow.add(const Duration(hours: 5, minutes: 30));
  final hour = ist.hour;
  if (hour >= 5 && hour < 12) {
    return 'Good morning ☀️';
  } else if (hour >= 12 && hour < 17) {
    return 'Good afternoon 🌤️';
  } else if (hour >= 17 && hour < 21) {
    return 'Good evening 🌇';
  } else {
    return 'Good night 🌙';
  }
}

class SchemeListScreen extends StatefulWidget {
  const SchemeListScreen({super.key});

  @override
  State<SchemeListScreen> createState() => _SchemeListScreenState();
}

class _SchemeListScreenState extends State<SchemeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load schemes on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchemeListViewModel>().loadSchemes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to sign out from FundBrowser?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await context.read<LoginViewModel>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = context.watch<SchemeListViewModel>();
    final loginViewModel = context.watch<LoginViewModel>();

    final headerGradientStart = isDark 
        ? AppTheme.headerGradientStartDark 
        : AppTheme.headerGradientStartLight;
    final headerGradientEnd = isDark 
        ? AppTheme.headerGradientEndDark 
        : AppTheme.headerGradientEndLight;

    return SessionTimeoutWrapper(
      timeoutDuration: const Duration(minutes: 5),
      onTimeout: () async {
        if (!mounted) return;
        // Capture context-dependent references before any async gap
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final loginVM = context.read<LoginViewModel>();
        final navigator = Navigator.of(context);

        // Show a snackbar informing the user
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.lock_clock, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Session expired due to inactivity.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1565C0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        await loginVM.logout();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        body: SafeArea(
          top: false, // Let header draw behind status bar
          child: Column(
          children: [
            // Custom Header matching Screenshot 2 second image
            Container(
              padding: const EdgeInsets.only(
                top: 50.0,
                bottom: 24.0,
                left: 20.0,
                right: 20.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [headerGradientStart, headerGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with greeting and user avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getISTGreeting(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mutual Funds',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      // Interactive Profile Avatar (Tapping launches logout dialog)
                      GestureDetector(
                        onTap: () => _confirmLogout(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            loginViewModel.avatarInitials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {});
                        viewModel.setSearchQuery(val);
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: false, // Prevents global lightInputBg theme override
                        hintText: 'Search schemes...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  viewModel.setSearchQuery('');
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Category horizontal pill items row
            const SizedBox(height: 16),
            _buildCategoryRow(viewModel, isDark),
            const SizedBox(height: 8),

            if (viewModel.isOfflineMode) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.shade600.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 16,
                      color: isDark ? Colors.amber.shade400 : Colors.amber.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Running offline (showing cached funds)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],

            Expanded(
              child: _buildMainContent(viewModel, isDark),
            ),
          ],
        ),
      ),
    ),
    );
  }

  // Categories row widget Builder
  Widget _buildCategoryRow(SchemeListViewModel viewModel, bool isDark) {
    final categories = ['All', 'Equity', 'Debt', 'Hybrid', 'Others'];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = viewModel.selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                viewModel.setSelectedCategory(cat);
              },
              selectedColor: isDark ? AppTheme.primaryBlueDark : AppTheme.primaryBlue,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  width: 0.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Screen content resolver (handles loading/error/empty/list states)
  Widget _buildMainContent(SchemeListViewModel viewModel, bool isDark) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppTheme.primaryBlueDark : AppTheme.primaryBlue,
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 54, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Failed to load mutual funds',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: viewModel.refreshSchemes,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.schemes.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No schemes found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Try searching for another keyword or tab.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Refresh indicator wrapped list
    return RefreshIndicator(
      onRefresh: viewModel.refreshSchemes,
      color: isDark ? AppTheme.primaryBlueDark : AppTheme.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: viewModel.schemes.length,
        itemBuilder: (context, index) {
          final scheme = viewModel.schemes[index];
          return _buildSchemeCard(scheme, isDark);
        },
      ),
    );
  }

  Widget _buildSchemeCard(SchemeModel scheme, bool isDark) {
    // Resolve dynamic styling for left badge icon
    IconData cardIcon;
    Color iconColor;
    Color badgeBg;

    final designType = scheme.schemeCode % 4;
    switch (designType) {
      case 0: // Equity
        cardIcon = Icons.trending_up_rounded;
        iconColor = const Color(0xFF1E88E5); // Blue
        badgeBg = const Color(0xFF1E88E5).withValues(alpha: 0.1);
        break;
      case 1: // Debt
        cardIcon = Icons.eco_outlined;
        iconColor = const Color(0xFF43A047); // Green
        badgeBg = const Color(0xFF43A047).withValues(alpha: 0.1);
        break;
      case 2: // Hybrid
        cardIcon = Icons.account_balance_outlined;
        iconColor = const Color(0xFFFFB300); // Amber
        badgeBg = const Color(0xFFFFB300).withValues(alpha: 0.15);
        break;
      default: // Others
        cardIcon = Icons.business_outlined;
        iconColor = const Color(0xFF8E24AA); // Purple
        badgeBg = const Color(0xFF8E24AA).withValues(alpha: 0.1);
        break;
    }

    final isPositive = scheme.mockChange >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? const Color(0xFF161F30) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
          width: 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SchemeDetailScreen(scheme: scheme),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Left Custom Badge Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cardIcon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Middle Text Info (Scheme Name + Code)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.schemeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${scheme.schemeCode}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Right Price + Daily Change Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${scheme.mockNav.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}${scheme.mockChange.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? const Color(0xFF43A047) : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
