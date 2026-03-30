// lib/presentation/screens/main_scaffold.dart
// ─────────────────────────────────────────────────────────────────────────────
// Root scaffold: hosts the 5-tab BottomNavigationBar and tab bodies.
// Uses IndexedStack so each tab preserves its scroll/state position.
// Navigation state is managed by NavigationProvider (ChangeNotifier).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolioph/core/theme/color_palette.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/navigation_provider.dart';
import 'package:portfolioph/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:portfolioph/presentation/screens/portfolio/portfolio_screen.dart';
import 'package:portfolioph/presentation/screens/resume/resume_screen.dart';
import 'package:portfolioph/presentation/screens/skills/skills_screen.dart';
import 'package:portfolioph/presentation/screens/profile/profile_screen.dart';
import 'package:portfolioph/features/recruiter/screens/dashboard/recruiter_dashboard_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  // ── Seeker tabs (default) ──────────────────────────────────────────────────
  static const List<_TabItem> _seekerTabs = [
    _TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    _TabItem(
      icon: Icons.folder_open_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Portfolio',
    ),
    _TabItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      label: 'Resume',
    ),
    _TabItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Skills',
    ),
    _TabItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const List<Widget> _seekerBodies = [
    DashboardScreen(),
    PortfolioScreen(),
    ResumeScreen(),
    SkillsScreen(),
    ProfileScreen(),
  ];

  // ── Recruiter tabs ─────────────────────────────────────────────────────────
  static const List<_TabItem> _recruiterTabs = [
    _TabItem(
      icon: Icons.business_outlined,
      activeIcon: Icons.business_rounded,
      label: 'Jobs',
    ),
    _TabItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Applications',
    ),
    _TabItem(
      icon: Icons.hourglass_empty_rounded,
      activeIcon: Icons.hourglass_full_rounded,
      label: 'Pending',
    ),
    _TabItem(
      icon: Icons.close_rounded,
      activeIcon: Icons.close_rounded,
      label: 'Rejected',
    ),
    _TabItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const List<Widget> _recruiterBodies = [
    RecruiterDashboardScreen(),
    // TODO: Applications screen
    Placeholder(),
    // TODO: Pending approvals screen
    Placeholder(),
    // TODO: Rejected screen
    Placeholder(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, AuthProvider>(
      builder: (context, nav, auth, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final palette = Theme.of(context).extension<AppPalette>()!;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Determine tabs based on user role
        final isRecruiter =
            auth.currentUser?.role == AppConstants.roleRecruiter;
        final tabs = isRecruiter ? _recruiterTabs : _seekerTabs;
        final bodies = isRecruiter ? _recruiterBodies : _seekerBodies;

        // Ensure current index is valid for the selected tabs
        final currentIndex = nav.currentIndex.clamp(0, tabs.length - 1);

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.gradientStart.withValues(alpha: 0.10),
                  palette.gradientEnd.withValues(alpha: 0.08),
                  colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(currentIndex),
                  // IndexedStack keeps all tab states alive simultaneously.
                  child: IndexedStack(index: currentIndex, children: bodies),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.glassFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: palette.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor: Colors.transparent,
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final isSelected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      );
                    }),
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final isSelected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      );
                    }),
                  ),
                  child: NavigationBar(
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      HapticFeedback.selectionClick();
                      nav.goTo(index);
                    },
                    animationDuration: const Duration(milliseconds: 320),
                    indicatorColor: isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.06),
                    destinations: tabs
                        .asMap()
                        .entries
                        .map(
                          (entry) => NavigationDestination(
                            icon: _NavIcon(
                              icon: entry.value.icon,
                              isSelected: false,
                              showPhilippineDot: entry.key == 0,
                            ),
                            selectedIcon: _NavIcon(
                              icon: entry.value.activeIcon,
                              isSelected: true,
                              showPhilippineDot: entry.key == 0,
                            ),
                            label: entry.value.label,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lightweight data class for tab metadata.
class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool showPhilippineDot;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.showPhilippineDot,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.38),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon),
        ),
      ],
    );
  }
}
