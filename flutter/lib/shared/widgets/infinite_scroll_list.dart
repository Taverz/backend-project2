import 'package:flutter/material.dart';

class InfiniteScrollList<T> extends StatefulWidget {
  const InfiniteScrollList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    this.isLoadingMore = false,
    this.padding,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final EdgeInsetsGeometry? padding;

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        return widget.itemBuilder(context, widget.items[index]);
      },
    );
  }
}
