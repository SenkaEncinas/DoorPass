import 'package:doorpass/models/Entities/RedditDto.dart';
import 'package:doorpass/services/reddit_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORTS DE CONSTANTES (nueva ubicación)
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  _TrendsScreenState createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final RedditService _redditService = RedditService();
  List<RedditDto> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);

    try {
      final posts = await _redditService.getDoorpassPosts();
      setState(() => _posts = posts);
    } catch (e) {
      debugPrint("Error cargando posts: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tendencias • r/doorpass',
          style: AppTextStyles.titleSection.copyWith(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refrescar",
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _posts.isEmpty
                ? _buildEmpty()
                : _buildPostsList(),
      ),
    );
  }

  // ----- UI STATES -----

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.progress),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Cargando publicaciones...',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.group_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No hay publicaciones en r/doorpass',
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyState.copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.lg),
            _gradientButton(
              text: "Reintentar",
              onTap: _loadPosts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      itemCount: _posts.length,
      itemBuilder: (_, index) => _TrendsPostCard(post: _posts[index]),
    );
  }

  // ----- REUSABLE GRADIENT BUTTON -----

  Widget _gradientButton({required String text, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.softCard,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Text(
            text,
            style: GoogleFonts.orbitron(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// ---- CARD INDIVIDUAL CON SPOILER / NSFW TAP-TO-REVEAL ----

class _TrendsPostCard extends StatefulWidget {
  final RedditDto post;

  const _TrendsPostCard({required this.post});

  @override
  State<_TrendsPostCard> createState() => _TrendsPostCardState();
}

class _TrendsPostCardState extends State<_TrendsPostCard> {
  late bool _revealed;

  @override
  void initState() {
    super.initState();
    final p = widget.post;
    // Si es NSFW o Spoiler => empieza oculto
    _revealed = !(p.isNsfw || p.isSpoiler);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isSensitive = post.isNsfw || post.isSpoiler;

    final String contentTypeLabel = post.isVideo
        ? 'VIDEO'
        : (post.isSelfPost ? 'TEXTO' : 'ENLACE');

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),

          // Si es sensible y NO está revelado => muestra overlay estilo Discord
          if (isSensitive && !_revealed)
            _buildSensitiveOverlay(post)
          else
            _buildPostBody(post, contentTypeLabel),
        ],
      ),
    );
  }

  // ----- HEADER -----

  Widget _buildPostHeader(RedditDto post) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.card),
          topRight: Radius.circular(AppRadius.card),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.background.withOpacity(0.9),
            radius: 16,
            child: Text(
              post.author.isNotEmpty ? post.author[0].toUpperCase() : 'U',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'u/${post.author}',
                  style: GoogleFonts.orbitron(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'r/${post.subreddit}',
                      style: GoogleFonts.orbitron(
                        color: AppColors.textPrimary.withOpacity(0.9),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${_formatTimeAgo(post.created)}',
                      style: GoogleFonts.orbitron(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildPostBadges(post),
        ],
      ),
    );
  }

  // ----- OVERLAY SPOILER / NSFW -----

  Widget _buildSensitiveOverlay(RedditDto post) {
    final isNsfw = post.isNsfw;
    final isSpoiler = post.isSpoiler;

    String title = 'Contenido sensible';
    String subtitle = 'Toca para revelar';

    if (isNsfw && isSpoiler) {
      title = 'NSFW + Spoiler';
      subtitle = 'Toca para revelar contenido';
    } else if (isNsfw) {
      title = '+18 • NSFW';
      subtitle = 'Toca para revelar imagen / contenido';
    } else if (isSpoiler) {
      title = 'Spoiler';
      subtitle = 'Toca para ver el contenido';
    }

    return InkWell(
      onTap: () => setState(() => _revealed = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppRadius.card),
            bottomRight: Radius.circular(AppRadius.card),
          ),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent.shade200,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: Colors.redAccent.shade200,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (isNsfw)
                  _smallTag('NSFW'),
                if (isSpoiler)
                  _smallTag('Spoiler'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          color: AppColors.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ----- BODY NORMAL (YA REVELADO) -----

  Widget _buildPostBody(RedditDto post, String contentTypeLabel) {
    final textTitle = AppTextStyles.titleSection.copyWith(
      fontSize: 15,
    );

    final textNormal = AppTextStyles.body.copyWith(
      fontSize: 13,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen solo si hay URL y no es video
          if (post.fullImageUrl.isNotEmpty && !post.isVideo)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: Image.network(
                  post.fullImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: Text(
                      'No se pudo cargar la imagen',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Text(post.title, style: textTitle),
          const SizedBox(height: AppSpacing.sm),

          if (post.selftext.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: AppColors.primaryAccent.withOpacity(0.4),
                ),
              ),
              child: Text(
                post.selftext,
                style: textNormal.copyWith(
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          _buildPostMetrics(post, contentTypeLabel),
        ],
      ),
    );
  }

  // ----- BADGES EN EL HEADER -----

  Widget _buildPostBadges(RedditDto post) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (post.isStickied)
          _buildBadge(Icons.push_pin, 'Fijado', Colors.greenAccent),

        if (post.isVideo)
          _buildBadge(Icons.videocam, 'Video', Colors.lightBlueAccent),

        if (post.totalAwards > 0)
          _buildBadge(
            Icons.emoji_events,
            '${post.totalAwards}',
            Colors.amberAccent,
          ),

        if (post.isNsfw)
          _buildBadge(Icons.warning_amber_rounded, 'NSFW', Colors.redAccent),

        if (post.isSpoiler)
          _buildBadge(Icons.visibility_off, 'Spoiler', Colors.orangeAccent),

        if (post.flair.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Text(
              post.flair,
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.orbitron(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ----- MÉTRICAS -----

  Widget _buildPostMetrics(RedditDto post, String contentTypeLabel) {
    return Row(
      children: [
        _metric(Icons.arrow_upward, '${post.upvotes}', 'Upvotes'),
        const SizedBox(width: AppSpacing.md),
        _metric(Icons.comment, '${post.comments}', 'Comentarios'),
        const SizedBox(width: AppSpacing.md),
        _metric(
          Icons.thumb_up,
          '${(post.upvoteRatio * 100).round()}%',
          'Ratio',
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: post.isSelfPost
                ? Colors.greenAccent.withOpacity(0.10)
                : Colors.lightBlueAccent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  post.isSelfPost ? Colors.greenAccent : Colors.lightBlueAccent,
            ),
          ),
          child: Text(
            contentTypeLabel,
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color:
                  post.isSelfPost ? Colors.greenAccent : Colors.lightBlueAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: AppColors.textSecondary.withOpacity(0.7),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ----- TIME AGO -----

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'ahora';
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace ${difference.inHours} h';
    if (difference.inDays < 7) return 'hace ${difference.inDays} días';

    return '${date.day}/${date.month}/${date.year}';
  }
}
