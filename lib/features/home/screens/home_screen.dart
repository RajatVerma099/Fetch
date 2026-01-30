import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../widgets/storage_indicator.dart';
import '../widgets/last_scan_card.dart';
import '../widgets/stats_grid.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load home data with context for SD card detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(LoadHomeData(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar.large(
                  floating: true,
                  title: const Text('Fetch'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Hero Section
                      _buildHeroSection(context),
                      const SizedBox(height: 24),

                      // Storage Indicator
                      if (state is HomeLoaded)
                        StorageIndicator(storageInfo: state.storageInfo)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Stats Grid
                      if (state is HomeLoaded)
                        StatsGrid(stats: state.fileStats)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 100.ms)
                            .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Last Scan Card
                      if (state is HomeLoaded && state.lastScan != null)
                        LastScanCard(session: state.lastScan!)
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),

                      // Loading State
                      if (state is HomeLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48),
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      // Error State
                      if (state is HomeError)
                        _buildErrorCard(context, state.message),

                      const SizedBox(height: 100), // Space for FAB
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildScanButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: colorScheme.onPrimaryContainer,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
          const SizedBox(height: 16),
          Text(
            'Rediscover Your Media',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find forgotten photos, videos & documents hiding in your device storage.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildScanButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.glow(AppTheme.primarySeed),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/scan'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Start Scan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.5, end: 0);
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<HomeBloc>().add(LoadHomeData(context));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
