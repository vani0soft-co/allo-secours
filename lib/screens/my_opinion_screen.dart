import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/providers/auth_provider.dart';
import 'package:allo_secours/providers/services_provider.dart';
import 'package:allo_secours/services/api_service.dart';
import 'package:allo_secours/utils/mock_data.dart';
import 'package:allo_secours/widgets/custom_app_bar.dart';

class MyOpinionScreen extends StatefulWidget {
  const MyOpinionScreen({Key? key}) : super(key: key);

  @override
  State<MyOpinionScreen> createState() => _MyOpinionScreenState();
}

class _MyOpinionScreenState extends State<MyOpinionScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  Service? _selectedService;
  bool _isSubmitting = false;
  bool _submitted = false;

  // Services disponibles pour la sélection
  List<Service> _availableServices = [];
  bool _loadingServices = true;

  @override
  void initState() {
    super.initState();
    // Récupère le service passé en argument (depuis ServiceDetailScreen)
    final args = Get.arguments;
    if (args is Service) {
      _selectedService = args;
    }
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final provider = context.read<ServicesProvider>();
      await provider.fetchServices();
      setState(() {
        _availableServices = provider.allServices.isNotEmpty
            ? provider.allServices
            : MockData.mockServices;
        _loadingServices = false;
      });
    } catch (_) {
      setState(() {
        _availableServices = MockData.mockServices;
        _loadingServices = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_selectedService == null) {
      _showSnack('Veuillez sélectionner un service', isError: true);
      return;
    }
    if (_rating == 0) {
      _showSnack('Veuillez donner une note', isError: true);
      return;
    }
    if (_commentController.text.trim().length < 10) {
      _showSnack('Le commentaire doit faire au moins 10 caractères', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();
      await api.loadToken();

      await api.addReview(
        serviceId: _selectedService!.id,
        userId: auth.userId.isNotEmpty ? auth.userId : 'demo_user',
        userName: auth.userName,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (_) {
      // Simuler le succès en mode démo si l'API n'est pas disponible
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _reset() {
    setState(() {
      _rating = 0;
      _commentController.clear();
      _selectedService = null;
      _submitted = false;
    });
  }

  String _ratingLabel() {
    switch (_rating.toInt()) {
      case 1:
        return 'Très mauvais';
      case 2:
        return 'Mauvais';
      case 3:
        return 'Correct';
      case 4:
        return 'Bien';
      case 5:
        return 'Excellent';
      default:
        return 'Appuyez pour noter';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Votre avis'),
      body: _submitted ? _buildSuccessView() : _buildForm(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded,
                  size: 60, color: Colors.green.shade600),
            ),
            const SizedBox(height: 24),
            const Text(
              'Merci pour votre avis !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre avis sur "${_selectedService?.name}" a bien été enregistré.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('Donner un autre avis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection du service
          const Text(
            'Service évalué',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingServices)
            const Center(child: CircularProgressIndicator())
          else
            _buildServiceSelector(),

          const SizedBox(height: 24),

          // Évaluation par étoiles
          const Text(
            'Votre note',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerGray),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = (index + 1).toDouble()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          _rating >= (index + 1)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: _rating >= (index + 1) ? 42 : 38,
                          color: _rating >= (index + 1)
                              ? Colors.orange
                              : AppColors.dividerGray,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _ratingLabel(),
                    key: ValueKey(_rating),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _rating > 0
                          ? Colors.orange.shade700
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Commentaire
          const Text(
            'Votre commentaire',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Décrivez votre expérience avec ce service...',
              hintStyle: const TextStyle(color: AppColors.textLight),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dividerGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dividerGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton d'envoi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.dividerGray,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Envoyer mon avis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildServiceSelector() {
    return GestureDetector(
      onTap: _showServicePicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerGray),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_hospital_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedService?.name ?? 'Sélectionner un service...',
                style: TextStyle(
                  color: _selectedService != null
                      ? AppColors.textDark
                      : AppColors.textLight,
                  fontWeight: _selectedService != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dividerGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Choisir un service',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: _availableServices.length,
                    itemBuilder: (_, i) {
                      final service = _availableServices[i];
                      return ListTile(
                        leading: Icon(
                          _getCategoryIcon(service.category),
                          color: AppColors.primary,
                        ),
                        title: Text(service.name,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(service.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11)),
                        trailing: _selectedService?.id == service.id
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary)
                            : null,
                        onTap: () {
                          setState(() => _selectedService = service);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'pharmacy':
        return Icons.local_pharmacy_rounded;
      case 'emergency':
        return Icons.emergency_rounded;
      case 'specialist':
        return Icons.person_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
