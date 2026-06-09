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
    return Review(id: reviewJson['id'],
        client: reviewJson['client'],
        restaurant: reviewJson['restaurant'],
        reservation: reviewJson['reservation'],
        rating: reviewJson['rating'],
        comment: reviewJson['comment'],
        createdAt: DateTime.parse(reviewJson['created_at']));
  }

  @override
  String toString() {
    return 'Review: {id : $id, client : $client, restaurant : $restaurant, '
        'reservation : $reservation, rating : $rating,'
        'comment : $comment, createdAt : $createdAt}';
  }

  static String? validateComment(String newComm){
    final toCheck = newComm.trim();
    if(toCheck.length < 10)
      return "Votre commentaire doit avoir une longueur de minimun 10 caracteres";
    return null;
  }


}