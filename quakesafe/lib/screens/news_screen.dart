import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
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
    List<RssItem> allItems = [];
    for (var url in _rssUrls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final feed = RssFeed.parse(response.body);
          allItems.addAll(feed.items);
        }
      } catch (_) {}
    }
    allItems.sort((a, b) => (b.pubDate ?? "").compareTo(a.pubDate ?? ""));
    setState(() {
      _newsItems = allItems;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(AppTranslations.t('news', settings.language)), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNews)]),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : ListView.builder(
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              final item = _newsItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF161616),
                child: ListTile(
                  title: Text(item.title ?? "", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(item.description?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? "", maxLines: 2, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.open_in_new, size: 14, color: Colors.purple),
                  onTap: () => launchUrl(Uri.parse(item.link ?? "")),
                ),
              );
            },
          ),
    );
  }
}
