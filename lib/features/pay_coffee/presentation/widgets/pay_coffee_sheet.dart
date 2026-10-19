import 'package:flutter/material.dart';

class PayCoffeeSheet extends StatefulWidget {
  const PayCoffeeSheet({
    super.key,
    required this.isArabic,
    required this.onConfirm,
  });

  final bool isArabic;
  final ValueChanged<int> onConfirm;

  @override
  State<PayCoffeeSheet> createState() => _PayCoffeeSheetState();
}

class _PayCoffeeSheetState extends State<PayCoffeeSheet> {
  static const _prices = [5, 10, 20];
  int _selectedSize = 0;
  int _quantity = 1;

  String _text(String english, String arabic) =>
      widget.isArabic ? arabic : english;

  int get _total => _prices[_selectedSize] * _quantity;

  @override
  Widget build(BuildContext context) {
    final finalPrice = _total;
    final labels = widget.isArabic
        ? const ['صغير', 'متوسط', 'كبير']
        : const ['Small', 'Medium', 'Large'];

    return FractionallySizedBox(
      heightFactor: .76,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Material(
          color: const Color(0xFF101010),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A2119),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB87945).withValues(alpha: .16),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      size: 48,
                      color: Color(0xFFD5A16F),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _text('Final price', 'السعر النهائي'),
                    style: const TextStyle(
                      color: Color(0xFF989898),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Text(
                      '$finalPrice',
                      key: ValueKey(finalPrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: List.generate(3, (index) {
                      final isSelected = _selectedSize == index;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: index == 2 ? 0 : 8,
                          ),
                          child: _SizeOption(
                            label: labels[index],
                            selected: isSelected,
                            onTap: () => setState(() => _selectedSize = index),
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  _QuantityCounter(
                    quantity: _quantity,
                    onDecrease: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    onIncrease: () => setState(() => _quantity++),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E5E5),
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => widget.onConfirm(_total),
                      child: Text(
                        _text('Confirm', 'تأكيد'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF3F3F3) : const Color(0xFF1B1B1B),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityCounter extends StatelessWidget {
  const _QuantityCounter({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterButton(
            icon: Icons.remove_rounded,
            onPressed: onDecrease,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          icon,
          color: onPressed == null ? Colors.white24 : Colors.white70,
          size: 20,
        ),
      );
}
