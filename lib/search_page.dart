import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/listing_item.dart';
import 'package:kltheguide/services/api_service.dart';
import 'package:kltheguide/services/recent_searches_service.dart';
import 'package:kltheguide/widgets/listing_card.dart';
import 'package:kltheguide/widgets/state_views.dart';

class _SearchEntry {
  final ListingItem item;
  final String category;
  const _SearchEntry(this.item, this.category);
}

// (API action, category label). Covers the categories that share
// ListingItem's shape (title/image/location/hours/phone/website) — Explore
// KL's sub-pages use a mix of shapes and category-filtered single actions,
// so they're left as a follow-up rather than force-fit here.
const _searchSources = [
  ('appShop', 'Shop'),
  ('appSpa', 'Spa'),
  ('appStay_top', 'Stay'),
  ('appStay_h', 'Stay'),
  ('appStay_bh', 'Stay'),
  ('appStay_bks', 'Stay'),
  ('appMedicalT_hc', 'Medical Tourism'),
  ('appMedicalT_dtl', 'Medical Tourism'),
  ('appMedicalT_der', 'Medical Tourism'),
  ('appMedicalT_oph', 'Medical Tourism'),
  ('appMedicalT_ps', 'Medical Tourism'),
  ('appBeyondKL_i', 'Beyond KL'),
  ('appBeyondKL_hs', 'Beyond KL'),
  ('appBeyondKL_w', 'Beyond KL'),
  ('appBeyondKL_h', 'Beyond KL'),
  ('appBeyondKL_es', 'Beyond KL'),
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

const _categories = ['Shop', 'Spa', 'Stay', 'Medical Tourism', 'Beyond KL'];

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  bool _loading = true;
  bool _error = false;
  List<_SearchEntry> _all = [];
  String? _categoryFilter;
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
    RecentSearchesService.getRecent().then((recent) {
      if (mounted) setState(() => _recent = recent);
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final results = await Future.wait(_searchSources.map((s) => fetchList(s.$1)));
      final entries = <_SearchEntry>[];
      for (var i = 0; i < _searchSources.length; i++) {
        final category = _searchSources[i].$2;
        for (final e in results[i]) {
          entries.add(_SearchEntry(
            ListingItem(
              title: field(e, 'title'),
              imageUrl: field(e, 'image'),
              description: field(e, 'content'),
              address: field(e, 'location'),
              mapsUrl: field(e, 'locationurl'),
              hours: field(e, 'hours'),
              contact: field(e, 'phone'),
              website: field(e, 'website'),
            ),
            category,
          ));
        }
      }
      if (!mounted) return;
      setState(() {
        _all = entries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    if (_query.trim().isNotEmpty) {
      RecentSearchesService.add(_query);
    }
    _controller.dispose();
    super.dispose();
  }

  void _applyQuery(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    setState(() => _query = query);
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final query = _query.trim().toLowerCase();
    final results = query.isEmpty
        ? const <_SearchEntry>[]
        : _all.where((e) {
            final matchesText = e.item.title.toLowerCase().contains(query) ||
                e.item.address.toLowerCase().contains(query);
            if (!matchesText) return false;
            if (_categoryFilter != null && e.category != _categoryFilter) return false;
            return true;
          }).toList();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.textSecondary),
        titleSpacing: 0,
        title: Hero(
          tag: 'home-search-bar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 46,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: palette.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: TextStyle(color: palette.textPrimary, fontSize: 15),
                      cursorColor: palette.accent,
                      decoration: InputDecoration(
                        hintText: 'Search shops, stays, spas…',
                        hintStyle: TextStyle(color: palette.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    Semantics(
                      button: true,
                      label: 'Clear search text',
                      child: GestureDetector(
                        onTap: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.close_rounded, size: 18, color: palette.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: palette.accent))
          : _error
              ? ErrorStateView(
                  message: 'Could not load search results. Check your connection and try again.',
                  onRetry: _load,
                )
              : query.isEmpty
                  ? _buildIdleState(palette)
                  : Column(
                      children: [
                        _buildFilterChips(palette),
                        if (results.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${results.length} result${results.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: results.isEmpty
                              ? EmptyStateView(
                                  icon: Icons.search_off,
                                  message: 'No results for "$_query".',
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                  itemCount: results.length,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: ListingCard.fromItem(
                                      results[index].item,
                                      category: results[index].category,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildIdleState(HomePalette palette) {
    if (_recent.isEmpty) {
      return const EmptyStateView(
        icon: Icons.search,
        message: 'Search shops, stays, spas, medical tourism, and Beyond KL by name.',
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent searches',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  RecentSearchesService.clear();
                  setState(() => _recent = []);
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in _recent)
                _FilterChip(
                  label: query,
                  selected: false,
                  palette: palette,
                  onTap: () => _applyQuery(query),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(HomePalette palette) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        children: [
          _FilterChip(
            label: 'All',
            selected: _categoryFilter == null,
            palette: palette,
            onTap: () => setState(() => _categoryFilter = null),
          ),
          for (final category in _categories) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: category,
              selected: _categoryFilter == category,
              palette: palette,
              onTap: () => setState(() => _categoryFilter = category),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final HomePalette palette;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.accent : palette.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected ? null : Border.all(color: palette.accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : palette.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
