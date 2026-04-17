import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class AdminAddCarScreen extends ConsumerStatefulWidget {
  final String? carId;

  const AdminAddCarScreen({super.key, this.carId});

  @override
  ConsumerState<AdminAddCarScreen> createState() => _AdminAddCarScreenState();
}

class _AdminAddCarScreenState extends ConsumerState<AdminAddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _licensePlateCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _licensePlateCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // TODO: Implement save logic
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sauvegarde')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carId == null ? 'Ajouter une voiture' : 'Modifier la voiture'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _brandCtrl,
                label: 'Marque',
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingM),
              CustomTextField(
                controller: _modelCtrl,
                label: 'Modèle',
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingM),
              CustomTextField(
                controller: _yearCtrl,
                label: 'Année',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingM),
              CustomTextField(
                controller: _licensePlateCtrl,
                label: 'Plaque d\'immatriculation',
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingM),
              CustomTextField(
                controller: _capacityCtrl,
                label: 'Capacité',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              SizedBox(height: AppDimensions.paddingXL),
              CustomButton(
                label: 'Sauvegarder',
                onPressed: _save,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}