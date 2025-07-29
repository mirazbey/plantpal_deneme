// lib/pages/encyclopedia_detail_page.dart (TAM VE HATASIZ FİNAL SÜRÜM)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:plantpal/pages/plant_search_page.dart'; // Bu import gerekli
import 'package:plantpal/services/image_search_service.dart';
import 'package:plantpal/theme/app_theme.dart';

class EncyclopediaDetailPage extends StatelessWidget {
  final PlantSearchResult plant;
  final ImageSearchService _imageService = ImageSearchService();

  EncyclopediaDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: textTheme.bodyLarge?.color,
                  unselectedLabelColor: textTheme.bodyMedium?.color,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3.0,
                  labelStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "Bakım"),
                    Tab(text: "Gereksinimler"),
                  ],
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
              pinned: true,
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _buildBakimContent(context),
                  _buildGereksinimlerContent(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      leading: const BackButton(color: Colors.white),
      actions: [
        IconButton(
          onPressed: () { /* Favori butonu işlevi */ },
          icon: const Icon(Iconsax.heart, color: Colors.white, size: 26),
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          plant.commonName,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: FutureBuilder<String?>(
          future: _imageService.searchImage(plant.imagePath),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(102), // ~40% opacity
                colorBlendMode: BlendMode.darken,
              );
            }
            return Container(color: Colors.grey.shade800, child: const Center(child: CircularProgressIndicator(color: Colors.white)));
          },
        ),
      ),
    );
  }

  Widget _buildBakimContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        InfoDetailCard(
          icon: Iconsax.ruler,
          title: "Zorluk",
          subtitle: "Genellikle kolay",
          iconColor: Colors.orange,
        ),
        InfoDetailCard(
          icon: Iconsax.drop,
          title: "Sulama",
          subtitle: "Kural: Az sulama, fazla değil!",
          iconColor: AppTheme.designAccentBlue,
        ),
        InfoDetailCard(
          icon: Iconsax.cup,
          title: "Gübreleme",
          subtitle: "Büyüme döneminde ayda bir",
          iconColor: Colors.green,
        ),
      ],
    );
  }

  // encyclopedia_detail_page.dart dosyasındaki SADECE bu fonksiyonu güncelle

Widget _buildGereksinimlerContent(BuildContext context) {
  // HATA DÜZELTMESİ: Tüm widget ağacına 'const' doğru şekilde eklendi
  return const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RequirementCard(
                icon: Iconsax.box_1,
                title: "Saksı",
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: RequirementCard(
                icon: Iconsax.tree,
                title: "Toprak",
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        RequirementCard(
          icon: Iconsax.sun_1,
          title: "Işık",
          subtitle: "Dolaylı parlak ışık",
          isFullWidth: true,
        ),
        SizedBox(height: 16),
        RequirementCard(
          icon: Iconsax.cloud_snow,
          title: "Nem",
          subtitle: "Orta nem",
          isFullWidth: true,
        ),
        SizedBox(height: 16),
        RequirementCard(
          icon: Iconsax.sun_1,
          title: "Sıcaklık",
          subtitle: "18°C - 30°C",
          isFullWidth: true,
        ),
      ],
    ),
  );
}
}

// =========================================================================
// YARDIMCI WIDGET'LAR VE CLASS'LAR (DEĞİŞİKLİK YOK)
// =========================================================================

class InfoDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const InfoDetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = AppTheme.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: textTheme.bodyMedium!),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class RequirementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isFullWidth;

  const RequirementCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: isFullWidth
              ? Row(
                  children: [
                    Icon(icon, color: textTheme.bodyLarge?.color),
                    const SizedBox(width: 16),
                    Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (subtitle != null) Text(subtitle!, style: textTheme.bodyMedium!),
                  ],
                )
              : Column(
                  children: [
                    Icon(icon, color: textTheme.bodyLarge?.color, size: 28),
                    const SizedBox(height: 12),
                    Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverAppBarDelegate(this._tabBar, {required this.backgroundColor});

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}