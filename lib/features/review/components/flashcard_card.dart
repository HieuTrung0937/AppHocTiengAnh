import 'package:flutter/material.dart';
import 'package:app_hoc_tieng_anh/shared/theme/app_theme.dart';
import 'package:app_hoc_tieng_anh/core/database/vocab_model.dart';
import 'package:app_hoc_tieng_anh/core/services/tts_service.dart';

class FlashcardCard extends StatefulWidget {
  final VocabModel vocab;

  const FlashcardCard({super.key, required this.vocab});

  @override
  State<FlashcardCard> createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard> with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    final textSecondary = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    final cardBgColor = theme.cardColor;

    // ✅ KHÔNG DÙNG SizedBox cố định nữa, mà dùng LayoutBuilder để lấy exact height từ cha
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * 3.14159;
              final frontAngle = angle < 1.5708 ? angle : 1.5708;
              final backAngle = angle > 1.5708 ? angle - 3.14159 : -1.5708;
              final showFront = angle < 1.5708;
              
              return Stack(
                fit: StackFit.expand, // ✅ Chiếm full không gian của LayoutBuilder
                children: [
                  if (showFront)
                    Opacity(
                      opacity: 1.0 - (angle / 1.5708),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(frontAngle),
                        alignment: Alignment.center,
                        child: _buildFrontCard(constraints.maxHeight, cardBgColor, textPrimary, textSecondary),
                      ),
                    ),
                  if (!showFront)
                    Opacity(
                      opacity: (angle - 1.5708) / 1.5708,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(backAngle),
                        alignment: Alignment.center,
                        child: _buildBackCard(constraints.maxHeight, cardBgColor, textPrimary, textSecondary),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFrontCard(double cardHeight, Color cardBgColor, Color textPrimary, Color textSecondary) {
    // Tính font size động dựa trên chiều cao thẻ để luôn TO vừa vặn
    final wordFontSize = (cardHeight * 0.12).clamp(32.0, 60.0);
    final phoneticFontSize = (cardHeight * 0.05).clamp(16.0, 24.0);

    return Card(
      color: cardBgColor,
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildPriorityBadge(),
            ),
            const SizedBox(height: 24),
            
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.vocab.word,
                  style: TextStyle(
                    fontSize: wordFontSize,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.vocab.phonetic,
                style: TextStyle(
                  fontSize: phoneticFontSize,
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            FittedBox(
              fit: BoxFit.scaleDown,
              child: InkWell(
                onTap: () => TtsService().speakUS(widget.vocab.word),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up, size: 24, color: AppColors.primary),
                      const SizedBox(width: 10),
                      const Text(
                        'Nghe phát âm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 20, color: AppColors.primary.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text(
                    'Chạm để lật thẻ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(double cardHeight, Color cardBgColor, Color textPrimary, Color textSecondary) {
    final wordFontSize = (cardHeight * 0.08).clamp(24.0, 40.0);

    return Card(
      color: cardBgColor,
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.vocab.word,
                      style: TextStyle(
                        fontSize: wordFontSize,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => TtsService().speakUS(widget.vocab.word),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up, color: AppColors.primary, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.vocab.phonetic,
                style: TextStyle(fontSize: 16, color: textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(height: 2, width: 50, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection('GIẢI THÍCH', widget.vocab.partOfSpeech, widget.vocab.meaning, textPrimary, textSecondary),
                    const SizedBox(height: 16),
                    _buildInfoSection('VÍ DỤ', null, widget.vocab.example, textPrimary, textSecondary),
                    if (widget.vocab.context.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection('BỐI CẢNH', null, widget.vocab.context, textPrimary, textSecondary),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 16, color: AppColors.primary.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'Chạm để lật lại',
                    style: TextStyle(fontSize: 12, color: AppColors.primary.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    String badgeText = '';
    Color badgeColor = AppColors.primary;
    IconData badgeIcon = Icons.auto_awesome;
    
    if (widget.vocab.forgetCount >= 3) {
      badgeText = 'QUÊN ${widget.vocab.forgetCount} LẦN · ƯU TIÊN';
      badgeColor = AppColors.error;
      badgeIcon = Icons.warning_amber_rounded;
    } else if (widget.vocab.forgetCount > 0) {
      badgeText = 'QUÊN ${widget.vocab.forgetCount} LẦN';
      badgeColor = AppColors.warning;
      badgeIcon = Icons.schedule;
    } else {
      badgeText = 'TỪ MỚI · CẦN ÔN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String? subLabel, String content, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            fontWeight: subLabel != null ? FontWeight.w600 : FontWeight.w400,
            color: textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
