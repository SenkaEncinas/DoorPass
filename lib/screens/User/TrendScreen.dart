import 'package:doorpass/models/Entities/RedditDto.dart';
import 'package:doorpass/services/reddit_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final textStyleTitulo = GoogleFonts.orbitron(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        title: Text('Tendencias • r/doorpass', style: textStyleTitulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
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
          const CircularProgressIndicator(color: Colors.purpleAccent),
          const SizedBox(height: 16),
          Text(
            'Cargando publicaciones...',
            style: GoogleFonts.orbitron(color: Colors.purpleAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off, size: 64, color: Colors.purpleAccent),
            const SizedBox(height: 16),
            Text(
              'No hay publicaciones en r/doorpass',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      itemCount: _posts.length,
      itemBuilder: (_, index) => _buildPostItem(_posts[index]),
    );
  }

  // ----- POST ITEM -----

  Widget _buildPostItem(RedditDto post) {
    final textTitle = GoogleFonts.orbitron(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );

    final textNormal = GoogleFonts.orbitron(
      color: Colors.purpleAccent,
      fontSize: 13,
    );

    return Card(
      color: const Color(0xFF2D014F).withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: textTitle),
                const SizedBox(height: 10),

                if (post.selftext.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF100018),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purpleAccent.shade200),
                    ),
                    child: Text(
                      post.selftext,
                      style: textNormal.copyWith(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                _buildPostMetrics(post),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(RedditDto post) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF3A0055),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple[200],
            radius: 16,
            child: Text(
              post.author.isNotEmpty ? post.author[0].toUpperCase() : 'U',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'u/${post.author}',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimeAgo(post.created),
                  style: GoogleFonts.orbitron(
                    color: Colors.purpleAccent.shade100,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _buildPostBadges(post),
        ],
      ),
    );
  }

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

        if (post.flair.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              post.flair,
              style: GoogleFonts.orbitron(
                color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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

  Widget _buildPostMetrics(RedditDto post) {
    return Row(
      children: [
        _metric(Icons.arrow_upward, '${post.upvotes}', 'Upvotes'),
        const SizedBox(width: 14),
        _metric(Icons.comment, '${post.comments}', 'Comentarios'),
        const SizedBox(width: 14),
        _metric(
          Icons.thumb_up,
          '${(post.upvoteRatio * 100).round()}%',
          'Ratio',
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: post.isSelfPost
                ? Colors.greenAccent.withOpacity(0.10)
                : Colors.lightBlueAccent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: post.isSelfPost ? Colors.greenAccent : Colors.lightBlueAccent,
            ),
          ),
          child: Text(
            post.isSelfPost ? 'TEXTO' : 'ENLACE',
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: post.isSelfPost ? Colors.greenAccent : Colors.lightBlueAccent,
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
            Icon(icon, size: 15, color: Colors.purpleAccent),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: Colors.white,
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
            color: Colors.purpleAccent.shade100,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ----- REUSABLE GRADIENT BUTTON (igual a tu estilo) -----

  Widget _gradientButton({required String text, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: Text(
            text,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
