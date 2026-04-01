import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';

class BossFightScreen extends StatefulWidget {
  const BossFightScreen({super.key});
  @override
  State<BossFightScreen> createState() => _BossFightScreenState();
}

class _BossFightScreenState extends State<BossFightScreen>
    with TickerProviderStateMixin {
  // 0=intro, 1=fighting, 2=victory, 3=defeat
  int _phase = 0;
  int _bossHp = 100;
  int _playerHp = 100;
  int _timeLeft = 90;
  Timer? _gameTimer;
  late AnimationController _shakeCtrl, _glowCtrl, _bossHitCtrl;
  late Animation<double> _shake;
  final List<String> _log = [];
  int _combo = 0;

  static const _bossMoves = [
    '🔥 Urge attacks! (-8 HP)', '😈 Dark thought strikes! (-5 HP)',
    '💀 Isolation urge! (-10 HP)', '🌑 Late night whispers! (-6 HP)',
    '📱 Social feed pulls! (-7 HP)',
  ];

  static const _playerMoves = [
    (label: '⚔️ Resist!', dmg: 12, cost: 0),
    (label: '🧊 Cold Focus', dmg: 18, cost: 5),
    (label: '💪 Force of Will', dmg: 25, cost: 12),
    (label: '🔥 Full Power', dmg: 35, cost: 20),
  ];

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bossHitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _shake = Tween<double>(begin: 0, end: 8).chain(CurveTween(curve: Curves.elasticOut)).animate(_shakeCtrl);
  }

  @override
  void dispose() { _gameTimer?.cancel(); _shakeCtrl.dispose(); _bossHitCtrl.dispose(); _glowCtrl.dispose(); super.dispose(); }

  void _startFight() {
    HapticFeedback.heavyImpact();
    setState(() { _phase = 1; _bossHp = 100; _playerHp = 100; _timeLeft = 90; _log.clear(); _combo = 0; });
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _timeLeft--;
        // Boss attacks every 8 seconds
        if (_timeLeft % 8 == 0 && _bossHp > 0 && _playerHp > 0) {
          final move = _bossMoves[_timeLeft % _bossMoves.length];
          final dmg = 5 + ((_timeLeft % 6));
          _playerHp = (_playerHp - dmg).clamp(0, 100);
          _log.insert(0, move);
          if (_log.length > 6) _log.removeLast();
          _shakeCtrl.forward(from: 0);
          HapticFeedback.mediumImpact();
        }
        if (_playerHp <= 0) { t.cancel(); _phase = 3; }
        if (_bossHp <= 0) { t.cancel(); _phase = 2; }
        if (_timeLeft <= 0) { t.cancel(); _phase = _bossHp < _playerHp ? 2 : 3; }
      });
    });
  }

  void _attack(int dmg, int hpCost) {
    if (_phase != 1 || _bossHp <= 0 || _playerHp <= 0) return;
    HapticFeedback.lightImpact();
    setState(() {
      _combo++;
      final actualDmg = dmg + (_combo > 3 ? 10 : 0);
      _bossHp = (_bossHp - actualDmg).clamp(0, 100);
      if (hpCost > 0) _playerHp = (_playerHp - hpCost).clamp(0, 100);
      final comboText = _combo > 3 ? ' COMBO x$_combo ⚡' : '';
      _log.insert(0, '⚔️ You dealt $actualDmg damage!$comboText');
      if (_log.length > 6) _log.removeLast();
      _bossHitCtrl.forward(from: 0);
      if (_bossHp <= 0) { _gameTimer?.cancel(); _phase = 2; HapticFeedback.heavyImpact(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () { _gameTimer?.cancel(); Navigator.pop(context); },
                  child: Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.close, color: AppTheme.textMuted, size: 18.sp)),
                ),
                SizedBox(width: 14.w),
                Text('🎮 BOSS FIGHT MODE', style: TextStyle(fontSize: 11.sp, color: AppTheme.statusDanger, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
              ]),
            ),
            Expanded(child: _buildPhase()),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case 0: return _buildIntro();
      case 1: return _buildFight();
      case 2: return _buildVictory();
      case 3: return _buildDefeat();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildIntro() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Container(
            width: 130.w, height: 130.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.statusDanger.withOpacity(0.1), boxShadow: [BoxShadow(color: AppTheme.statusDanger.withOpacity(0.2 + 0.2 * _glowCtrl.value), blurRadius: 40)]),
            child: Center(child: Text('😈', style: TextStyle(fontSize: 64.sp))),
          ),
        ),
        SizedBox(height: 24.h),
        Text('THE URGE BOSS', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: AppTheme.statusDanger, letterSpacing: 2)),
        SizedBox(height: 8.h),
        Text('It\'s attacking your willpower.\nSurvive 90 seconds to defeat it.', style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted, height: 1.6), textAlign: TextAlign.center),
        SizedBox(height: 12.h),
        Text('⚔️ Attack the Boss\n💀 Let it attack you\n🏆 Last man standing wins', style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary, height: 1.7), textAlign: TextAlign.center),
        SizedBox(height: 36.h),
        GestureDetector(
          onTap: _startFight,
          child: Container(
            width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), color: AppTheme.statusDanger, boxShadow: [BoxShadow(color: AppTheme.statusDanger.withOpacity(0.4), blurRadius: 20)]),
            alignment: Alignment.center,
            child: Text('START THE FIGHT', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
          ),
        ),
      ]),
    );
  }

  Widget _buildFight() {
    final bossColorVal = _bossHp > 60 ? AppTheme.statusSuccess : _bossHp > 30 ? const Color(0xFFF59E0B) : AppTheme.statusDanger;
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          // HP Bars
          _HpBar(label: 'Boss HP', value: _bossHp, color: bossColorVal),
          SizedBox(height: 8.h),
          _HpBar(label: 'Your HP', value: _playerHp, color: AppTheme.primary),
          SizedBox(height: 12.h),

          // Timer
          Text('⏱ ${_timeLeft}s', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: _timeLeft < 20 ? AppTheme.statusDanger : AppTheme.textMuted)),

          SizedBox(height: 12.h),

          // Boss
          AnimatedBuilder(
            animation: _shake,
            builder: (_, __) => Transform.translate(
              offset: Offset(_shake.value * math.sin(_shake.value), 0),
              child: AnimatedBuilder(
                animation: _bossHitCtrl,
                builder: (_, __) => Container(
                  width: 100.w, height: 100.w,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.statusDanger.withOpacity(0.1 + 0.15 * _bossHitCtrl.value), boxShadow: [BoxShadow(color: AppTheme.statusDanger.withOpacity(0.3), blurRadius: 24)]),
                  child: Center(child: Text('😈', style: TextStyle(fontSize: 52.sp))),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Battle log
          Container(
            height: 90.h,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white.withOpacity(0.07))),
            child: ListView(physics: const NeverScrollableScrollPhysics(), reverse: false, children: _log.map((l) => Text(l, style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted, height: 1.5))).toList()),
          ),

          const Spacer(),

          // Attack buttons
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8.w, mainAxisSpacing: 8.h, childAspectRatio: 2.8,
            children: _playerMoves.map((m) => GestureDetector(
              onTap: () => _attack(m.dmg, m.cost),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppTheme.primary.withOpacity(0.10),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(m.label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  if (m.cost > 0) Text('-${m.cost} HP', style: TextStyle(fontSize: 8.sp, color: AppTheme.textMuted)),
                ]),
              ),
            )).toList(),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildVictory() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('👑', style: TextStyle(fontSize: 72.sp)),
        SizedBox(height: 16.h),
        ShaderMask(shaderCallback: (b) => AppTheme.goldGradient.createShader(b), child: Text('BOSS DEFEATED!', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2))),
        SizedBox(height: 12.h),
        Text('The urge tried to defeat you.\nYou held on and won.\n\nThis is what real power feels like.', style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted, height: 1.7), textAlign: TextAlign.center),
        SizedBox(height: 32.h),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 16.h), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), gradient: AppTheme.goldGradient, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24)]), alignment: Alignment.center, child: Text('CHAMPION VICTORY', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5))),
        ),
      ]),
    );
  }

  Widget _buildDefeat() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('💀', style: TextStyle(fontSize: 72.sp)),
        SizedBox(height: 16.h),
        Text('BOSS WON THIS ROUND', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.statusDanger, letterSpacing: 1.5), textAlign: TextAlign.center),
        SizedBox(height: 12.h),
        Text('It got you this time. But every warrior\n loses a battle before winning the war.\n\nGet up. The next fight is yours.', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, height: 1.7), textAlign: TextAlign.center),
        SizedBox(height: 32.h),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => setState(() { _phase = 0; _gameTimer?.cancel(); }), child: Container(padding: EdgeInsets.symmetric(vertical: 14.h), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), border: Border.all(color: AppTheme.statusDanger.withOpacity(0.4)), color: AppTheme.statusDanger.withOpacity(0.08)), alignment: Alignment.center, child: Text('Rematch', style: TextStyle(fontSize: 13.sp, color: AppTheme.statusDanger, fontWeight: FontWeight.w800))))),
          SizedBox(width: 10.w),
          Expanded(child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: EdgeInsets.symmetric(vertical: 14.h), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.r), gradient: AppTheme.goldGradient), alignment: Alignment.center, child: Text('Fight Tomorrow', style: TextStyle(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w900))))),
        ]),
      ]),
    );
  }
}

class _HpBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _HpBar({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 60.w, child: Text(label, style: TextStyle(fontSize: 9.sp, color: AppTheme.textMuted))),
    Expanded(
      child: Stack(children: [
        Container(height: 10.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.r), color: Colors.white.withOpacity(0.06))),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 10.h,
          width: double.infinity * (value / 100),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.r), color: color),
        ),
        FractionallySizedBox(
          widthFactor: value / 100,
          child: Container(height: 10.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.r), color: color)),
        ),
      ]),
    ),
    SizedBox(width: 6.w),
    Text('$value', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: color)),
  ]);
}
