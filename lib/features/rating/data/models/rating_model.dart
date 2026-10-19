class RatingSummary {
  const RatingSummary({required this.average, required this.count});

  final double average;
  final int count;
}

class RatingReview {
  const RatingReview({
    required this.name,
    required this.avatarUrl,
    required this.stars,
    this.comment,
  });

  final String name;
  final String avatarUrl;
  final int stars;
  final String? comment;
}
