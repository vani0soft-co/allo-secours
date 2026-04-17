import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/parcel_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/parcel_provider.dart';
import '../../../services/notification_service.dart';
import '../../../models/notification_model.dart';

class CreateParcelScreen extends ConsumerStatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  ConsumerState<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends ConsumerState<CreateParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _recipientAddressCtrl = TextEditingController();
  final _senderAddressCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _dimensionsCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  ParcelType _type = ParcelType.standard;
  bool _loading = false;
  int _step = 0;

  @override
  void dispose() {
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _recipientAddressCtrl.dispose();
    _senderAddressCtrl.dispose();
    _weightCtrl.dispose();
    _dimensionsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _estimatedPrice {
    final w = double.tryParse(_weightCtrl.text.replaceAll(',', '.')) ?? 0;
    return ref.read(parcelServiceProvider).calculatePrice(w, _type);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await ref.read(userStreamProvider.future);
      final id = await ref.read(parcelServiceProvider).createParcel(
            sender: user!,
            recipientName: _recipientNameCtrl.text.trim(),
            recipientPhone: _recipientPhoneCtrl.text.trim(),
            recipientAddress: _recipientAddressCtrl.text.trim(),
            senderAddress: _senderAddressCtrl.text.trim(),
            weight: double.parse(_weightCtrl.text.replaceAll(',', '.')),
            dimensions: _dimensionsCtrl.text.trim().isEmpty
                ? null
                : _dimensionsCtrl.text.trim(),
            type: _type,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );

      await NotificationService.saveNotification(
        userId: user.id,
        title: 'Colis enregistré',
        body: 'Votre envoi vers ${_recipientNameCtrl.text.trim()} a été créé.',
        type: NotificationType.parcel,
        refId: id,
      );

      if (mounted) {
        context.go('/client/parcels');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Colis créé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Envoyer un colis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Stepper header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _StepDot(index: 0, current: _step, label: 'Expéditeur'),
                  _StepLine(active: _step >= 1),
                  _StepDot(index: 1, current: _step, label: 'Destinataire'),
                  _StepLine(active: _step >= 2),
                  _StepDot(index: 2, current: _step, label: 'Colis'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _Step0(ctrl: _senderAddressCtrl)
                      : _step == 1
                          ? _Step1(
                              nameCtrl: _recipientNameCtrl,
                              phoneCtrl: _recipientPhoneCtrl,
                              addressCtrl: _recipientAddressCtrl,
                            )
                          : _Step2(
                              weightCtrl: _weightCtrl,
                              dimensionsCtrl: _dimensionsCtrl,
                              noteCtrl: _noteCtrl,
                              type: _type,
                              onTypeChanged: (t) =>
                                  setState(() => _type = t),
                              estimatedPrice: _estimatedPrice,
                            ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 12)
                ],
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: CustomButton(
                        label: 'Précédent',
                        variant: ButtonVariant.outline,
                        onPressed: () => setState(() => _step--),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _step < 2
                        ? CustomButton(
                            label: 'Suivant',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _step++);
                              }
                            },
                            suffixIcon: Icons.arrow_forward_rounded,
                          )
                        : CustomButton(
                            label: 'Confirmer l\'envoi',
                            onPressed: _submit,
                            isLoading: _loading,
                            prefixIcon: Icons.send_rounded,
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
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;
  const _StepDot(
      {required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final done = current > index;
    final active = current == index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done || active ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded,
                    size: 16, color: Colors.white)
                : Text('${index + 1}',
                    style: TextStyle(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: active ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

class _Step0 extends StatelessWidget {
  final TextEditingController ctrl;
  const _Step0({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations de l\'expéditeur',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Ces informations seront utilisées comme adresse de ramassage.',
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Adresse d\'enlèvement',
          hint: 'Rue, Quartier, Ville',
          controller: ctrl,
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, 'L\'adresse'),
        ),
      ],
    );
  }
}

class _Step1 extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  const _Step1(
      {required this.nameCtrl,
      required this.phoneCtrl,
      required this.addressCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations du destinataire',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Nom du destinataire',
          hint: 'Nom complet',
          controller: nameCtrl,
          prefixIcon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, 'Le nom'),
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'Téléphone',
          hint: '+229 XX XX XX XX',
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          validator: Validators.phone,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'Adresse de livraison',
          hint: 'Rue, Quartier, Ville',
          controller: addressCtrl,
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, 'L\'adresse'),
        ),
      ],
    );
  }
}

class _Step2 extends StatelessWidget {
  final TextEditingController weightCtrl;
  final TextEditingController dimensionsCtrl;
  final TextEditingController noteCtrl;
  final ParcelType type;
  final void Function(ParcelType) onTypeChanged;
  final double estimatedPrice;

  const _Step2({
    required this.weightCtrl,
    required this.dimensionsCtrl,
    required this.noteCtrl,
    required this.type,
    required this.onTypeChanged,
    required this.estimatedPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations du colis',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Poids (kg)',
          hint: 'Ex: 2.5',
          controller: weightCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.scale_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
          ],
          validator: Validators.positiveNumber,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'Dimensions (optionnel)',
          hint: 'Ex: 30x20x15 cm',
          controller: dimensionsCtrl,
          prefixIcon: Icons.straighten_outlined,
        ),
        const SizedBox(height: 20),
        const Text('Type d\'envoi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          children: ParcelType.values
              .map((t) => Expanded(
                    child: GestureDetector(
                      onTap: () => onTypeChanged(t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: type == t
                              ? AppColors.primaryLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: type == t
                                ? AppColors.primary
                                : AppColors.border,
                            width: type == t ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(_typeIcon(t),
                                color: type == t
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 22),
                            const SizedBox(height: 4),
                            Text(_typeLabel(t),
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: type == t
                                        ? AppColors.primary
                                        : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        if (weightCtrl.text.isNotEmpty && estimatedPrice > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Coût estimé',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text(FormatUtils.formatPrice(estimatedPrice),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'Note (optionnel)',
          hint: 'Instructions particulières...',
          controller: noteCtrl,
          maxLines: 3,
          prefixIcon: Icons.note_outlined,
        ),
      ],
    );
  }

  IconData _typeIcon(ParcelType t) {
    switch (t) {
      case ParcelType.standard: return Icons.inventory_2_outlined;
      case ParcelType.express: return Icons.bolt_rounded;
      case ParcelType.fragile: return Icons.warning_amber_rounded;
    }
  }

  String _typeLabel(ParcelType t) {
    switch (t) {
      case ParcelType.standard: return 'Standard';
      case ParcelType.express: return 'Express';
      case ParcelType.fragile: return 'Fragile';
    }
  }
}