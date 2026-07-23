import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';
import 'package:kltheguide/services/cache_service.dart';
import 'package:kltheguide/widgets/state_views.dart';

/// Loads [load] into a FutureBuilder and renders [builder] on success.
/// Shows a spinner while loading and a retry prompt on failure, so a
/// dropped connection doesn't leave the user staring at a raw exception.
/// If [isEmpty] is given and reports the loaded data as empty, [emptyBuilder]
/// (or a default "nothing here" view) is shown instead of [builder].
/// If [load] falls back to cached data (see [CacheService]), a small
/// "showing saved content" banner is shown above [builder].
class ApiFutureView<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final WidgetBuilder? emptyBuilder;

  const ApiFutureView({
    super.key,
    required this.load,
    required this.builder,
    this.isEmpty,
    this.emptyBuilder,
  });

  @override
  State<ApiFutureView<T>> createState() => _ApiFutureViewState<T>();
}

class _ApiFutureViewState<T> extends State<ApiFutureView<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  Future<T> _reload() {
    final next = widget.load();
    setState(() {
      CacheService.isServingCachedContent.value = false;
      _future = next;
    });
    return next;
  }

  void _retry() => _reload();

  Future<void> _onRefresh() async {
    try {
      await _reload();
    } catch (_) {
      // The FutureBuilder below renders the error state; this only needs
      // to complete so RefreshIndicator dismisses its spinner.
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return ErrorStateView(
            message: 'Could not load content.\nCheck your connection and try again.',
            onRetry: _retry,
          );
        }
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(color: palette.accent));
        }
        final data = snap.data as T;
        final isEmpty = widget.isEmpty?.call(data) ?? false;
        final content = isEmpty
            ? (widget.emptyBuilder?.call(context) ?? const EmptyStateView())
            : widget.builder(context, data);
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: palette.accent,
          child: ValueListenableBuilder<bool>(
            valueListenable: CacheService.isServingCachedContent,
            builder: (context, isCached, child) {
              if (!isCached) return child!;
              return Column(
                children: [
                  _OfflineBanner(),
                  Expanded(child: child!),
                ],
              );
            },
            child: content,
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.amber[900]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing saved content — you\'re offline',
              style: TextStyle(fontSize: 12, color: Colors.amber[900]),
            ),
          ),
        ],
      ),
    );
  }
}
