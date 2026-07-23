// lib/services/travel_buddy.dart
import 'dart:math';
import '../data/travel_playbook.dart';

String respondTo(
  String user,
  List<QA> qaList, {
  String? districtHint,
  bool isNight = false,
}) {
  final q = user.toLowerCase().trim();

  // Return empty if user input is too short
  if (q.isEmpty || q.length < 2) {
    return _fallbacks[rand.nextInt(_fallbacks.length)];
  }

  // Enhanced scoring: count keyword matches per QA
  int bestScore = 0;
  QA? best;

  for (final qa in qaList) {
    int score = 0;
    for (final kw in qa.patterns) {
      final keyword = kw.toLowerCase();

      // Exact match = higher score
      if (q == keyword) {
        score += 10;
      }
      // Contains full keyword = medium score
      else if (q.contains(keyword)) {
        score += 5;
      }
      // Partial match for longer keywords (3+ chars)
      else if (keyword.length >= 3 && q.contains(keyword.substring(0, 3))) {
        score += 1;
      }
    }

    if (score > bestScore) {
      bestScore = score;
      best = qa;
    }
  }

  // Context-aware fallbacks (optional enhancements)
  if (best == null && districtHint != null) {
    final d = districtHint.toLowerCase();
    if (d.contains('bukit bintang') || d.contains('bb')) {
      return "Around Bukit Bintang tonight:\n\n"
          "🍜 Jalan Alor food street (6-11pm)\n"
          "⛲ Pavilion fountain show (8pm)\n"
          "🍹 Changkat nightlife & rooftop bars\n"
          "✨ TRX Exchange Park light show\n\n"
          "All within walking distance! Safe & fun 😊";
    }
    if (d.contains('klcc')) {
      return "Around KLCC area:\n\n"
          "🏙️ Twin Towers photo time!\n"
          "⛲ Lake Symphony fountain show (8pm & 9pm)\n"
          "🛍️ Suria KLCC shopping\n"
          "🐠 Aquaria underwater tunnel\n"
          "🌳 KLCC Park for evening walk\n\n"
          "Perfect evening spot! ✨";
    }
    if (d.contains('chinatown') || d.contains('petaling')) {
      return "Chinatown vibes! 🏮\n\n"
          "🛍️ Petaling Street (bargain central!)\n"
          "🍜 Street food everywhere\n"
          "🏛️ Sri Mahamariamman Temple\n"
          "🎨 Central Market for crafts\n\n"
          "Go evening for best atmosphere!";
    }
  }

  // Time-based suggestions
  if (best == null && isNight) {
    return "Night time adventures! 🌃✨\n\n"
        "🍜 Jalan Alor: Street food paradise\n"
        "⛲ KLCC: Lake Symphony light show\n"
        "🍹 Changkat: Rooftop bars & nightlife\n"
        "🌉 Saloma Bridge: Perfect for photos\n"
        "🏮 Petaling Street: Night market buzz\n\n"
        "KL is super safe at night - enjoy! 😊";
  }

  // If we found a match, return it
  if (best != null && bestScore > 0) {
    return best.getAnswer(user);
  }

  // Ultimate fallback
  return _fallbacks[rand.nextInt(_fallbacks.length)];
}

// Helper function to get quick reply buttons for the last response
List<String> getQuickReplies(String user, List<QA> qaList) {
  final q = user.toLowerCase().trim();

  // Find best matching QA
  for (final qa in qaList) {
    for (final kw in qa.patterns) {
      if (q.contains(kw.toLowerCase())) {
        return qa.quick;
      }
    }
  }

  // Default quick replies if no match
  return ['Top attractions', 'Best food', 'Getting around'];
}

final rand = Random();

const _fallbacks = [
  "Hmm, I'm not sure about that! 🤔\n\n"
      "Try asking me about:\n"
      "• Food & restaurants\n"
      "• Attractions & sights\n"
      "• Shopping & markets\n"
      "• Transportation tips\n\n"
      "Example: 'Best food near KLCC?' or 'What to do tonight?'",
  "I'd love to help! 😊\n\n"
      "Ask me specific questions like:\n"
      "• 'Where to eat nasi lemak?'\n"
      "• 'How to get to Batu Caves?'\n"
      "• 'Best shopping malls?'\n"
      "• 'Is it safe at night?'\n\n"
      "What would you like to know?",
  "Let me help you explore Malaysia! 🇲🇾✨\n\n"
      "Popular topics:\n"
      "🍜 Food recommendations\n"
      "🏛️ Tourist attractions\n"
      "🛍️ Shopping spots\n"
      "🚇 Getting around\n\n"
      "What interests you most?",
  "Not sure what you're asking! 🤷‍♂️\n\n"
      "Try questions like:\n"
      "• 'Street food recommendations?'\n"
      "• 'Things to do in Bukit Bintang?'\n"
      "• 'Best Instagram spots?'\n"
      "• 'Day trips from KL?'\n\n"
      "I'm here to help! 😊",
];
