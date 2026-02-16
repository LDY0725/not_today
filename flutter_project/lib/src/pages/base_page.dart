import 'package:flutter/material.dart';
import '../components/loading_indicator.dart';
import '../components/error_view.dart';

mixin BasePageController<T extends StatefulWidget> on State<T> {
  bool _isLoading = true;
  String? _errorMessage;
  dynamic _errorData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  dynamic get errorData => _errorData;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        if (loading) {
          _errorMessage = null;
          _errorData = null;
        }
      });
    }
  }

  void setError(String message, {dynamic data}) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = message;
        _errorData = data;
      });
    }
  }

  void clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _errorData = null;
      });
    }
  }

  void loadData() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Widget buildContent(BuildContext context);
  String get pageTitle => '';
  bool get showAppBar => true;
  List<Widget>? buildActions(BuildContext context) => null;
  Widget? buildLeading(BuildContext context) => null;
  Color? get backgroundColor => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(pageTitle),
              actions: buildActions(context),
              leading: buildLeading(context),
            )
          : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        data: _errorData,
        onRetry: loadData,
      );
    }

    return buildContent(context);
  }
}
