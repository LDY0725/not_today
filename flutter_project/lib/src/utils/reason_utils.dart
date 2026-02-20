// 原因维度枚举
enum Reason {
  workload, // W
  emotionalDrain, // E
  uncertainty, // U
  interpersonal, // I
  compensation, // C
  boredom, // B
}

// 使用时间段枚举
enum TimeSlot {
  sunNight, // SUN_NIGHT
  wkdayDay, // WKDAY_DAY
  monMorning, // MON_MORNING
  friNight, // FRI_NIGHT
  other, // OTHER
}

// 每日输入数据
class DailyInput {
  final int c; // 单日点击次数
  final double delta; // 连续点击间隔均值 (ms)
  final double t; // 单次使用时长均值 (秒)
  final TimeSlot slot; // 使用时间段

  DailyInput({
    required this.c,
    required this.delta,
    required this.t,
    required this.slot,
  });
}

// 阈值配置（工程配置项）
class ThresholdConfig {
  final double c0; // 点击次数低阈值
  final double c1; // 点击次数高阈值
  final double d0; // 间隔快阈值 (ms)
  final double d1; // 间隔慢阈值 (ms)
  final double t0; // 时长短阈值 (秒)
  final double t1; // 时长 长阈值 (秒)

  ThresholdConfig({
    this.c0 = 3,
    this.c1 = 20,
    this.d0 = 150,
    this.d1 = 1200,
    this.t0 = 3,
    this.t1 = 60,
  });
}

// 工具类
class ReasonScoreUtils {
  final ThresholdConfig config;

  ReasonScoreUtils({ThresholdConfig? config})
      : config = config ?? ThresholdConfig();

  // 截断线性函数
  double _clip01(double x) {
    return x < 0 ? 0 : (x > 1 ? 1 : x);
  }

  // 归一化函数
  double _norm(double x, double a, double b) {
    if (b == a) return 0; // 避免除零
    return _clip01((x - a) / (b - a));
  }

  // 计算四个可用特征
  Map<String, double> _computeFeatures(DailyInput input) {
    final fc = _norm(input.c.toDouble(), config.c0, config.c1);
    final normDelta = _norm(input.delta, config.d0, config.d1);
    final fFast = 1 - normDelta;
    final fSlow = normDelta;
    final normT = _norm(input.t, config.t0, config.t1);
    final fExit = 1 - normT;

    return {
      'fc': fc,
      'fFast': fFast,
      'fSlow': fSlow,
      'fExit': fExit,
    };
  }

  // 计算时间段偏置向量 b(slot)
  Map<Reason, double> _computeSlotBias(TimeSlot slot) {
    switch (slot) {
      case TimeSlot.sunNight:
        return {
          Reason.emotionalDrain: 1.0,
          Reason.boredom: 0.2,
        };
      case TimeSlot.wkdayDay:
        return {
          Reason.workload: 1.0,
        };
      case TimeSlot.monMorning:
        return {
          Reason.uncertainty: 1.0,
        };
      case TimeSlot.friNight:
        return {
          Reason.boredom: 1.0,
          Reason.emotionalDrain: 0.2,
        };
      case TimeSlot.other:
        return {};
    }
  }

  // 计算每日原始分数向量 s_d = [s_W, s_E, s_U, s_I, s_C, s_B]
  List<double> computeDailyScores(DailyInput input) {
    final features = _computeFeatures(input);
    final fc = features['fc']!;
    final fFast = features['fFast']!;
    final fSlow = features['fSlow']!;
    final fExit = features['fExit']!;

    final slotBias = _computeSlotBias(input.slot);
    final bW = slotBias[Reason.workload] ?? 0.0;
    final bE = slotBias[Reason.emotionalDrain] ?? 0.0;
    final bU = slotBias[Reason.uncertainty] ?? 0.0;
    final bI = slotBias[Reason.interpersonal] ?? 0.0;
    final bC = slotBias[Reason.compensation] ?? 0.0;
    final bB = slotBias[Reason.boredom] ?? 0.0;

    final sW = 0.8 * fc + 0.3 * bW;
    final sE = 1.0 * fc * fFast + 0.6 * bE;
    final sU = 0.9 * fSlow + 0.5 * bU;
    final sI = 0.4 * fc + 0.4 * bI;
    final sC = 0.4 * fc + 0.4 * bC;
    final sB = 1.0 * fExit + 0.6 * bB;

    return [sW, sE, sU, sI, sC, sB];
  }

  // 应用连续打卡天数增强规则
  List<double> applyStreakEnhancement(
    List<double> rawScores,
    int streakDays,
  ) {
    if (rawScores.length != 6) {
      throw ArgumentError('rawScores must be a 6-element list');
    }

    double sW = rawScores[0];
    double sE = rawScores[1];
    final sU = rawScores[2];
    final sI = rawScores[3];
    final sC = rawScores[4];
    final sB = rawScores[5];

    if (streakDays > 7) {
      sW *= 1.1;
    }
    if (streakDays > 30) {
      sW *= 1.1;
      sE *= 1.3;
    }

    return [sW, sE, sU, sI, sC, sB];
  }

  // 完整流程：输入 + 打卡天数 → 最终分数向量
  List<double> computeFinalScores(DailyInput input, int streakDays) {
    final raw = computeDailyScores(input);
    return applyStreakEnhancement(raw, streakDays);
  }
}
