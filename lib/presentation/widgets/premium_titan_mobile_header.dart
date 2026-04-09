import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PremiumTitanMobileHeader extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final String greeting;
  final String userName;
  final bool compact;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;
  final bool hasUnreadNotifications;

  const PremiumTitanMobileHeader({
    super.key,
    required this.title,
    required this.greeting,
    required this.userName,
    this.compact = false,
    this.onSearchTap,
    this.onSearchSubmitted,
    this.onNotificationTap,
    this.onProfileTap,
    this.onLogoutTap,
    this.hasUnreadNotifications = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(compact ? 84 : 126);

  @override
  State<PremiumTitanMobileHeader> createState() =>
      _PremiumTitanMobileHeaderState();
}

class _PremiumTitanMobileHeaderState extends State<PremiumTitanMobileHeader> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = Colors.white.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.fromLTRB(12, 10, 12, widget.compact ? 10 : 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      const Color(0xFF0A66C2).withValues(alpha: 0.22),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onProfileTap,
                          child: _LiveAvatar(initial: _initialFromName(widget.userName)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.greeting,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: labelColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _SvgActionButton(
                          tooltip: 'Search',
                          svg: _searchSvg,
                          onTap: () {
                            setState(() => _searchExpanded = !_searchExpanded);
                            widget.onSearchTap?.call();
                          },
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _SvgActionButton(
                              tooltip: 'Notifications',
                              svg: _bellSvg,
                              onTap: widget.onNotificationTap,
                            ),
                            if (widget.hasUnreadNotifications)
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withValues(alpha: 0.7),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (widget.onLogoutTap != null) ...[
                          const SizedBox(width: 8),
                          _SvgActionButton(
                            tooltip: 'Logout',
                            svg: _logoutSvg,
                            onTap: widget.onLogoutTap,
                          ),
                        ],
                      ],
                    ),
                    if (!widget.compact) ...[
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _searchExpanded
                            ? Container(
                                key: const ValueKey('searchField'),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: widget.onSearchSubmitted,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    icon: SvgPicture.string(
                                      _searchSvg,
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white70,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    hintText: 'Search jobs, companies, skills...',
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                  ),
                                ),
                              )
                            : Container(
                                key: const ValueKey('searchHint'),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black.withValues(alpha: 0.18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: const Text(
                                  'Search jobs, companies, skills',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initialFromName(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return 'U';
    return clean.substring(0, 1).toUpperCase();
  }
}

class _LiveAvatar extends StatelessWidget {
  final String initial;

  const _LiveAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF0A66C2), Color(0xFF38BDF8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SvgActionButton extends StatelessWidget {
  final String tooltip;
  final String svg;
  final VoidCallback? onTap;

  const _SvgActionButton({
    required this.tooltip,
    required this.svg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Center(
            child: SvgPicture.string(
              svg,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const String _searchSvg =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="2"/><path d="M20 20L17 17" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>';

const String _bellSvg =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M15 17H5L6.4 15.6V10.2C6.4 7.5 8.4 5.1 11 4.6V4C11 3.4 11.4 3 12 3C12.6 3 13 3.4 13 4V4.6C15.6 5.1 17.6 7.5 17.6 10.2V15.6L19 17H15Z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M9.5 18.5C9.8 19.4 10.7 20 11.7 20C12.7 20 13.6 19.4 13.9 18.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>';

const String _logoutSvg =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M10 17L15 12L10 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M15 12H4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M13 4H18C19.1 4 20 4.9 20 6V18C20 19.1 19.1 20 18 20H13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>';
