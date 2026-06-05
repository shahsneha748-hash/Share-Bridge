List<Map<String, dynamic>> sharedItems = [
  {
    'title': 'Grocery Essentials Bundle',
    'image': 'assets/images/GroceryBag.png',
    'available': true,
    'category': 'Food',
    'subcategory': 'FOOD & PANTRY',
    'location': 'Imadol-5, Green Community Hub, Kathmandu',
    'shortLocation': 'Imadol-5',
    'distance': '0.4 miles',
    'expires': '2d',
    'description':
    'A nutritious variety of fresh items and pantry essentials. Includes organic spinach, seasonal apples, a loaf of fresh sourdough bread, and assorted dry pantry staples.',
    'portion': '2-3 people',
    'weight': 'Approx. 3kg',
    'condition': 'Fresh',
    'tag': 'Organic Produce',
    'note': 'All items are fresh and unopened.',
    'donorName': 'Ram Sah',
    'donorRating': '4.8',
    'donorDonations': '120',
    'mapLat': 27.6588,
    'mapLng': 85.3247,
  },
  {
    'title': 'Cooked Meal',
    'image': 'assets/images/CookedMeal.jpeg',
    'available': true,
    'category': 'Food',
    'subcategory': 'HOME COOKED',
    'location': 'Lalitpur-3, Patan Dhoka, Lalitpur',
    'shortLocation': 'Lalitpur-3',
    'distance': '1.1 miles',
    'expires': '6h',
    'description':
    'Freshly prepared home-cooked meal — dal bhat with vegetables and pickle. Made today, ready for pickup.',
    'portion': '3-4 people',
    'weight': 'Approx. 2kg',
    'condition': 'Hot & Fresh',
    'tag': 'Home Cooked',
    'note': 'Best consumed within 6 hours.',
    'donorName': 'Sita Karki',
    'donorRating': '4.9',
    'donorDonations': '15',
    'mapLat': 27.6766,
    'mapLng': 85.3250,
  },
  {
    'title': 'T-shirts',
    'image': 'assets/images/T-shirts.jpeg',
    'available': false,
    'category': 'Clothes',
    'subcategory': 'CASUAL WEAR',
    'location': 'Kathmandu-7, New Baneshwor, Kathmandu',
    'shortLocation': 'Kathmandu-7',
    'distance': '2.3 miles',
    'description':
    'Gently used t-shirts in good condition. Various sizes and colors. Washed and folded, ready to wear.',
    'portion': '5 pieces',
    'condition': 'Gently Used',
    'tag': 'Mixed Sizes',
    'donorName': 'Amit Shrestha',
    'donorRating': '4.5',
    'donorDonations': '8',
    'mapLat': 27.6915,
    'mapLng': 85.3420,
  },
  {
    'title': 'Cardigan',
    'image': 'assets/images/Cardigan.jpeg',
    'available': true,
    'category': 'Clothes',
    'subcategory': 'WINTER WEAR',
    'location': 'Bhaktapur-4, Durbar Square, Bhaktapur',
    'shortLocation': 'Bhaktapur-4',
    'distance': '3.8 miles',
    'description':
    'Warm woolen cardigan, lightly used. Perfect for the winter season. Size M.',
    'portion': '1 piece',
    'condition': 'Like New',
    'tag': 'Size M',
    'donorName': 'Maya Tamang',
    'donorRating': '4.7',
    'donorDonations': '12',
    'mapLat': 27.6710,
    'mapLng': 85.4298,
  },
  {
    'title': 'Jeans',
    'image': 'assets/images/Jeans.jpeg',
    'available': true,
    'category': 'Clothes',
    'subcategory': 'CASUAL WEAR',
    'location': 'Patan-2, Pulchowk, Lalitpur',
    'shortLocation': 'Patan-2',
    'distance': '1.5 miles',
    'description':
    'Two pairs of denim jeans in good condition. Size 32. Washed and ready.',
    'portion': '2 pieces',
    'condition': 'Good',
    'tag': 'Size 32',
    'donorName': 'Bikash Rai',
    'donorRating': '4.6',
    'donorDonations': '5',
    'mapLat': 27.6790,
    'mapLng': 85.3180,
  },
];

// Community-wide stats
class CommunityStats {
  static int weeklyGoal = 200;
  static int itemsShared = 128;
  static double get progress => itemsShared / weeklyGoal;
}

// Favorites — global in-memory set of titles the user has favorited.
// Later, swap this for shared_preferences/Firebase.
class Favorites {
  static final Set<String> _saved = {};

  static bool isFavorite(String title) => _saved.contains(title);

  static void toggle(String title) {
    if (_saved.contains(title)) {
      _saved.remove(title);
    } else {
      _saved.add(title);
    }
  }
}