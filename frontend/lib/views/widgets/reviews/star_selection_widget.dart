import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarSelectionWidget extends StatefulWidget {
  const StarSelectionWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StarSelectionWidget createState() => _StarSelectionWidget();
}

class _StarSelectionWidget extends State<StarSelectionWidget> {
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
    return _buildExample(
      'Votre Avis ',
      EasyStarsRating(
        // allowPreciseRating: true,
        // rtl: true,
        initialRating: _basicRating,
        starCount: 5,
        starSize: 30,
        onRatingChanged: (rating) {
          setState(() {
            _basicRating = rating;
          });
        },
      ),
      'Note: ${_basicRating.toStringAsFixed(1)}',
    );
  }

  Widget _buildExample(String title, Widget widget, String description) {
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
        ],
      ),
    );
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
