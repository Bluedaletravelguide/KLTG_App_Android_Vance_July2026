// lib/data/travel_playbook.dart
//
// Static Q&A content (patterns/answer/quick-replies) lives in the backend
// `travel_buddy_qa` table via the `appTravelBuddyQA` action — see
// fetchRawList() in lib/services/api_service.dart. Only the 5 entries below
// stay hardcoded, since they run query-parsing logic (dynamicAnswer) rather
// than just returning stored text.

class QueryAnalyzer {
  // Extract number from query (e.g., "top 10" -> 10)
  static int? extractNumber(String query) {
    final numbers = {
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      '1': 1,
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      '15': 15,
      '20': 20
    };

    for (var entry in numbers.entries) {
      if (query.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  // Extract location from query
  static String extractLocation(String query) {
    final q = query.toLowerCase();
    if (q.contains('klcc') || q.contains('twin tower')) return 'klcc';
    if (q.contains('bukit bintang') || q.contains('bb')) return 'bukit_bintang';
    if (q.contains('chinatown') || q.contains('petaling')) return 'chinatown';
    if (q.contains('bangsar')) return 'bangsar';
    if (q.contains('penang')) return 'penang';
    if (q.contains('melaka') || q.contains('malacca')) return 'melaka';
    if (q.contains('langkawi')) return 'langkawi';
    return 'general';
  }

  // Extract time preference
  static String extractTime(String query) {
    final q = query.toLowerCase();
    if (q.contains('morning') || q.contains('breakfast')) return 'morning';
    if (q.contains('lunch') || q.contains('afternoon')) return 'afternoon';
    if (q.contains('dinner') || q.contains('evening')) return 'evening';
    if (q.contains('night') || q.contains('tonight')) return 'night';
    return 'anytime';
  }

  // Extract budget (in RM)
  static int? extractBudget(String query) {
    final q = query.toLowerCase();
    if (q.contains('cheap') || q.contains('budget')) return 50;
    if (q.contains('under 50') || q.contains('below 50')) return 50;
    if (q.contains('under 100') || q.contains('below 100')) return 100;
    if (q.contains('under 200')) return 200;
    if (q.contains('expensive') || q.contains('luxury')) return 999;
    return null;
  }

  // Check if asking for list
  static bool isListRequest(String query) {
    final q = query.toLowerCase();
    return q.contains('list') ||
        q.contains('top ') ||
        extractNumber(query) != null;
  }
}

// ============================================
// ENHANCED QA CLASS
// ============================================

class QA {
  final List<String> patterns;
  final String? staticAnswer;
  final String Function(String query)? dynamicAnswer;
  final List<String> quick;
  final String answerType; // 'static', 'dynamic', 'list'

  const QA({
    required this.patterns,
    this.staticAnswer,
    this.dynamicAnswer,
    this.quick = const [],
    this.answerType = 'static',
  });

  String getAnswer(String query) {
    if (answerType == 'dynamic' && dynamicAnswer != null) {
      return dynamicAnswer!(query);
    }
    return staticAnswer ?? "I'm here to help! What would you like to know?";
  }
}

// ============================================
// DYNAMIC ANSWER GENERATORS
// ============================================

class AnswerGenerators {
  // Generator for attractions
  static String attractionsAnswer(String query) {
    final count = QueryAnalyzer.extractNumber(query) ?? 5;
    final location = QueryAnalyzer.extractLocation(query);

    final attractions = {
      'general': [
        {
          'name': 'Petronas Twin Towers',
          'desc': 'Iconic 452m towers with skybridge',
          'time': '2-3 hrs'
        },
        {
          'name': 'Batu Caves',
          'desc': '272 rainbow stairs, Hindu temple',
          'time': '2 hrs'
        },
        {
          'name': 'KL Tower',
          'desc': '421m observation deck views',
          'time': '1-2 hrs'
        },
        {
          'name': 'Merdeka Square',
          'desc': 'Historic independence site',
          'time': '1 hr'
        },
        {
          'name': 'KLCC Park',
          'desc': 'Free fountain show at 8pm',
          'time': '1 hr'
        },
        {
          'name': 'Central Market',
          'desc': 'Art & handicraft shopping',
          'time': '1-2 hrs'
        },
        {
          'name': 'Islamic Arts Museum',
          'desc': 'Stunning architecture & exhibits',
          'time': '2 hrs'
        },
        {
          'name': 'Thean Hou Temple',
          'desc': '6-tier Chinese temple',
          'time': '1 hr'
        },
        {
          'name': 'Bukit Bintang',
          'desc': 'Shopping & nightlife district',
          'time': '3-4 hrs'
        },
        {
          'name': 'Perdana Botanical Garden',
          'desc': '92-hectare green oasis',
          'time': '2-3 hrs'
        },
      ],
      'penang': [
        {
          'name': 'Street Art Murals',
          'desc': 'Famous Georgetown art',
          'time': '2-3 hrs'
        },
        {
          'name': 'Kek Lok Si Temple',
          'desc': 'Largest Buddhist temple',
          'time': '2 hrs'
        },
        {
          'name': 'Penang Hill',
          'desc': 'Cable car & panoramic views',
          'time': '3 hrs'
        },
        {
          'name': 'Clan Jetties',
          'desc': 'Historic waterfront villages',
          'time': '1 hr'
        },
        {
          'name': 'Fort Cornwallis',
          'desc': '1786 British fort',
          'time': '1 hr'
        },
      ],
    };

    final items = attractions[location] ?? attractions['general']!;
    final limitedItems = items.take(count).toList();

    String result = "Top $count attractions";
    if (location != 'general') {
      result += " in ${location.replaceAll('_', ' ').toUpperCase()}";
    }
    result += "! 🌟✨\n\n";

    for (int i = 0; i < limitedItems.length; i++) {
      final item = limitedItems[i];
      result += "${i + 1}. ${item['name']}\n";
      result += "   ${item['desc']}\n";
      result += "   ⏰ ${item['time']}\n\n";
    }

    result += "💡 Want detailed guides for any of these?\n";
    result += "Check KL The Guide for complete info! 👇";

    return result;
  }

  // Generator for food recommendations
  static String foodAnswer(String query) {
    final location = QueryAnalyzer.extractLocation(query);
    final time = QueryAnalyzer.extractTime(query);
    final count = QueryAnalyzer.extractNumber(query) ?? 5;
    final isBudget = query.toLowerCase().contains('cheap') ||
        query.toLowerCase().contains('budget');

    final restaurants = {
      'klcc_morning': [
        {'name': 'VCR', 'dish': 'Aussie breakfast', 'price': 'RM35-50'},
        {
          'name': 'Feeka Coffee',
          'dish': 'Waffles & coffee',
          'price': 'RM25-40'
        },
        {'name': 'Delicious', 'dish': 'Western brunch', 'price': 'RM30-45'},
      ],
      'klcc_evening': [
        {
          'name': 'Jalan Alor',
          'dish': 'Street food paradise',
          'price': 'RM15-30'
        },
        {'name': 'Madam Kwan\'s', 'dish': 'Nasi lemak', 'price': 'RM20-35'},
        {
          'name': 'Lot 10 Hutong',
          'dish': 'Food court classics',
          'price': 'RM15-25'
        },
      ],
      'bukit_bintang_evening': [
        {
          'name': 'Jalan Alor',
          'dish': 'Grilled seafood, satay',
          'price': 'RM20-40'
        },
        {
          'name': 'Lot 10 Hutong',
          'dish': 'KL best hawker food',
          'price': 'RM15-30'
        },
        {'name': 'Imbi Market', 'dish': 'Curry laksa', 'price': 'RM10-15'},
      ],
      'general_budget': [
        {
          'name': 'Mamak Stalls',
          'dish': 'Roti canai, nasi lemak',
          'price': 'RM5-15'
        },
        {
          'name': 'Food Courts',
          'dish': 'Mixed local dishes',
          'price': 'RM8-20'
        },
        {
          'name': 'Chow Kit Market',
          'dish': 'Local breakfast',
          'price': 'RM5-12'
        },
      ],
      'general': [
        {
          'name': 'Nasi Lemak',
          'dish': 'Coconut rice breakfast',
          'price': 'RM8-25'
        },
        {
          'name': 'Char Kuey Teow',
          'dish': 'Wok-fried noodles',
          'price': 'RM8-15'
        },
        {'name': 'Satay', 'dish': 'Grilled meat skewers', 'price': 'RM12-20'},
        {'name': 'Roti Canai', 'dish': 'Flaky flatbread', 'price': 'RM3-8'},
        {'name': 'Laksa', 'dish': 'Spicy noodle soup', 'price': 'RM10-18'},
      ],
    };

    String key = isBudget
        ? 'general_budget'
        : location != 'general'
        ? '${location}_$time'
        : 'general';

    final items = restaurants[key] ?? restaurants['general']!;
    final limitedItems = items.take(count).toList();

    String result = "🍜 Top $count food spots";
    if (time != 'anytime') result += " for $time";
    if (location != 'general') {
      result += " near ${location.replaceAll('_', ' ')}";
    }
    result += "! 😋\n\n";

    for (int i = 0; i < limitedItems.length; i++) {
      final item = limitedItems[i];
      result += "${i + 1}. ${item['name']}\n";
      result += "   🍽️ ${item['dish']}\n";
      result += "   💰 ${item['price']}\n\n";
    }

    result += "All spots are safe & delicious! 👍\n\n";
    result += "💡 Want more foodie recommendations?\n";
    result += "Check KL The Guide for complete reviews! 👇";

    return result;
  }

  // Generator for shopping
  static String shoppingAnswer(String query) {
    final budget = QueryAnalyzer.extractBudget(query);
    final count = QueryAnalyzer.extractNumber(query) ?? 5;

    final malls = [
      {
        'name': 'Pavilion KL',
        'type': 'Luxury brands',
        'area': 'Bukit Bintang',
        'budget': 'High'
      },
      {
        'name': 'Suria KLCC',
        'type': 'Premium shopping',
        'area': 'KLCC',
        'budget': 'High'
      },
      {
        'name': 'TRX Exchange',
        'type': 'Newest & fanciest',
        'area': 'TRX',
        'budget': 'High'
      },
      {
        'name': 'Mid Valley',
        'type': 'Massive selection',
        'area': 'Mid Valley',
        'budget': 'Mid'
      },
      {
        'name': 'Sunway Pyramid',
        'type': 'Family entertainment',
        'area': 'Sunway',
        'budget': 'Mid'
      },
      {
        'name': 'Central Market',
        'type': 'Souvenirs & crafts',
        'area': 'Chinatown',
        'budget': 'Low'
      },
      {
        'name': 'Petaling Street',
        'type': 'Bargain shopping',
        'area': 'Chinatown',
        'budget': 'Low'
      },
      {
        'name': '1 Utama',
        'type': 'Huge mall with rainforest',
        'area': 'PJ',
        'budget': 'Mid'
      },
    ];

    final filtered = budget != null && budget < 100
        ? malls
        .where((m) => m['budget'] == 'Low' || m['budget'] == 'Mid')
        .toList()
        : malls;

    final limitedItems = filtered.take(count).toList();

    String result = "🛍️ Top $count shopping destinations! ✨\n\n";

    for (int i = 0; i < limitedItems.length; i++) {
      final mall = limitedItems[i];
      result += "${i + 1}. ${mall['name']}\n";
      result += "   ${mall['type']}\n";
      result += "   📍 ${mall['area']} | Budget: ${mall['budget']}\n\n";
    }

    result += "⏰ Most malls: 10am-10pm\n";
    result += "🎉 Mega sales: March, August, December\n\n";
    result += "💡 Need mall details & directions?\n";
    result += "Check KL The Guide for shopping guides! 👇";

    return result;
  }

  // Generator for transport
  static String transportAnswer(String query) {
    final from = query.toLowerCase().contains('airport')
        ? 'airport'
        : query.toLowerCase().contains('klcc')
        ? 'klcc'
        : 'general';

    if (from == 'airport') {
      return "🛬 From KLIA Airport to city! 🚇\n\n"
          "Best options:\n\n"
          "1. KLIA Express Train 🚄\n"
          "   • 28 minutes to KL Sentral\n"
          "   • RM55 one-way\n"
          "   • Every 15-20 mins\n"
          "   • Most convenient!\n\n"
          "2. Grab Car 🚗\n"
          "   • 45-60 mins (traffic dependent)\n"
          "   • RM60-90 to city center\n"
          "   • Door-to-door\n\n"
          "3. Airport Bus 🚌\n"
          "   • RM10-12\n"
          "   • 1-1.5 hours\n"
          "   • Budget option\n\n"
          "💡 Pro tip: KLIA Express + Grab to hotel = best combo!\n\n"
          "Need detailed transport routes?\n"
          "Check KL The Guide for all options! 👇";
    }

    return "Getting around KL is EASY! 🚇🚗\n\n"
        "📱 Best options:\n\n"
        "1. Grab (like Uber)\n"
        "   • Safest & easiest\n"
        "   • RM8-30 within city\n"
        "   • Download app first!\n\n"
        "2. LRT/MRT Trains\n"
        "   • RM1-5 per trip\n"
        "   • Fast & clean\n"
        "   • 6am-midnight\n\n"
        "3. FREE Go KL Bus\n"
        "   • Purple buses in city\n"
        "   • Completely free!\n\n"
        "4. Walking 🚶\n"
        "   • City center is walkable\n"
        "   • 15-20 min between malls\n\n"
        "💡 Want train maps & routes?\n"
        "Visit KL The Guide for transport details! 👇";
  }

  // Generator for budget planning
  static String budgetAnswer(String query) {
    final days = QueryAnalyzer.extractNumber(query) ?? 3;
    final isBudget = query.toLowerCase().contains('budget') ||
        query.toLowerCase().contains('cheap');
    final isLuxury = query.toLowerCase().contains('luxury') ||
        query.toLowerCase().contains('expensive');

    String result = "💰 $days-Day Malaysia Budget Guide! ✨\n\n";

    if (isBudget) {
      result += "🎒 BUDGET TRAVELER:\n\n";
      result += "Per Day: RM100-150 (USD25-35)\n";
      result += "• Hostel: RM30-50\n";
      result += "• Food: RM30-50 (street food)\n";
      result += "• Transport: RM10-20 (LRT/bus)\n";
      result += "• Activities: RM20-30 (free sites + 1 paid)\n\n";
      result += "$days Days Total: RM${100 * days}-${150 * days}\n";
      result += "≈ USD${25 * days}-${35 * days}\n\n";
      result += "💡 Budget tips:\n";
      result += "• Eat at hawker centers\n";
      result += "• Use public transport\n";
      result += "• Visit free attractions\n";
      result += "• Stay in Chinatown area\n";
    } else if (isLuxury) {
      result += "💎 LUXURY TRAVELER:\n\n";
      result += "Per Day: RM800+ (USD190+)\n";
      result += "• 5-star hotel: RM400-600\n";
      result += "• Fine dining: RM200-300\n";
      result += "• Private transport: RM150-200\n";
      result += "• Premium activities: RM100-150\n\n";
      result += "$days Days Total: RM${800 * days}+\n";
      result += "≈ USD${190 * days}+\n\n";
      result += "💡 Luxury perks:\n";
      result += "• Rooftop bars with views\n";
      result += "• Private tours available\n";
      result += "• Spa & wellness centers\n";
      result += "• KLCC/Bangsar hotels\n";
    } else {
      result += "🏨 MID-RANGE TRAVELER:\n\n";
      result += "Per Day: RM250-400 (USD60-95)\n";
      result += "• Hotel: RM120-200\n";
      result += "• Food: RM80-120 (mix of restaurants)\n";
      result += "• Transport: RM30-50 (Grab)\n";
      result += "• Activities: RM50-80\n\n";
      result += "$days Days Total: RM${250 * days}-${400 * days}\n";
      result += "≈ USD${60 * days}-${95 * days}\n\n";
      result += "💡 Sweet spot for comfort!\n";
      result += "• 3-star hotels\n";
      result += "• Mix street food & restaurants\n";
      result += "• Grab for convenience\n";
      result += "• All major attractions\n";
    }

    result += "\n💡 Want detailed budget breakdown?\n";
    result += "Check KL The Guide for money tips! 👇";

    return result;
  }
}

// ============================================
// DYNAMIC-GENERATOR Q&A ENTRIES
// ============================================

const List<QA> kDynamicQA = [
  QA(
    patterns: [
      'attraction',
      'see',
      'visit',
      'sights',
      'landmarks',
      'tourist',
      'top places',
      'must see'
    ],
    answerType: 'dynamic',
    dynamicAnswer: AnswerGenerators.attractionsAnswer,
    quick: ['Top 10 must-see', 'Hidden gems', 'KL The Guide 🔗'],
  ),

  // ========== FOOD (DYNAMIC) ==========
  QA(
    patterns: [
      'food',
      'eat',
      'hungry',
      'restaurant',
      'dishes',
      'breakfast',
      'lunch',
      'dinner'
    ],
    answerType: 'dynamic',
    dynamicAnswer: AnswerGenerators.foodAnswer,
    quick: ['Where to eat', 'Halal options', 'KL The Guide 🔗'],
  ),

  // ========== SHOPPING (DYNAMIC) ==========
  QA(
    patterns: ['shopping', 'mall', 'buy', 'shop', 'souvenirs', 'where to buy'],
    answerType: 'dynamic',
    dynamicAnswer: AnswerGenerators.shoppingAnswer,
    quick: ['Sale seasons', 'Mall locations', 'KL The Guide 🔗'],
  ),

  // ========== TRANSPORT (DYNAMIC) ==========
  QA(
    patterns: [
      'transport',
      'travel',
      'getting around',
      'how to get',
      'move around',
      'grab',
      'taxi'
    ],
    answerType: 'dynamic',
    dynamicAnswer: AnswerGenerators.transportAnswer,
    quick: ['Train routes', 'Best apps', 'KL The Guide 🔗'],
  ),

  // ========== BUDGET (DYNAMIC) ==========
  QA(
    patterns: [
      'budget',
      'cost',
      'expensive',
      'cheap',
      'money',
      'price',
      'how much'
    ],
    answerType: 'dynamic',
    dynamicAnswer: AnswerGenerators.budgetAnswer,
    quick: ['Budget breakdown', 'Free things', 'KL The Guide 🔗'],
  ),
];

// Combines the hardcoded dynamic-generator entries with static Q&A rows
// fetched from the backend into the full list used by respondTo() in
// lib/services/travel_buddy.dart.
List<QA> buildQAList(List<Map<String, dynamic>> backendRows) {
  final staticEntries = backendRows.map((row) {
    return QA(
      patterns: List<String>.from(row['patterns'] as List? ?? const []),
      staticAnswer: (row['answer'] ?? '').toString(),
      quick: List<String>.from(row['quick'] as List? ?? const []),
    );
  });
  return [...kDynamicQA, ...staticEntries];
}
