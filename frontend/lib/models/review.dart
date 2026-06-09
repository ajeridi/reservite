import 'dart:convert';

import 'package:intl/intl.dart';

import '../core/services/api_client.dart';

class Review {
  final int id;
  final int client;
  final int restaurant;
  final int reservation;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.reservation,
    required this.rating,
    this.comment = null,
    required this.createdAt
  });


  factory Review.fromJson(Map<String, dynamic> reviewJson){
    return Review(
      id: reviewJson['id'],
      client: reviewJson['client'],
      restaurant: reviewJson['restaurant'],
      reservation: reviewJson['reservation'],
      rating: reviewJson['rating'],
      comment: reviewJson['comment'],
      createdAt: DateTime.parse(reviewJson['created_at']),
    );
  }

  @override
  String toString() {
    return 'Review: {id: $id, client: $client, restaurant: $restaurant, reservation: $reservation, rating: $rating, comment: $comment, createdAt: $createdAt';
  }

  static String? validateComment(String newComment) {
    final toCheck = newComment.trim();
    if (toCheck.length < 10) return 'Votre commentaire doit avoir une longueur de 10 characteres.';
    return null;
  }

  static Future<Review> save({required reviewId, required int clientId, required int restaurantId, required int reservationId, required int newRating, required String? newComment, required DateTime updateDate}) async {

    try {
      final response = await ApiClient.post(
          'save_review',
          body: json.encode({
            'review_id': reviewId,
            'client_id': clientId,
            'restaurant_id': restaurantId,
            'reservation_id': reservationId,
            'new_rating': newRating,
            'new_comment': newComment,
            'update_date': DateFormat("yyyy-MM-dd HH:mm:ss").format(updateDate)
          })
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return Review.fromJson(body);
      }
      else {
        throw Exception(
            'Something went wrong when saving the review.\nResponseBody: ${response
                .body}');
      }
    }catch(e, st){
      print('$e\n$st');
      throw Exception();
    }
  }
}