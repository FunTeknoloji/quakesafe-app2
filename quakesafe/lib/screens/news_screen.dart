import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_provider.dart';
import '../translations.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<RssItem> _newsItems = [];
  bool _isLoading = true;

  final List<String> _rssUrls = [
    "https://www.haberturk.com/rss",
    "https://www.ahaber.com.tr/rss/son-dakika.xml",
    "https://halktv.com.tr/rss",
  ];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _isLoading = true);
    List<RssItem> allItems = [];
    for (var url in _rssUrls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes, allowMalformed: true);
          final feed = RssFeed.parse(decodedBody);
          allItems.addAll(feed.items);
        }
      } catch (_) {}
    }
    allItems.sort((a, b) => (b.pubDate ?? "").compareTo(a.pubDate ?? ""));
    if (mounted) {
      setState(() {
        _newsItems = allItems;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(AppTranslations.t('news', settings.language)),
            backgroundColor: Colors.black,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.purple),
                onPressed: _fetchNews,
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Colors.purple)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _newsItems[index];
                    return _buildNewsCard(item, index);
                  },
                  childCount: _newsItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(RssItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(item.link ?? ""), mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSource(item.link),
                      style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.open_in_new, size: 14, color: Colors.white24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title ?? "",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                item.description?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? "",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  String _getSource(String? link) {
    if (link == null) return "HABER";
    if (link.contains("haberturk")) return "HABERTÜRK";
    if (link.contains("ahaber")) return "A HABER";
    if (link.contains("halktv")) return "HALK TV";
    return "HABER";
  }
}
