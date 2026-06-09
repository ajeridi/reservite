// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:easy_stars/easy_stars.dart';

void main() {
  runApp(const EasyStarsExampleApp());
}

class EasyStarsExampleApp extends StatelessWidget {
  const EasyStarsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      title: 'Easy Stars Complete Example',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const EasyStarsDemo(),
    );
  }
}

class EasyStarsDemo extends StatefulWidget {
  const EasyStarsDemo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EasyStarsDemoState createState() => _EasyStarsDemoState();
}

class _EasyStarsDemoState extends State<EasyStarsDemo> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Stars - Complete Examples'),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Basic Rating', _buildBasicExamples()),
              _buildSection('Animation Examples', _buildAnimationExamples()),
              _buildSection('Arrangements', _buildArrangementExamples()),
              _buildSection('Custom Shapes & Colors', _buildCustomExamples()),
              _buildSection(
                  'Interactive Features', _buildInteractiveExamples()),
              _buildSection('Advanced Features', _buildAdvancedExamples()),
              _buildSection('Emoji', _buildEmojiExamples()),
              _buildSection('Form Integration', _buildFormExample()),
              _buildSection('Dynamic Theming', _buildThemingExample()),
              _buildSection('Review Bottom Sheet Tests',
                  _buildReviewBottomSheetExamples()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicExamples() {
    return Column(
      children: [
        _buildExample(
          'Basic 5-Star Rating',
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
          'Rating: ${_basicRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Half-Star Rating',
          EasyStarsRating(
            initialRating: _halfRating,
            starCount: 5,
            starSize: 28,
            allowHalfRating: true,
            filledColor: Colors.orange,
            emptyColor: Colors.grey.shade300,
            onRatingChanged: (rating) {
              setState(() {
                _halfRating = rating;
              });
            },
          ),
          'Rating: ${_halfRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Read-Only Display',
          EasyStarsDisplay(
            initialRating: _readOnlyRating,
            starCount: 5,
            starSize: 26,
            readOnly: true,
            showRatingText: true,
            filledColor: Colors.green,
            emptyColor: Colors.grey.shade400,
          ),
          'Fixed rating display',
        ),
      ],
    );
  }

  Widget _buildAnimationExamples() {
    return Column(
      children: [
        _buildExample(
          'Scale Animation',
          EasyStarsRating(
            initialRating: _animatedRating,
            starCount: 5,
            starSize: 32,
            animationConfig: StarAnimationConfig.scale,
            filledColor: Colors.purple,
            onRatingChanged: (rating) {
              setState(() {
                _animatedRating = rating;
              });
            },
          ),
          'Rating: ${_animatedRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Bounce Animation',
          EasyStarsRating(
            initialRating: 3.0,
            starCount: 5,
            starSize: 30,
            animationConfig: StarAnimationConfig.bounce,
            filledColor: Colors.blue,
            onRatingChanged: (rating) {},
          ),
          'Tap to see bounce effect',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Rotation Animation',
          EasyStarsRating(
            initialRating: 4.0,
            starCount: 5,
            starSize: 28,
            animationConfig: StarAnimationConfig.rotate,
            filledColor: Colors.red,
            onRatingChanged: (rating) {},
          ),
          'Stars rotate on interaction',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Pulse Animation',
          EasyStarsRating(
            initialRating: 3.5,
            starCount: 5,
            starSize: 26,
            animationConfig: StarAnimationConfig.pulse,
            filledColor: Colors.pink,
            onRatingChanged: (rating) {},
          ),
          'Continuous pulse effect',
        ),
      ],
    );
  }

  Widget _buildReviewBottomSheetExamples() {
    return Column(
      children: [
        _buildExample(
          'Review Bottom Sheet Tests',
          Column(
            children: [
              // Basic Review Bottom Sheet Button
              ElevatedButton.icon(
                onPressed: () async {
                  final reviewData = await context.showReviewBottomSheet(
                    title: 'Basic Review',
                    subtitle: 'Rate this product',
                    initialRating: 3.0,
                    reviewType: ReviewType.stars,
                    allowModeSwitch: false,
                  );

                  if (reviewData != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Basic Review - Rating: ${reviewData.rating}, Comment: ${reviewData.comment}',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.star),
                label: const Text('Basic Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 12),

              // Advanced Review Bottom Sheet Button
              ElevatedButton.icon(
                onPressed: () async {
                  final reviewData = await EasyStarsReviewBottomSheet.show(
                    context: context,
                    title: 'Advanced Review',
                    subtitle: 'Tell us about your detailed experience',
                    initialRating: 0.0,
                    reviewType: ReviewType.stars,
                    allowModeSwitch: true,
                    allowHalfRating: true,
                    isCommentRequired: true,
                    minCharacters: 10,
                    maxCharacters: 300,
                    showRatingLabels: true,
                    animationConfig: StarAnimationConfig.bounce,
                    filledColor: Colors.orange,
                    emptyColor: Colors.grey.shade300,
                    starCount: 5,
                    ratingSize: 36.0,
                    customRatingLabels: [
                      'Terrible',
                      'Poor',
                      'Okay',
                      'Good',
                      'Amazing'
                    ],
                    hintText: 'Please share your detailed feedback...',
                    headerWidgets: [
                      Card(
                        color: Colors.orange.shade50,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.shopping_bag, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Product: Easy Stars Package',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    footerWidgets: [
                      CheckboxListTile(
                        title: const Text('Recommend to others'),
                        subtitle:
                        const Text('Would you recommend this to friends?'),
                        value: true,
                        onChanged: (value) {},
                        dense: true,
                      ),
                    ],
                  );

                  if (reviewData != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Advanced Review Submitted:'),
                            Text('Rating: ${reviewData.rating}/5'),
                            Text('Type: ${reviewData.reviewType.name}'),
                            if (reviewData.comment.isNotEmpty)
                              Text('Comment: ${reviewData.comment}'),
                          ],
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('Advanced Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 12),

              // Emoji Review Bottom Sheet Button
              ElevatedButton.icon(
                onPressed: () async {
                  final reviewData = await EasyStarsReviewBottomSheet.show(
                    context: context,
                    title: 'Emoji Review',
                    subtitle: 'How do you feel about this?',
                    initialRating: 4.0,
                    reviewType: ReviewType.emoji,
                    allowModeSwitch: true,
                    allowHalfRating: false,
                    isCommentRequired: false,
                    maxCharacters: 200,
                    showRatingLabels: true,
                    animationConfig: StarAnimationConfig.scale,
                    ratingSize: 40.0,
                    customEmojis: ['😭', '😢', '😐', '😊', '🤩'],
                    customRatingLabels: [
                      'Awful',
                      'Sad',
                      'Neutral',
                      'Happy',
                      'Ecstatic'
                    ],
                    hintText: 'Share your feelings about this experience...',
                    submitButtonText: 'Share Feeling',
                    headerWidgets: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.shade100,
                              Colors.purple.shade100
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_emotions,
                                color: Colors.purple),
                            const SizedBox(width: 8),
                            Text(
                              'Express yourself with emojis!',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (reviewData != null) {
                    String emojiMap = '';
                    switch (reviewData.rating.toInt()) {
                      case 1:
                        emojiMap = '😭';
                        break;
                      case 2:
                        emojiMap = '😢';
                        break;
                      case 3:
                        emojiMap = '😐';
                        break;
                      case 4:
                        emojiMap = '😊';
                        break;
                      case 5:
                        emojiMap = '🤩';
                        break;
                      default:
                        emojiMap = '😐';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Text(emojiMap,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Emoji Review: ${reviewData.rating}/5'),
                                  if (reviewData.comment.isNotEmpty)
                                    Text('Feeling: ${reviewData.comment}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.purple.shade400,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.emoji_emotions),
                label: const Text('Emoji Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
          'Test different review bottom sheet configurations',
        ),
      ],
    );
  }

  Widget _buildArrangementExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arrangement Examples',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildExample(
          'Circular Arrangement',
          EasyStarsRating(
            initialRating: _circularRating,
            starCount: 12,
            starSize: 24,
            arrangement: StarArrangement.arc,
            arrangementRadius: 60,
            filledColor: Colors.teal,
            onRatingChanged: (rating) {
              setState(() {
                _circularRating = rating;
              });
            },
          ),
          'Rating: ${_circularRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Grid Arrangement',
          EasyStarsRating(
            initialRating: _gridRating,
            starCount: 6,
            starSize: 28,
            arrangement: StarArrangement.grid,
            gridColumns: 3,
            spacing: 8,
            filledColor: Colors.indigo,
            onRatingChanged: (rating) {
              setState(() {
                _gridRating = rating;
              });
            },
          ),
          'Rating: ${_gridRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Wave Arrangement',
          EasyStarsRating(
            initialRating: _waveRating,
            starCount: 10,
            starSize: 26,
            arrangement: StarArrangement.wave,
            waveAmplitude: 15,
            filledColor: Colors.cyan,
            onRatingChanged: (rating) {
              setState(() {
                _waveRating = rating;
              });
            },
          ),
          'Rating: ${_waveRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Spiral Arrangement',
          EasyStarsRating(
            initialRating: _spiralRating,
            starCount: 8,
            starSize: 22,
            arrangement: StarArrangement.spiral,
            arrangementRadius: 50,
            filledColor: Colors.deepOrange,
            onRatingChanged: (rating) {
              setState(() {
                _spiralRating = rating;
              });
            },
          ),
          'Rating: ${_spiralRating.toStringAsFixed(1)}',
        ),
      ],
    );
  }

  Widget _buildEmojiExamples() {
    return Column(
      children: [
        _buildExample(
          'Emoji Rating',
          EasyStarsEmoji(
            initialRating: 4.5,
            onRatingChanged: (rating) {},
          ),
          'Use emojis as stars',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Emoji Rating with custom icons',
          EasyStarsEmojiSlider(
            initialRating: 4.5,
            onRatingChanged: (rating) {},
          ),
          'Use custom icons',
        ),
      ],
    );
  }

  Widget _buildCustomExamples() {
    return Column(
      children: [
        _buildExample(
          'Heart Shape',
          EasyStarsRating(
            initialRating: 4.0,
            starCount: 5,
            starSize: 32,
            starShape: StarShape.heart,
            filledColor: Colors.red,
            emptyColor: Colors.pink.shade100,
            onRatingChanged: (rating) {},
          ),
          'Heart-shaped rating',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Gradient Colors',
          EasyStarsRating(
            initialRating: _gradientRating,
            starCount: 5,
            starSize: 30,
            gradientColors: const [Colors.yellow, Colors.orange, Colors.red],
            onRatingChanged: (rating) {
              setState(() {
                _gradientRating = rating;
              });
            },
          ),
          'Rating: ${_gradientRating.toStringAsFixed(1)}',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Custom Icons',
          EasyStarsRating(
            initialRating: _multiShapeRating,
            starCount: 5,
            starSize: 28,
            customIcons: const [
              Icons.favorite,
              Icons.star,
              Icons.thumb_up,
              Icons.mood,
              Icons.emoji_events,
            ],
            customColors: const [
              Colors.red,
              Colors.amber,
              Colors.blue,
              Colors.green,
              Colors.purple,
            ],
            onRatingChanged: (rating) {
              setState(() {
                _multiShapeRating = rating;
              });
            },
          ),
          'Rating: ${_multiShapeRating.toStringAsFixed(1)}',
        ),
      ],
    );
  }

  Widget _buildInteractiveExamples() {
    return Column(
      children: [
        _buildExample(
          'Drag Interaction',
          EasyStarsRating(
            initialRating: _dragRating,
            starCount: 5,
            starSize: 32,
            dragSensitivity: DragSensitivity.high,
            animationConfig: StarAnimationConfig.scale,
            filledColor: Colors.deepPurple,
            onRatingChanged: (rating) {
              setState(() {
                _dragRating = rating;
              });
            },
          ),
          'Rating: ${_dragRating.toStringAsFixed(1)} - Drag to rate',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Clearable Rating',
          EasyStarsRating(
            initialRating: 3.0,
            starCount: 5,
            starSize: 30,
            allowClear: true,
            filledColor: Colors.brown,
            onRatingChanged: (rating) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Rating: ${rating.toStringAsFixed(1)}')),
              );
            },
          ),
          'Tap same star to clear',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Vertical Layout',
          EasyStarsRating(
            initialRating: 4.0,
            starCount: 5,
            starSize: 28,
            direction: StarDirection.vertical,
            spacing: 8,
            filledColor: Colors.lime,
            onRatingChanged: (rating) {},
          ),
          'Vertical arrangement',
        ),
      ],
    );
  }

  Widget _buildAdvancedExamples() {
    return Column(
      children: [
        _buildExample(
          'Size Variants',
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  EasyStarsRating(
                    initialRating: 3.0,
                    starCount: 3,
                    sizeVariant: StarSizeVariant.small,
                    filledColor: Colors.blue,
                    onRatingChanged: (rating) {},
                  ),
                  const SizedBox(height: 4),
                  const Text('Small', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  EasyStarsRating(
                    initialRating: 3.0,
                    starCount: 3,
                    sizeVariant: StarSizeVariant.medium,
                    filledColor: Colors.green,
                    onRatingChanged: (rating) {},
                  ),
                  const SizedBox(height: 4),
                  const Text('Medium', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  EasyStarsRating(
                    initialRating: 3.0,
                    starCount: 3,
                    sizeVariant: StarSizeVariant.large,
                    filledColor: Colors.red,
                    onRatingChanged: (rating) {},
                  ),
                  const SizedBox(height: 4),
                  const Text('Large', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          'Different size variants',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'With Shadow',
          EasyStarsRating(
            initialRating: 4.0,
            starCount: 5,
            starSize: 32,
            starShadow: const BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
            filledColor: Colors.amber,
            onRatingChanged: (rating) {},
          ),
          'Stars with shadow effect',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Rotated Arrangement',
          EasyStarsRating(
            initialRating: 3.5,
            starCount: 5,
            starSize: 28,
            arrangementRotation: 0.2,
            filledColor: Colors.purple,
            onRatingChanged: (rating) {},
          ),
          'Rotated star arrangement',
        ),
        const SizedBox(height: 20),
        _buildExample(
          'Arc Arrangement',
          EasyStarsRating(
            initialRating: 4.0,
            starCount: 7,
            starSize: 26,
            arrangement: StarArrangement.arc,
            arrangementRadius: 80,
            filledColor: Colors.orange,
            onRatingChanged: (rating) {},
          ),
          'Arc-shaped arrangement',
        ),
      ],
    );
  }

  Widget _buildFormExample() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          FormField<double>(
            initialValue: _formRating,
            validator: (value) {
              if (value == 0) {
                return 'Please provide a rating';
              }
              return null;
            },
            onSaved: (value) {
              _formRating = value ?? 0;
            },
            builder: (FormFieldState<double> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EasyStarsRating(
                    initialRating: state.value ?? 0,
                    onRatingChanged: (rating) {
                      state.didChange(rating);
                    },
                    starCount: 5,
                    starSize: 30,
                    filledColor: Colors.blue,
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                      Text('Form submitted with rating: $_formRating')),
                );
              }
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemingExample() {
    return Column(
      children: [
        _buildExample(
          'Switch Themes',
          EasyStarsRating(
            animationConfig: StarAnimationConfig.pulse,
            initialRating: _themedRating,
            onRatingChanged: (rating) {
              setState(() {
                _themedRating = rating;
              });
            },
            allowHalfRating: true,
            starCount: 5,
            filledColor: _currentTheme.filledColor ?? Colors.amber,
            emptyColor: _currentTheme.emptyColor ?? Colors.grey,
            starSize: _currentTheme.starSize ?? 30.0,
            spacing: _currentTheme.spacing ?? 2.0,
            gradientColors: _currentTheme.gradientColors,
            starShadow: _currentTheme.starShadow,
            starShape: _currentTheme.starShape ?? StarShape.star,
          ),
          'Current theme: ${_getThemeName()}',
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentTheme = StarThemes.goldTheme();
                });
              },
              child: const Text('Gold'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentTheme = StarThemes.darkTheme();
                });
              },
              child: const Text('Dark'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentTheme = StarThemes.heartTheme();
                });
              },
              child: const Text('Heart'),
            ),
          ],
        ),
      ],
    );
  }

  String _getThemeName() {
    if (_currentTheme.filledColor == StarThemes.goldTheme().filledColor) {
      return 'Gold';
    }
    if (_currentTheme.filledColor == StarThemes.darkTheme().filledColor) {
      return 'Dark';
    }
    if (_currentTheme.filledColor == StarThemes.heartTheme().filledColor) {
      return 'Heart';
    }
    return 'Unknown';
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom star builder example
class CustomStarBuilder {
  static Widget buildCustomStar(int index, bool isFilled, bool isHalf) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? Colors.amber : Colors.grey.shade300,
        border: Border.all(
          color: Colors.amber.shade700,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isFilled ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// Extension for additional functionality
extension EasyStarsExtension on EasyStarsRating {
  EasyStarsRating withCustomAnimation(StarAnimationConfig config) {
    return EasyStarsRating(
      initialRating: initialRating,
      starCount: starCount,
      starSize: starSize,
      animationConfig: config,
      filledColor: filledColor,
      emptyColor: emptyColor,
      onRatingChanged: onRatingChanged,
    );
  }
}

// Example of custom animation configurations
class CustomAnimations {
  static const StarAnimationConfig bouncyScale = StarAnimationConfig(
    animationType: StarAnimation.scale,
    duration: Duration(milliseconds: 400),
    curve: Curves.bounceOut,
    scaleFactor: 1.4,
    staggerDelay: Duration(milliseconds: 100),
  );

  static const StarAnimationConfig smoothFade = StarAnimationConfig(
    animationType: StarAnimation.fade,
    duration: Duration(milliseconds: 600),
    curve: Curves.easeInOutCubic,
    fadeOpacity: 0.2,
    animateColor: true,
    colorDuration: Duration(milliseconds: 300),
  );

  static const StarAnimationConfig elasticRotation = StarAnimationConfig(
    animationType: StarAnimation.rotate,
    duration: Duration(milliseconds: 800),
    curve: Curves.elasticOut,
    rotationAngle: 0.5,
    useSpringAnimation: true,
    springStiffness: 80.0,
    springDamping: 6.0,
  );
}

class StarConfig {
  final Color? filledColor;
  final Color? emptyColor;
  final double? starSize;
  final double? spacing;
  final List<Color>? gradientColors;
  final BoxShadow? starShadow;
  final Color? borderColor;
  final double? borderWidth;
  final StarShape? starShape;
  final StarArrangement? arrangement;
  final double? arrangementRadius;

  StarConfig({
    this.filledColor,
    this.emptyColor,
    this.starSize,
    this.spacing,
    this.gradientColors,
    this.starShadow,
    this.borderColor,
    this.borderWidth,
    this.starShape,
    this.arrangement,
    this.arrangementRadius,
  });
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

  static StarConfig darkTheme() {
    return StarConfig(
      filledColor: Colors.white,
      emptyColor: Colors.grey.shade700,
      starSize: 26,
      spacing: 8,
      borderColor: Colors.grey.shade400,
      borderWidth: 1,
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