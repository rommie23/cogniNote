class BiasDetector {
  static const Map<String, List<String>> biasKeywords = {
    // -----------------------------------------
    // ARGUMENT / CONFLICT BIASES
    // -----------------------------------------

    "Confirmation Bias": [
      "i knew i was right",
      "this proves",
      "they always",
      "i knew this would happen",
      "obviously",
      "exactly what i expected",
      "just like always"
    ],

    "Fundamental Attribution Error": [
      "he is just rude",
      "she is selfish",
      "they never care",
      "he always behaves like this",
      "that's just how he is",
      "she does this intentionally"
    ],

    "Hostile Attribution Bias": [
      "he did it on purpose",
      "she meant to hurt me",
      "they intentionally",
      "he wanted to make me angry",
      "she knew this would bother me"
    ],

    "Self-Serving Bias": [
      "not my fault",
      "they made me do it",
      "i reacted because of them",
      "they started it",
      "i did nothing wrong"
    ],

    // -----------------------------------------
    // NEGATIVE THOUGHT / SAD / LOW MOOD
    // -----------------------------------------

    "Negativity Bias": [
      "nothing good happened",
      "everything went wrong",
      "worst day",
      "only bad things",
      "nothing positive"
    ],

    "Catastrophizing": [
      "my life is ruined",
      "everything is a mess",
      "this always happens",
      "i can't handle this",
      "it's over for me"
    ],

    "Overgeneralization": [
      "i always fail",
      "i never succeed",
      "everyone hates me",
      "nothing ever works",
      "i fail at everything"
    ],

    "Personalization": [
      "it must be my fault",
      "maybe it's because of me",
      "i caused this",
      "it's all my fault",
      "i ruined everything"
    ],

    // -----------------------------------------
    // ANGER / LOSS OF CONTROL
    // -----------------------------------------

    "Emotional Reasoning": [
      "i was so angry",
      "i felt terrible so it must be bad",
      "my feelings are proof",
      "i feel upset so it's wrong"
    ],

    "Jumping to Conclusions": [
      "they must think i'm useless",
      "he definitely hates me",
      "she must be lying",
      "i know they don’t like me",
      "i know what they think"
    ],

    "Attribution Bias": [
      "they did this knowingly",
      "he knew i would get angry",
      "she did it deliberately",
      "they acted with bad intentions"
    ],

    // -----------------------------------------
    // FAILURE / DOUBT / IMPOSTOR
    // -----------------------------------------

    "Impostor Syndrome": [
      "i don’t deserve this",
      "i’m not good enough",
      "i’m a fraud",
      "i just got lucky",
      "others are better"
    ],

    "Fixed Mindset": [
      "i can't improve",
      "i'm not talented",
      "i will always be like this",
      "i can't change",
      "i’m just bad at this"
    ],

    "Pessimism Bias": [
      "it will definitely fail",
      "nothing will work",
      "why even try",
      "i expect the worst",
      "no hope"
    ],

    // -----------------------------------------
    // POSITIVE / REFLECTION BIASES
    // -----------------------------------------

    "Optimism Bias": [
      "i think things will be better",
      "i feel hopeful",
      "tomorrow will be good",
      "i believe it will turn out well"
    ],

    "Positive Self-Serving Bias": [
      "i handled it well",
      "i did a good job",
      "i gave my best",
      "i think i did great"
    ],

    "Rosy Retrospection": [
      "looking back it wasn't that bad",
      "it wasn’t as bad as i thought",
      "in hindsight"
    ],

    "Gratitude Bias": [
      "i am thankful",
      "i appreciate",
      "grateful for",
      "i feel blessed"
    ],
  };

  /// Returns a list of suggested biases based on text
  static List<String> detectBiases(String text) {
    text = text.toLowerCase();
    final Map<String, int> score = {};

    biasKeywords.forEach((bias, keywords) {
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score[bias] = (score[bias] ?? 0) + 1;
        }
      }
    });

    // Sort by highest score
    final sorted = score.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return top 3 suggestions
    return sorted.map((e) => e.key).take(3).toList();
  }
}
