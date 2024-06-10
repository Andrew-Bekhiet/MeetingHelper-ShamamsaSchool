// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TermCWProxy {
  Term ref(DocumentReference<Object?> ref);

  Term order(int order);

  Term from(DateTime from);

  Term to(DateTime to);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Term(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Term(...).copyWith(id: 12, name: "My name")
  /// ````
  Term call({
    DocumentReference<Object?>? ref,
    int? order,
    DateTime? from,
    DateTime? to,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTerm.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTerm.copyWith.fieldName(...)`
class _$TermCWProxyImpl implements _$TermCWProxy {
  const _$TermCWProxyImpl(this._value);

  final Term _value;

  @override
  Term ref(DocumentReference<Object?> ref) => this(ref: ref);

  @override
  Term order(int order) => this(order: order);

  @override
  Term from(DateTime from) => this(from: from);

  @override
  Term to(DateTime to) => this(to: to);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Term(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Term(...).copyWith(id: 12, name: "My name")
  /// ````
  Term call({
    Object? ref = const $CopyWithPlaceholder(),
    Object? order = const $CopyWithPlaceholder(),
    Object? from = const $CopyWithPlaceholder(),
    Object? to = const $CopyWithPlaceholder(),
  }) {
    return Term(
      ref: ref == const $CopyWithPlaceholder() || ref == null
          ? _value.ref
          // ignore: cast_nullable_to_non_nullable
          : ref as DocumentReference<Object?>,
      order: order == const $CopyWithPlaceholder() || order == null
          ? _value.order
          // ignore: cast_nullable_to_non_nullable
          : order as int,
      from: from == const $CopyWithPlaceholder() || from == null
          ? _value.from
          // ignore: cast_nullable_to_non_nullable
          : from as DateTime,
      to: to == const $CopyWithPlaceholder() || to == null
          ? _value.to
          // ignore: cast_nullable_to_non_nullable
          : to as DateTime,
    );
  }
}

extension $TermCopyWith on Term {
  /// Returns a callable class that can be used as follows: `instanceOfTerm.copyWith(...)` or like so:`instanceOfTerm.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TermCWProxy get copyWith => _$TermCWProxyImpl(this);
}
