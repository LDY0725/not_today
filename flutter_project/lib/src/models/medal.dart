import 'package:flutter/material.dart';
import 'dart:convert';

class Medal {
  final String id;
  final String name;
  final String iconName;
  final int requiredDays;
  final String description;
  final int iconWeight;
  final bool isUnlocked;

  Medal({
    required this.id,
    required this.name,
    required this.iconName,
    required this.requiredDays,
    required this.description,
    this.iconWeight = 200,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'requiredDays': requiredDays,
      'description': description,
      'iconWeight': iconWeight,
      'isUnlocked': isUnlocked,
    };
  }

  factory Medal.fromJson(Map<String, dynamic> json) {
    return Medal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconName: json['iconName'] ?? 'star',
      requiredDays: json['requiredDays'] ?? 0,
      description: json['description'] ?? '',
      iconWeight: json['iconWeight'] ?? 200,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}

class MedalData {
  final List<Medal> medals;
  final int currentStreak;

  MedalData({
    required this.medals,
    required this.currentStreak,
  });

  List<Medal> get unlockedMedals =>
      medals.where((m) => m.isUnlocked).toList();

  List<Medal> get lockedMedals =>
      medals.where((m) => !m.isUnlocked).toList();

  int get totalMedals => medals.length;
  int get unlockedCount => unlockedMedals.length;

  Medal? getNextUnlockableMedal() {
    final sortedLocked = lockedMedals
      ..sort((a, b) => a.requiredDays.compareTo(b.requiredDays));
    return sortedLocked.isNotEmpty ? sortedLocked.first : null;
  }
}

class MedalService {
  static MedalService? _instance;
  late List<Medal> _medals;

  MedalService._();

  static MedalService getInstance() {
    _instance ??= MedalService._();
    _instance!._initializeMedals();
    return _instance!;
  }

  void _initializeMedals() {
    _medals = [
      Medal(
        id: 'coffee_master',
        name: '咖啡因续命师',
        iconName: 'coffee',
        requiredDays: 7,
        description: '连续签到 7 天',
        iconWeight: 200,
        isUnlocked: true,
      ),
      Medal(
        id: 'watcher',
        name: '观望型选手',
        iconName: 'satellite',
        requiredDays: 15,
        description: '还差一点，再忍忍',
        iconWeight: 200,
        isUnlocked: false,
      ),
      Medal(
        id: 'invisible_king',
        name: '老板看不见的忍耐王',
        iconName: 'visibility_off',
        requiredDays: 30,
        description: '解锁条件：连续签到 30 天',
        iconWeight: 200,
        isUnlocked: false,
      ),
      Medal(
        id: 'next_year',
        name: '明年再说型选手',
        iconName: 'sentiment_neutral',
        requiredDays: 31,
        description: '解锁条件：连续签到 > 30 天',
        iconWeight: 200,
        isUnlocked: false,
      ),
    ];
  }

  MedalData getMedalData(int currentStreak) {
    final medalsWithStatus = _medals.map((medal) {
      return Medal(
        id: medal.id,
        name: medal.name,
        iconName: medal.iconName,
        requiredDays: medal.requiredDays,
        description: medal.description,
        iconWeight: medal.iconWeight,
        isUnlocked: currentStreak >= medal.requiredDays,
      );
    }).toList();

    return MedalData(
      medals: medalsWithStatus,
      currentStreak: currentStreak,
    );
  }

  List<Medal> getAllMedals(int currentStreak) {
    return _medals.map((medal) {
      return Medal(
        id: medal.id,
        name: medal.name,
        iconName: medal.iconName,
        requiredDays: medal.requiredDays,
        description: medal.description,
        iconWeight: medal.iconWeight,
        isUnlocked: currentStreak >= medal.requiredDays,
      );
    }).toList();
  }
}

IconData getIconData(String iconName) {
  switch (iconName) {
    case 'coffee':
      return Icons.coffee;
    case 'satellite':
      return Icons.satellite;
    case 'visibility_off':
      return Icons.visibility_off;
    case 'sentiment_neutral':
      return Icons.sentiment_neutral;
    default:
      return Icons.star;
  }
}
