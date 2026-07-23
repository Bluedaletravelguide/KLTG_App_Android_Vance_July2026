import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/models/trip_day.dart';
import 'package:kltheguide/models/trip_item.dart';
import 'package:kltheguide/services/trip_planner_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/landmarks.dart';

const _klCenter = LatLng(3.1516, 101.6942);
const _initialZoom = 13.0;

extension on LandmarkCategory {
  /// A recognizable glyph for this category, shown inside the map pin and
  /// next to the landmark's name in lists.
  IconData get icon {
    switch (this) {
      case LandmarkCategory.tower:
        return Icons.location_city;
      case LandmarkCategory.mosque:
        return Icons.mosque;
      case LandmarkCategory.hinduTemple:
        return Icons.temple_hindu;
      case LandmarkCategory.chineseTemple:
        return Icons.temple_buddhist;
      case LandmarkCategory.museum:
        return Icons.museum;
      case LandmarkCategory.park:
        return Icons.park;
      case LandmarkCategory.shopping:
        return Icons.local_mall;
      case LandmarkCategory.market:
        return Icons.storefront;
      case LandmarkCategory.foodStreet:
        return Icons.restaurant;
      case LandmarkCategory.neighborhood:
        return Icons.holiday_village;
      case LandmarkCategory.transit:
        return Icons.train;
      case LandmarkCategory.business:
        return Icons.business_center;
      case LandmarkCategory.stadium:
        return Icons.stadium;
      case LandmarkCategory.concertHall:
        return Icons.theater_comedy;
      case LandmarkCategory.attraction:
        return Icons.attractions;
      case LandmarkCategory.historic:
        return Icons.account_balance;
    }
  }

  /// Short human-readable name shown on the category filter chips.
  String get label {
    switch (this) {
      case LandmarkCategory.tower:
        return 'Towers';
      case LandmarkCategory.mosque:
        return 'Mosques';
      case LandmarkCategory.hinduTemple:
        return 'Hindu Temples';
      case LandmarkCategory.chineseTemple:
        return 'Chinese Temples';
      case LandmarkCategory.museum:
        return 'Museums';
      case LandmarkCategory.park:
        return 'Parks';
      case LandmarkCategory.shopping:
        return 'Shopping';
      case LandmarkCategory.market:
        return 'Markets';
      case LandmarkCategory.foodStreet:
        return 'Food Streets';
      case LandmarkCategory.neighborhood:
        return 'Neighborhoods';
      case LandmarkCategory.transit:
        return 'Transit';
      case LandmarkCategory.business:
        return 'Business';
      case LandmarkCategory.stadium:
        return 'Stadiums';
      case LandmarkCategory.concertHall:
        return 'Concert Halls';
      case LandmarkCategory.attraction:
        return 'Attractions';
      case LandmarkCategory.historic:
        return 'Historic';
    }
  }
}

// Tiles are served through cached_network_image's disk cache (the same
// cache every other image in the app already uses) instead of a plain
// network fetch. There's no "download this region" flow — just: once
// you've viewed an area with a connection, it stays viewable without one.
class _CachedTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      CachedNetworkImageProvider(getTileUrl(coordinates, options));
}

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();

  Position? _userPosition;
  StreamSubscription<Position>? _posSub;
  String _searchQuery = '';
  bool _showSearchResults = false;
  Landmark? _selectedLandmark;
  final Set<LandmarkCategory> _hiddenCategories = {};

  HomePalette get _palette =>
      HomePalette.of(context);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return;
    }

    final pos =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    if (mounted) setState(() => _userPosition = pos);

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 2),
    ).listen((p) {
      if (mounted) setState(() => _userPosition = p);
    });
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + delta);
  }

  void _resetView() {
    _mapController.move(_klCenter, _initialZoom);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _goToMyLocation() async {
    if (_userPosition != null) {
      _mapController.move(
          LatLng(_userPosition!.latitude, _userPosition!.longitude), 16);
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      _toast('Turn on location services to find your position.');
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      _toast('Location permission is required to show your position.');
      return;
    }

    _toast('Finding your location...');
    await _initLocation();
    if (_userPosition != null) {
      _mapController.move(
          LatLng(_userPosition!.latitude, _userPosition!.longitude), 16);
    } else {
      _toast('Could not determine your location. Try again.');
    }
  }

  void _goToLandmark(Landmark lm) {
    HapticFeedback.selectionClick();
    _mapController.move(LatLng(lm.lat, lm.lng), 16);
    setState(() {
      _showSearchResults = false;
      _searchQuery = '';
      _searchCtrl.clear();
      _selectedLandmark = lm;
    });
    FocusScope.of(context).unfocus();
  }

  void _selectLandmark(Landmark lm) {
    HapticFeedback.selectionClick();
    setState(() => _selectedLandmark = lm);
  }

  void _dismissSelection() {
    if (_selectedLandmark == null && !_showSearchResults) return;
    setState(() {
      _selectedLandmark = null;
      _showSearchResults = false;
    });
    FocusScope.of(context).unfocus();
  }

  /// Categories that actually appear in [landmarks], in enum order — used
  /// to build the filter chip row (skips categories with no pins).
  List<LandmarkCategory> get _availableCategories {
    final present = landmarks.map((lm) => lm.category).toSet();
    return LandmarkCategory.values.where(present.contains).toList();
  }

  void _toggleCategory(LandmarkCategory category) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_hiddenCategories.contains(category)) {
        _hiddenCategories.remove(category);
      } else {
        _hiddenCategories.add(category);
        if (_selectedLandmark?.category == category) {
          _selectedLandmark = null;
        }
      }
    });
  }

  Future<void> _addToTrip(Landmark lm) async {
    final tripItem = TripItem(
      title: lm.name,
      imageUrl: '',
      description: lm.blurb,
      mapsUrl: 'https://www.google.com/maps/search/?api=1&query=${lm.lat},${lm.lng}',
      category: 'Landmark',
    );

    await TripPlannerService.ensureLoaded();
    final existing = TripPlannerService.days.value;

    int dayIndex;
    if (existing.isEmpty) {
      await TripPlannerService.addDay();
      dayIndex = 0;
    } else {
      if (!mounted) return;
      final choice = await showModalBottomSheet<_TripDayChoice>(
        context: context,
        backgroundColor: _palette.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _AddToTripSheet(days: existing),
      );
      if (choice == null) return;
      if (choice.isNewDay) {
        await TripPlannerService.addDay();
        dayIndex = TripPlannerService.days.value.length - 1;
      } else {
        dayIndex = choice.dayIndex!;
      }
    }

    final added = await TripPlannerService.addItem(dayIndex, tripItem);
    final label = TripPlannerService.days.value[dayIndex].label;
    if (!mounted) return;
    final palette = _palette;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added ? 'Added to $label' : 'Already in $label'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.accent,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  double? _distanceTo(Landmark lm) {
    final pos = _userPosition;
    if (pos == null) return null;
    return Geolocator.distanceBetween(
        pos.latitude, pos.longitude, lm.lat, lm.lng);
  }

  Future<void> _openInMaps(Landmark lm) async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${lm.lat},${lm.lng}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _showLandmarkSheet(Landmark lm) {
    final distance = _distanceTo(lm);
    final palette = _palette;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: palette.card,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lm.name,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                if (distance != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDistance(distance),
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lm.blurb,
              style: TextStyle(fontSize: 14, color: palette.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style:
                        FilledButton.styleFrom(backgroundColor: palette.accent),
                    onPressed: () => _openInMaps(lm),
                    icon: const Icon(Icons.map),
                    label: const Text('Open in Maps'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.accent,
                      side: BorderSide(color: palette.accent),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _addToTrip(lm);
                    },
                    icon: const Icon(Icons.card_travel),
                    label: const Text('Add to Trip'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _showNearbyList() {
    final withDistance = landmarks
        .map((lm) => (landmark: lm, distance: _distanceTo(lm) ?? double.infinity))
        .toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
    final palette = _palette;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: palette.card,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: withDistance.length,
          itemBuilder: (context, index) {
            final item = withDistance[index];
            final hasDistance = item.distance.isFinite;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: palette.accent,
                foregroundColor: Colors.white,
                child: Text('${index + 1}'),
              ),
              title: Text(
                item.landmark.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              subtitle: Text(
                item.landmark.blurb,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.textSecondary),
              ),
              trailing: hasDistance
                  ? Text(
                      _formatDistance(item.distance),
                      style: TextStyle(color: palette.textSecondary),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                _goToLandmark(item.landmark);
              },
            );
          },
        ),
      ),
    );
  }

  List<Landmark> get _searchResults {
    if (_searchQuery.isEmpty) return const [];
    final q = _searchQuery.toLowerCase();
    return landmarks.where((lm) {
      if (lm.name.toLowerCase().contains(q)) return true;
      return lm.aliases.any((a) => a.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maps',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find landmarks around Kuala Lumpur',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search landmarks',
                hintStyle: TextStyle(color: palette.textSecondary),
                prefixIcon: Icon(Icons.search, color: palette.accent),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close, color: palette.textSecondary),
                        tooltip: 'Clear search',
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _searchQuery = '';
                          _showSearchResults = false;
                        }),
                      ),
                filled: true,
                fillColor: palette.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) => setState(() {
                _searchQuery = value;
                _showSearchResults = value.isNotEmpty;
              }),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _availableCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _availableCategories[index];
                final selected = !_hiddenCategories.contains(category);
                return FilterChip(
                  avatar: Icon(
                    category.icon,
                    size: 16,
                    color: selected ? Colors.white : palette.textSecondary,
                  ),
                  label: Text(category.label),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : palette.textPrimary,
                  ),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: palette.accent,
                  backgroundColor: palette.card,
                  side: BorderSide.none,
                  onSelected: (_) => _toggleCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _klCenter,
                    initialZoom: _initialZoom,
                    minZoom: 10,
                    maxZoom: 18,
                    onTap: (_, __) => _dismissSelection(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'my.com.kltheguide',
                      tileProvider: _CachedTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        for (final lm in landmarks)
                          if (!_hiddenCategories.contains(lm.category))
                            Marker(
                              point: LatLng(lm.lat, lm.lng),
                              width: 44,
                              height: 44,
                              alignment: Alignment.topCenter,
                              child: _LandmarkPin(
                                selected: identical(_selectedLandmark, lm),
                                color: palette.accent,
                                icon: lm.category.icon,
                                onTap: () => _selectLandmark(lm),
                              ),
                            ),
                        if (_userPosition != null)
                          Marker(
                            point: LatLng(
                                _userPosition!.latitude, _userPosition!.longitude),
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Search results overlay
                if (_showSearchResults)
                  Positioned(
                    top: 0,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: palette.card,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: _searchResults.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No landmarks found',
                                  style: TextStyle(color: palette.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final lm = _searchResults[index];
                                  return ListTile(
                                    leading: Icon(lm.category.icon,
                                        color: palette.accent),
                                    title: Text(
                                      lm.name,
                                      style: TextStyle(color: palette.textPrimary),
                                    ),
                                    onTap: () => _goToLandmark(lm),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),

                // Zoom controls - bottom right
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _zoomBy(1),
                              tooltip: 'Zoom In',
                              color: palette.accent,
                            ),
                            Container(
                              height: 1,
                              width: 40,
                              color: palette.textSecondary.withValues(alpha: 0.2),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _zoomBy(-1),
                              tooltip: 'Zoom Out',
                              color: palette.accent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: palette.card,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 2,
                        child: IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _goToMyLocation,
                          tooltip: 'My Location',
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nearby + Reset - bottom center/left
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: _showNearbyList,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.list, size: 18, color: palette.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Nearby',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: _resetView,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: palette.card,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh, size: 18, color: palette.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Reset View',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected landmark - docked card above the bottom controls
                Positioned(
                  bottom: 76,
                  left: 16,
                  right: 16,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _selectedLandmark == null
                        ? const SizedBox.shrink()
                        : _SelectedLandmarkCard(
                            key: ValueKey(_selectedLandmark!.name),
                            landmark: _selectedLandmark!,
                            distanceLabel: () {
                              final d = _distanceTo(_selectedLandmark!);
                              return d == null ? null : _formatDistance(d);
                            }(),
                            palette: palette,
                            onClose: _dismissSelection,
                            onViewDetails: () =>
                                _showLandmarkSheet(_selectedLandmark!),
                            onAddToTrip: () =>
                                _addToTrip(_selectedLandmark!),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandmarkPin extends StatelessWidget {
  const _LandmarkPin({
    required this.selected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedScale(
          scale: selected ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_pin,
                  color:
                      selected ? Color.lerp(color, Colors.black, 0.3) : color,
                  size: 36,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Icon(icon, color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedLandmarkCard extends StatelessWidget {
  const _SelectedLandmarkCard({
    super.key,
    required this.landmark,
    required this.distanceLabel,
    required this.palette,
    required this.onClose,
    required this.onViewDetails,
    required this.onAddToTrip,
  });

  final Landmark landmark;
  final String? distanceLabel;
  final HomePalette palette;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final VoidCallback onAddToTrip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.card,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Icon(landmark.category.icon, color: palette.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected Landmark',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.textSecondary,
                      ),
                    ),
                    Text(
                      landmark.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: palette.textPrimary,
                      ),
                    ),
                    Text(
                      landmark.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.accent,
                            ),
                          ),
                        ),
                        if (distanceLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '· $distanceLabel',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.card_travel, color: palette.accent),
                tooltip: 'Add to Trip',
                onPressed: onAddToTrip,
              ),
              IconButton(
                icon: Icon(Icons.close, color: palette.textSecondary),
                tooltip: 'Dismiss',
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDayChoice {
  final bool isNewDay;
  final int? dayIndex;

  const _TripDayChoice.day(this.dayIndex) : isNewDay = false;
  const _TripDayChoice.newDay()
      : isNewDay = true,
        dayIndex = null;
}

class _AddToTripSheet extends StatelessWidget {
  final List<TripDay> days;

  const _AddToTripSheet({required this.days});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Add to which day?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < days.length; i++)
            ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: palette.accent),
              title: Text(days[i].label, style: TextStyle(color: palette.textPrimary)),
              subtitle: Text(
                '${days[i].items.length} place${days[i].items.length == 1 ? '' : 's'}',
                style: TextStyle(color: palette.textSecondary),
              ),
              onTap: () => Navigator.of(context).pop(_TripDayChoice.day(i)),
            ),
          ListTile(
            leading: Icon(Icons.add, color: palette.accent),
            title: Text('New Day', style: TextStyle(color: palette.textPrimary)),
            onTap: () => Navigator.of(context).pop(const _TripDayChoice.newDay()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
