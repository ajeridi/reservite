import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/services/api_client.dart';

class Review {
  final int id;
  final int client;
  final int restaurant;
  final int reservation;
  final int rating;
  final String comment;
  final DateTime created_at;

  //constructeur
  const Review({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.reservation,
    required this.rating,
    required this.comment,
    required this.created_at
  });

  // constructeur from Json
  factory Review.fromJson(Map<String, dynamic> reviewJson){
    return Review(
      id: reviewJson['id'],
      client: reviewJson['client'],
      restaurant: reviewJson['restaurant'],
      reservation: reviewJson['reservation'],
      rating: reviewJson['rating'],
      comment: reviewJson['comment'],
      created_at: DateTime.parse(reviewJson['created_at']),
    );
  }

  // prends une collection Json review et retourne un SET de tables
  static List<Review> reviewsFromJson(List<dynamic>? json) {
    List<Review> reviews = []; // infos, https://dart.dev/language/collections#sets
    if (json == null)
      return reviews;
    for (Map<String, dynamic> reviewJson in json) {
      Review review = Review.fromJson(reviewJson);
      reviews.add(review);
    }
    return reviews;
  }

  static Future<Review?> getReview({int? selectedReservation = null}) async {
    try {
      final response = await ApiClient.get("get_review?reservation_id=$selectedReservation");
      print("voici le body:");
      print(response.body);
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        print("je suis dans le if du modele");
        return Review.fromJson(body);
      }
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get review.');
    }

  }

  static Future<bool?> deja_review({required int idclient, required int reservationId}) async {
    try {
      final response = await ApiClient.get("deja_review?idclient=$idclient&reservationid=$reservationId");

      if (response.statusCode == 200){
        return json.decode(response.body) as bool;
      }

    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get deja_review');
    }

  }

  static String? validateDescription(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'Veuillez entrer une description à votre avis';
    }
    if (name.length < 3) {
      return 'La description doit contenir au moins 3 caractères';
    }
    return null;
  }

  static Future<Review> publier_avis({required int restaurantId, required int reservationId, required int ratingg, required String commentt, required DateTime date, required int? reviews_id}) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final reviewDateTime = DateTime(
        date.year,
        date.month,
        date.day,
      );
      final datetimeString =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(reviewDateTime);

      final response = await ApiClient.post(
        'publier_avis',
        body: json.encode({
          'restaurantid': restaurantId,
          'reservationid': reservationId,
          'ratingg': ratingg,
          'commentt': commentt,
          'datetime_': datetimeString,
          'reviews_id' : reviews_id,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return Review.fromJson(body);
      }
      throw Exception(
        'Failed to save review. Status code: ${response.statusCode}\nBody: ${response.body}',
      );
    } catch (e, st) {
      print('$e\n$st');
      throw Exception('Failed to save review.');
    }
  }

}