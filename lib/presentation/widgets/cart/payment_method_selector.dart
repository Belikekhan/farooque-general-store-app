import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PaymentMethodSelector extends StatefulWidget {
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({super.key, required this.onMethodSelected});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  String _selectedMethod = 'cash';

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'card',
      'icon': Icons.credit_card,
      'title': 'Pay by Card',
      'subtitle': 'Debit / Credit Card',
      'expanded': true,
    },
    {
      'id': 'upi',
      'icon': Icons.phone_android,
      'title': 'UPI Payment',
      'subtitle': 'PhonePe · GPay · Paytm',
      'expanded': true,
    },
    {
      'id': 'cash',
      'icon': Icons.money,
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when delivered',
      'expanded': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    widget.onMethodSelected(_selectedMethod);
  }

  void _handleSelect(String id) {
    setState(() => _selectedMethod = id);
    widget.onMethodSelected(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _methods.length,
          itemBuilder: (context, index) {
            final method = _methods[index];
            final isSelected = _selectedMethod == method['id'];

            return Column(
              children: [
                RadioListTile<String>(
                  activeColor: AppColors.primaryGreen,
                  value: method['id'],
                  groupValue: _selectedMethod,
                  onChanged: (val) => _handleSelect(val!),
                  title: Row(
                    children: [
                      Icon(method['icon'], color: AppColors.textDark),
                      const SizedBox(width: 12),
                      Text(
                        method['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(method['subtitle']),
                  ),
                ),
                if (isSelected && method['expanded'])
                  Padding(
                    padding: const EdgeInsets.fromLTRB(68, 0, 16, 16),
                    child: _buildExpandedForm(method['id']),
                  ),
                if (index < _methods.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandedForm(String id) {
    if (id == 'card') {
      return Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Card Number',
              prefixIcon: const Icon(Icons.credit_card),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'CVV',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          )
        ],
      );
    } else if (id == 'upi') {
      return TextField(
        decoration: InputDecoration(
          hintText: 'yourname@upi',
          prefixIcon: const Icon(Icons.alternate_email),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    return const SizedBox();
  }
}
