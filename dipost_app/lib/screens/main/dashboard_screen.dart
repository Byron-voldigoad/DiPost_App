import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../constants/route_names.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../services/database_helper.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = AppTheme.getPrimaryColor(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Image de fond qui couvre tout l'écran
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: AppTheme.getBackgroundDecoration(authProvider),
              ),
              // Contenu défilable
              _buildDashboardContent(context, authProvider, primaryColor),
              _buildNotificationBar(context, authProvider),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context, authProvider),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    if (authProvider.isAdmin || authProvider.isOperateur) {
      return FloatingActionButton(
        onPressed: () {
          if (authProvider.isAdmin) {
            Navigator.pushNamed(context, RouteNames.userManagement);
          } else {
            Navigator.pushNamed(context, RouteNames.colisList);
          }
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AuthProvider authProvider,
    Color primaryColor,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context, authProvider, primaryColor),
            const SizedBox(height: 25),
            _buildSectionTitle(context, 'Actions rapides', primaryColor),
            const SizedBox(height: 15),
            _buildActionGrid(context, authProvider, primaryColor),
            const SizedBox(height: 25),
            if (authProvider.isAdmin) ...[
              _buildKPIRow(context),
              const SizedBox(height: 20),
              _buildSectionTitle(
                context,
                'Statistiques détaillées',
                primaryColor,
              ),
              const SizedBox(height: 15),
              _buildStatsGrid(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKPIRow(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.getDeliveryStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildKpiLoading(context);

        final stats = snapshot.data!['week'];
        final delivered = stats['delivered'] ?? 0;
        final inProgress = stats['in_progress'] ?? 0;
        final pending = stats['pending'] ?? 0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildKPICard(
                context,
                title: 'Livrées',
                value: delivered,
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              _buildKPICard(
                context,
                title: 'En cours',
                value: inProgress,
                icon: Icons.timer,
                color: Colors.orange,
              ),
              const SizedBox(width: 10),
              _buildKPICard(
                context,
                title: 'En attente',
                value: pending,
                icon: Icons.pending,
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      color.red,
                      color.green,
                      color.blue,
                      0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiLoading(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 24,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(
    BuildContext context,
    AuthProvider authProvider,
    Color primaryColor,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Color.fromRGBO(
        primaryColor.red,
        primaryColor.green,
        primaryColor.blue,
        0.2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.red,
                  primaryColor.green,
                  primaryColor.blue,
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 30, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${authProvider.user?.prenom ?? 'Utilisateur'}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Chip(
              backgroundColor: Color.fromRGBO(
                primaryColor.red,
                primaryColor.green,
                primaryColor.blue,
                0.1,
              ),
              label: Text(
                authProvider.user?.role.toUpperCase() ?? '',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    AuthProvider authProvider,
    Color primaryColor,
  ) {
    final actions = [
      if (authProvider.isAdmin || authProvider.isOperateur)
        _DashboardAction(
          icon: Icons.storage,
          label: 'iBox',
          color: primaryColor,
          onTap: () => Navigator.pushNamed(context, RouteNames.iboxList),
        ),
      if (authProvider.isAdmin || authProvider.isOperateur)
        _DashboardAction(
          icon: Icons.mail,
          label: 'Colis',
          color: primaryColor,
          onTap: () => Navigator.pushNamed(context, RouteNames.colisList),
        ),
      if (authProvider.isAdmin)
        _DashboardAction(
          icon: Icons.people,
          label: 'Utilisateurs',
          color: primaryColor,
          onTap: () => Navigator.pushNamed(context, RouteNames.userManagement),
        ),
      if (authProvider.isAdmin || authProvider.isOperateur)
        _DashboardAction(
          icon: Icons.delivery_dining,
          label: 'Livraisons',
          color: primaryColor,
          onTap:
              () =>
                  Navigator.pushNamed(context, RouteNames.livraisonManagement),
        ),
      if (authProvider.isLivreur)
        _DashboardAction(
          icon: Icons.delivery_dining,
          label: 'Livraisons',
          color: primaryColor,
          onTap:
              () =>
                  Navigator.pushNamed(context, RouteNames.livraisonListLivreur),
        ),
      if (authProvider.isClient)
        _DashboardAction(
          icon: Icons.delivery_dining,
          label: 'Livraisons',
          color: primaryColor,
          onTap:
              () => Navigator.pushNamed(context, RouteNames.livraisonListUser),
        ),
      if (authProvider.isClient)
        _DashboardAction(
          icon: Icons.mail,
          label: 'Mes Colis',
          color: primaryColor,
          onTap: () => Navigator.pushNamed(context, RouteNames.colisList),
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: actions.length,
      itemBuilder:
          (context, index) => Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: actions[index],
          ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        DeliveryStatsCard(key: const ValueKey('delivery_stats')),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TopUsersCard(key: const ValueKey('top_users'))),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNotificationBar(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.query(
        'notifications',
        where: 'id_utilisateur = ? AND statut = ?',
        whereArgs: [authProvider.user?.id, 'non_lu'],
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox();

        final notifications = snapshot.data!;
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifications (${notifications.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...notifications.map((notification) {
                  return ListTile(
                    leading: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    title: Text(
                      notification['message'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () async {
                        await DatabaseHelper.instance.update(
                          'notifications',
                          {'statut': 'lu'},
                          where: 'id_notification = ?',
                          whereArgs: [notification['id_notification']],
                        );
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryStatsCard extends StatelessWidget {
  const DeliveryStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper.instance.getDeliveryStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildLoadingCard(theme);

        final weekStats = snapshot.data!['week'];
        final monthStats = snapshot.data!['month'];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistiques des livraisons',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return _buildMobileLayout(context, weekStats, monthStats);
                    } else {
                      return _buildDesktopLayout(
                        context,
                        weekStats,
                        monthStats,
                        theme,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildDeliveryChart(weekStats, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Map<String, dynamic> weekStats,
    Map<String, dynamic> monthStats,
  ) {
    return Column(
      children: [
        _buildStatItem(
          context,
          'Cette semaine',
          weekStats['total'] ?? 0,
          weekStats['delivered'] ?? 0,
          weekStats['in_progress'] ?? 0,
          weekStats['pending'] ?? 0,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _buildStatItem(
          context,
          'Ce mois',
          monthStats['total'] ?? 0,
          monthStats['delivered'] ?? 0,
          0,
          0,
          showDetails: false,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Map<String, dynamic> weekStats,
    Map<String, dynamic> monthStats,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Cette semaine',
            weekStats['total'] ?? 0,
            weekStats['delivered'] ?? 0,
            weekStats['in_progress'] ?? 0,
            weekStats['pending'] ?? 0,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 100, color: theme.dividerColor),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            context,
            'Ce mois',
            monthStats['total'] ?? 0,
            monthStats['delivered'] ?? 0,
            0,
            0,
            showDetails: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    int total,
    int delivered,
    int inProgress,
    int pending, {
    bool showDetails = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildCompactStatRow(context, 'Total', total.toString(), Colors.black),
        if (showDetails) ...[
          _buildCompactStatRow(
            context,
            'Livrées',
            delivered.toString(),
            Colors.green,
          ),
          _buildCompactStatRow(
            context,
            'En cours',
            inProgress.toString(),
            Colors.orange,
          ),
          _buildCompactStatRow(
            context,
            'En attente',
            pending.toString(),
            Colors.blue,
          ),
        ] else ...[
          _buildCompactStatRow(
            context,
            'Livrées',
            delivered.toString(),
            Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactStatRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryChart(Map<String, dynamic> stats, ThemeData theme) {
    final delivered = stats['delivered'] ?? 0;
    final inProgress = stats['in_progress'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final total = [
      delivered,
      inProgress,
      pending,
    ].reduce((a, b) => a > b ? a : b);

    if (total == 0) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('Aucune donnée disponible')),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: total * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Livrées', style: TextStyle(fontSize: 12)),
                      );
                    case 1:
                      return const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('En cours', style: TextStyle(fontSize: 12)),
                      );
                    case 2:
                      return const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'En attente',
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    default:
                      return const Text('');
                  }
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (value) => FlLine(
                  color: theme.colorScheme.surfaceContainerHighest,
                  strokeWidth: 1,
                ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: delivered.toDouble(),
                  color: Colors.green,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: inProgress.toDouble(),
                  color: Colors.orange,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: pending.toDouble(),
                  color: Colors.blue,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class TopUsersCard extends StatefulWidget {
  const TopUsersCard({super.key});

  @override
  State<TopUsersCard> createState() => _TopUsersCardState();
}

class _TopUsersCardState extends State<TopUsersCard> {
  Future<void> refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getTopUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(theme);
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(context, theme);
        }

        final users = snapshot.data!;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Utilisateurs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: refreshData,
                      tooltip: 'Actualiser',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildUsersList(users, theme, isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList(
    List<Map<String, dynamic>> users,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final rank = index + 1;
        final isLivreur = user['role'] == 'livreur';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildUserTile(user, rank, theme, isLivreur),
        );
      },
    );
  }

  Widget _buildUserTile(
    Map<String, dynamic> user,
    int rank,
    ThemeData theme,
    bool isLivreur,
  ) {
    return ListTile(
      leading: _buildUserAvatar(user, rank),
      title: Text(
        '${user['prenom']} ${user['nom']}',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user['role'].toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isLivreur ? Colors.blue : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user['adresse_email'],
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isLivreur
                ? '${user['deliveries_completed']} liv.'
                : '${user['colis_geres']} colis',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            isLivreur ? 'Livrées' : 'Gérés',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user, int rank) {
    final roleColor = _getRoleColor(user['role']);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Color.fromRGBO(
            roleColor.red,
            roleColor.green,
            roleColor.blue,
            0.2,
          ),
          child: Text(
            user['prenom'][0] + user['nom'][0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (rank <= 3)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'livreur':
        return Colors.blue;
      case 'operateur':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 40,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 10),
            Text(
              'Aucune activité utilisateur',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
