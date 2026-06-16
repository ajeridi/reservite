import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reviews_provider.dart';
import 'package:prbd_2526_a07/providers/selectedStarProvider.dart';

import '../../core/tools/validating_text_editing_controller.dart';
import '../../models/review.dart';
import '../pages/avis_provider.dart';

class StarSelectionWidget extends ConsumerStatefulWidget {
  const StarSelectionWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StarSelectionWidget createState() => _StarSelectionWidget();
}

class _StarSelectionWidget extends ConsumerState<StarSelectionWidget> {
  late final ValidatingTextEditingController _specialRequestsController =
  ValidatingTextEditingController(
      initialValue: getInitialAvis(),
      validator: Review.validateDescription,
      onAfterValidated: () => setState(() {})
  );



  double _basicRating = 3.0;
  double _halfRating = 2.5;
  double _animatedRating = 4.0;
  final double _readOnlyRating = 4.2;
  double _circularRating = 3.0;
  double _gridRating = 2.8;
  double _waveRating = 3.7;
  double _spiralRating = 4.1;
  double _gradientRating = 3.3;
  double _dragRating = 2.9;
  double _multiShapeRating = 3.6;
  final _formKey = GlobalKey<FormState>();
  double _formRating = 3.0;
  StarConfig _currentTheme = StarThemes.heartTheme();
  double _themedRating = 4.0;

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedStarProvider);
    final notifier = ref.read(selectedStarProvider.notifier);

    final selectedReservation = ref.read(selectedReservationIdProvider);

    return _buildExample(
      'Votre Avis ',
      EasyStarsRating(
        // allowPreciseRating: true,
        // rtl: true,
        initialRating: selected,
        starCount: 5,
        starSize: 30,
        onRatingChanged: (rating) {
          setState(() {
            _basicRating = rating;
            notifier.setState(rating);
          });
        },
      ),
      'Note: ${notifier.getState()}',
    );
  }

  Widget _buildExample(String title, Widget widget, String description) {
    final selectedReservation = ref.read(selectedReservationIdProvider);
    final currentReservationNotifier = ref.watch(currentReservationProvider(selectedReservation).notifier);

    final currentReservation = ref.watch(currentReservationProvider(selectedReservation));

    final restaurantId = currentReservation.value!.restaurant!.id;
    final reservationId = currentReservation.value!.id;

    final notifier = ref.read(selectedStarProvider.notifier);
    final note = notifier.getState();
    final AvisState = ref.watch(avisProvider);
    final simulatedTime = ref.watch(applicationTimeProvider).value!;
    final reviews_id = ref.read(reviewsProvider).value?.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: widget),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _specialRequestsController,
            maxLines: 3,
            decoration: InputDecoration(
              errorText: _specialRequestsController.errorText,
              labelText: 'Commentaire (optionnel)',
              border: OutlineInputBorder(),
              hintText: 'Très bonne expérience, je reviendrai !',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await currentReservationNotifier.publier_avis(
                  restaurantId: restaurantId,
                  reservationId: reservationId,
                  ratingg: note.toInt(),
                  commentt: _specialRequestsController.text.trim(),
                  date: simulatedTime,
                  reviews_id: reviews_id,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avis publié !')),
                  );
                }
              } catch (e) {
                print(e);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Publier mon avis'),
          ),
        ],
      ),
    );
  }

  String getInitialAvis() {
    final avisText = ref.watch(avisProvider);
    return avisText.whenData((avis) => avis).value!;
  }
}

// Helper class for creating themed star configurations
class StarThemes {
  static StarConfig goldTheme() {
    return StarConfig(
      filledColor: Colors.amber,
      emptyColor: Colors.grey.shade300,
      starSize: 28,
      spacing: 6,
      gradientColors: [Colors.yellow, Colors.orange],
      starShadow: BoxShadow(
        color: Colors.amber.withAlpha(75),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    );
  }

  static StarConfig heartTheme() {
    return StarConfig(
      filledColor: Colors.red,
      emptyColor: Colors.pink.shade100,
      starSize: 30,
      spacing: 4,
      starShape: StarShape.heart,
      arrangement: StarArrangement.arc,
      arrangementRadius: 60,
    );
  }
}