import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {
  final Locale locale;

  const SettingsInitial({this.locale = const Locale('ar', 'EG')});

  @override
  List<Object> get props => [locale];
}

class SettingsUpdated extends SettingsState {
  final Locale locale;

  const SettingsUpdated(this.locale);

  @override
  List<Object> get props => [locale];
}

// Cubit
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsInitial());

  void changeLanguage(Locale locale) {
    emit(SettingsUpdated(locale));
  }

  Locale get currentLocale {
    if (state is SettingsInitial) {
      return (state as SettingsInitial).locale;
    } else if (state is SettingsUpdated) {
      return (state as SettingsUpdated).locale;
    }
    return const Locale('ar', 'EG');
  }
}
