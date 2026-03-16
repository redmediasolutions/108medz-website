import 'dart:async';
import 'package:jaspr/jaspr.dart';

/// A component that synchronizes state between server and client.
class SyncState<T> extends StatefulComponent {
  final String id;
  final FutureOr<T> Function() create;
  final void Function(T data) update;
  final Component Function(BuildContext context) builder;

  SyncState({
    required this.id,
    required this.create,
    required this.update,
    required this.builder,
    super.key,
  });

  /// Static helper to match the aggregate syntax you were using
  static Component aggregate<T>({
    required String id,
    required FutureOr<T> Function() create,
    required void Function(T data) update,
    required Component Function(BuildContext context) builder,
  }) {
    return SyncState<T>(
      id: id,
      create: create,
      update: update,
      builder: builder,
    );
  }

  @override
  State<SyncState<T>> createState() => _SyncStateState<T>();
}

class _SyncStateState<T> extends State<SyncState<T>> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // In a real Jaspr environment, this would check 
      // the 'SyncState' registry for dehydrated data first.
      final data = await component.create();
      if (!mounted) return;
      setState(() {
        component.update(data);
      });
    } catch (e) {
      print('SyncState Error ($T): $e');
    }
  }

  @override
  Component build(BuildContext context) {
    return component.builder(context);
  }
}
