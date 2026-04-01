import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const _bg = Color(0xFF06050A);
const _surf = Color(0xFF100F1A);
const _gold = Color(0xFFFFCC44);
const _amber = Color(0xFFFFAA00);
const _textPri = Color(0xFFF2F2F2);
const _textSec = Color(0xFF8A8A9A);

const _tiers = [
  _Tier('☕', 'Coffee', 'Fuel one late-night bug fix', Color(0xFF6DD5ED), Color(0xFF2193B0), '1', false),
  _Tier('🥤', 'Smoothie', 'Keep the team energised', Color(0xFFDA8FFF), Color(0xFF8B5CF6), '2', false),
  _Tier('🥪', 'Sandwich', 'Power through a full sprint', Color(0xFFFF8A65), Color(0xFFE53935), '3', false),
  _Tier('🍕', 'Pizza', 'Celebrate a milestone release', Color(0xFFFF80AB), Color(0xFFF50057), '4', true),
  _Tier('🍱', 'Lunch Box', 'Support a whole dev day', Color(0xFF69FFBA), Color(0xFF00B09B), '5', false),
  _Tier('🎁', 'Huge Love', 'You are an absolute legend!', Color(0xFFFFCC44), Color(0xFFFF8C00), '6', false),
  _Tier('🎉', 'Surprise!', 'Let us be amazed — thank you', Color(0xFF89F7FE), Color(0xFF66A6FF), '7', false),
];

class _Tier {
  final String emoji, title, subtitle, productId;
  final Color colorA, colorB;
  final bool popular;
  const _Tier(this.emoji, this.title, this.subtitle, this.colorA, this.colorB, this.productId, this.popular);
}

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});
  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _shimCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade, _entrySlide;

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _sub;
  final List<ProductDetails> _products = [];
  bool _loading = true;
  bool _storeAvail = true;
  static const _productIds = ['1', '2', '3', '4', '5', '6', '7'];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _shimCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<double>(begin: 32, end: 0).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate, onDone: () => _sub.cancel());
    _loadProducts();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _glowCtrl.dispose();
    _shimCtrl.dispose();
    _entryCtrl.dispose();
    _sub.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final available = await InAppPurchase.instance.isAvailable();
    _storeAvail = available;
    if (available) {
      final resp = await _iap.queryProductDetails(_productIds.toSet());
      _products.addAll(resp.productDetails..sort((a, b) => a.id.compareTo(b.id)));
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.status == PurchaseStatus.pending)
        _snack('Processing… ⏳');
      else if (p.status == PurchaseStatus.purchased)
        _snack('Thank you so much! 🎉', good: true);
      else if (p.status == PurchaseStatus.error || p.status == PurchaseStatus.canceled) _snack('Purchase failed — please try again', good: false);
      if (p.pendingCompletePurchase) await InAppPurchase.instance.completePurchase(p);
    }
  }

  void _snack(String msg, {bool? good}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: good == null
          ? _surf
          : good
              ? const Color(0xFF1A3D2B)
              : const Color(0xFF3D1A1A),
      content: Text(msg, style: const TextStyle(color: _textPri, fontFamily: 'Delius')),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  void _buy(ProductDetails product) {
    _iap.buyConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  _Tier _tierFor(ProductDetails p) => _tiers.firstWhere((t) => t.productId == p.id, orElse: () => _tiers.last);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _glowCtrl]),
        builder: (_, child) => Stack(children: [
          CustomPaint(size: size, painter: _BgPainter(t: _bgCtrl.value, glow: _glowCtrl.value)),
          child!,
        ]),
        child: FadeTransition(
          opacity: _entryFade,
          child: AnimatedBuilder(
            animation: _entrySlide,
            builder: (_, child) => Transform.translate(offset: Offset(0, _entrySlide.value), child: child),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHero(),
                SliverToBoxAdapter(child: _buildStats()),
                SliverToBoxAdapter(child: _buildTeamNote()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 48.h),
                  sliver: _loading
                      ? _buildLoading()
                      : !_storeAvail || _products.isEmpty
                          ? _buildUnavailable()
                          : _buildTiers(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _glowCtrl]),
        builder: (_, __) {
          final glow = _glowCtrl.value;
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, MediaQuery.of(context).padding.top + 12.h, 20.w, 28.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1000), Color(0xFF0D0A00), Color(0xFF06050A)],
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Icon(Iconsax.arrow_left, size: 18.sp, color: Colors.white),
                  ),
                ),
              ]),
              SizedBox(height: 28.h),
              Center(
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        _gold.withOpacity(0.18 + glow * 0.12),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold.withOpacity(0.18 + glow * 0.14), width: 1.5),
                    ),
                  ),
                  Container(
                    width: 68.w,
                    height: 68.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _gold.withOpacity(0.25 + glow * 0.10),
                          _amber.withOpacity(0.18 + glow * 0.08),
                        ],
                      ),
                      border: Border.all(color: _gold.withOpacity(0.45 + glow * 0.20)),
                      boxShadow: [
                        BoxShadow(color: _gold.withOpacity(0.22 + glow * 0.18), blurRadius: 24, spreadRadius: 2),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: 1.0 + glow * 0.08,
                      child: Icon(Iconsax.heart, size: 30.sp, color: _gold),
                    ),
                  ),
                ]),
              ),
              SizedBox(height: 22.h),
              Center(
                child: ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Color(0xFFFFE57F), Color(0xFFFFCC44), Color(0xFFFFAA00)],
                  ).createShader(r),
                  child: Text('Support Our Mission',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Delius', height: 1.1)),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  'We\'re a small student team building something\nyou love — help us keep the lights on! 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.58), fontFamily: 'Delius', height: 1.55),
                ),
              ),
              SizedBox(height: 18.h),
              Center(
                child: Wrap(spacing: 8.w, runSpacing: 6.h, children: [
                  _heroBadge(Iconsax.security_safe, 'Secure Payment'),
                  _heroBadge(Iconsax.flash, 'Instant'),
                  _heroBadge(Iconsax.unlimited, 'No Subscription'),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _heroBadge(IconData icon, String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _gold.withOpacity(0.22)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11.sp, color: _gold),
          SizedBox(width: 5.w),
          Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: _gold.withOpacity(0.85), fontFamily: 'Delius')),
        ]),
      );

  Widget _buildStats() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _gold.withOpacity(0.18)),
      ),
      child: Row(children: [
        _statItem('500+', 'Happy Users'),
        _statDivider(),
        _statItem('100%', 'Goes to Dev'),
        _statDivider(),
        _statItem('❤️', 'Made with love'),
      ]),
    );
  }

  Widget _statItem(String value, String label) => Expanded(
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _gold, fontFamily: 'Delius')),
          SizedBox(height: 2.h),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5.sp, color: _textSec, fontFamily: 'Delius')),
        ]),
      );
  Widget _statDivider() => Container(width: 1, height: 32.h, color: _gold.withOpacity(0.18), margin: EdgeInsets.symmetric(horizontal: 4.w));

  Widget _buildTeamNote() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _surf,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🤝', style: TextStyle(fontSize: 26.sp)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('From our team, with gratitude',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _textPri, fontFamily: 'Delius')),
            SizedBox(height: 5.h),
            Text(
              'Every contribution — big or small — directly funds new features, bug fixes, and keeps the app free forever. Pick whatever feels right. You\'re a legend either way! 🌟',
              style: TextStyle(fontSize: 11.sp, color: _textSec, fontFamily: 'Delius', height: 1.55),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTiers() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) {
          final p = _products[i];
          final tier = _tierFor(p);
          return _buildTierCard(p, tier);
        },
        childCount: _products.length,
      ),
    );
  }

  Widget _buildTierCard(ProductDetails product, _Tier tier) {
    return AnimatedBuilder(
      animation: _shimCtrl,
      builder: (_, __) {
        final shimPos = _shimCtrl.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _surf,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: tier.popular ? tier.colorA.withOpacity(0.50) : tier.colorA.withOpacity(0.18),
                    width: tier.popular ? 1.5 : 1.0,
                  ),
                  boxShadow: tier.popular
                      ? [BoxShadow(color: tier.colorA.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Stack(children: [
                    if (tier.popular)
                      Positioned.fill(
                        child: ShaderMask(
                          shaderCallback: (r) => LinearGradient(
                            begin: Alignment(-2 + shimPos * 4, 0),
                            end: Alignment(-1.5 + shimPos * 4, 0),
                            colors: [Colors.transparent, tier.colorA.withOpacity(0.08), Colors.transparent],
                          ).createShader(r),
                          child: Container(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [tier.colorA, tier.colorB],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(22.r),
                            bottomLeft: Radius.circular(22.r),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _buy(product),
                        splashColor: tier.colorA.withOpacity(0.10),
                        highlightColor: tier.colorA.withOpacity(0.05),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(18.w, 14.h, 14.w, 14.h),
                          child: Row(children: [
                            Container(
                              width: 54.w,
                              height: 54.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [tier.colorA.withOpacity(0.18), tier.colorB.withOpacity(0.12)],
                                ),
                                border: Border.all(color: tier.colorA.withOpacity(0.28)),
                              ),
                              alignment: Alignment.center,
                              child: Text(tier.emoji, style: TextStyle(fontSize: 26.sp)),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                Row(children: [
                                  Text(tier.title,
                                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _textPri, fontFamily: 'Delius')),
                                  if (tier.popular) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [tier.colorA, tier.colorB]),
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Text('⭐ Popular',
                                          style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Delius')),
                                    ),
                                  ],
                                ]),
                                SizedBox(height: 3.h),
                                Text(tier.subtitle, style: TextStyle(fontSize: 11.sp, color: _textSec, fontFamily: 'Delius', height: 1.4)),
                              ]),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [tier.colorA, tier.colorB],
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(color: tier.colorA.withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 3)),
                                ],
                              ),
                              child: Text(product.price,
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Delius')),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() => SliverToBoxAdapter(
        child: SizedBox(
            height: 220.h,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    width: 36.w,
                    height: 36.w,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: _gold, backgroundColor: _gold.withOpacity(0.12))),
                SizedBox(height: 16.h),
                Text('Loading options…', style: TextStyle(fontSize: 13.sp, color: _textSec, fontFamily: 'Delius')),
              ]),
            )),
      );

  Widget _buildUnavailable() => SliverToBoxAdapter(
        child: SizedBox(
            height: 240.h,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Iconsax.shop_remove, size: 48.sp, color: _textSec),
                SizedBox(height: 16.h),
                Text('Store unavailable', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textPri, fontFamily: 'Delius')),
                SizedBox(height: 6.h),
                Text('Please try again later', style: TextStyle(fontSize: 13.sp, color: _textSec, fontFamily: 'Delius')),
              ]),
            )),
      );
}

class _BgPainter extends CustomPainter {
  final double t, glow;
  const _BgPainter({required this.t, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _bg);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.18 + math.sin(t * math.pi * 2) * h * 0.03),
        width: w * 0.9,
        height: h * 0.36,
      ),
      Paint()
        ..shader = RadialGradient(colors: [
          _amber.withOpacity(0.16 + glow * 0.10),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.18), radius: w * 0.45)),
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.80, h * 0.80), width: w * 0.55, height: h * 0.28),
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF8B5CF6).withOpacity(0.08 + glow * 0.04),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(w * 0.80, h * 0.80), radius: w * 0.28)),
    );

    for (int i = 0; i < 20; i++) {
      final seed = i * 0.618;
      final x = ((seed * 6.7 + math.sin(t * math.pi * 2 + i * 0.6) * 0.04) % 1.0) * w;
      final y = ((seed * 4.1 + t * 0.35 + i * 0.07) % 1.0) * h;
      canvas.drawCircle(Offset(x, y), 0.6 + (i % 3) * 0.5, Paint()..color = _gold.withOpacity(0.04 + (i % 5) * 0.015));
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t || old.glow != glow;
}
