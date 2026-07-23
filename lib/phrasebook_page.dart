import 'package:flutter/material.dart';
import 'package:kltheguide/home_page_v2.dart';

class _Phrase {
  final String english;
  final String malay;
  const _Phrase(this.english, this.malay);
}

const _phrases = [
  _Phrase('Hello', 'Helo'),
  _Phrase('Good morning', 'Selamat pagi'),
  _Phrase('Good night', 'Selamat malam'),
  _Phrase('Goodbye', 'Selamat tinggal'),
  _Phrase('Please', 'Tolong'),
  _Phrase('Thank you', 'Terima kasih'),
  _Phrase("You're welcome", 'Sama-sama'),
  _Phrase('Yes', 'Ya'),
  _Phrase('No', 'Tidak'),
  _Phrase('Excuse me / Sorry', 'Maaf'),
  _Phrase('How much is this?', 'Berapa harga ini?'),
  _Phrase('Where is the toilet?', 'Di mana tandas?'),
  _Phrase('I don\'t understand', 'Saya tidak faham'),
  _Phrase('Do you speak English?', 'Anda boleh cakap Bahasa Inggeris?'),
  _Phrase('Help!', 'Tolong!'),
  _Phrase('Delicious', 'Sedap'),
  _Phrase('Water', 'Air'),
];

class PhrasebookPage extends StatelessWidget {
  const PhrasebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.accent),
        title: Text(
          'Phrasebook',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: _phrases.length,
        itemBuilder: (context, index) {
          final phrase = _phrases[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    phrase.english,
                    style: TextStyle(fontSize: 14.5, color: palette.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phrase.malay,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
