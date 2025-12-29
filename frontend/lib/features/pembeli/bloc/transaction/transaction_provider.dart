import 'package:flutter/material.dart';
import 'package:frontend/features/pembeli/bloc/transaction/transaction_bloc.dart';

/// Inherited widget for providing TransactionBloc
class TransactionProvider extends InheritedWidget {
  final TransactionBloc bloc;

  const TransactionProvider({
    super.key,
    required this.bloc,
    required super.child,
  });

  static TransactionBloc of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<TransactionProvider>();
    assert(provider != null, 'No TransactionProvider found in context');
    return provider!.bloc;
  }

  @override
  bool updateShouldNotify(TransactionProvider oldWidget) => bloc != oldWidget.bloc;
}
