import 'package:customer/features/product/domain/entities/product_questions.dart';

/// Stand-in until questions are served: the design's questions about the
/// Nova X Pro, filtered, searched and sorted here as the server will.
class QuestionsLocalDataSource {
  const QuestionsLocalDataSource();

  QuestionsPage questions(
    String id, {
    required String? topic,
    required String search,
    required QuestionSort sort,
  }) {
    final words = search.trim().toLowerCase();
    final kept = _all
        .where((q) => topic == null || q.topic == topic)
        .where(
          (q) =>
              words.isEmpty ||
              q.question.toLowerCase().contains(words) ||
              q.answers.any((a) => a.text.toLowerCase().contains(words)),
        )
        .toList();
    if (sort == QuestionSort.newest) {
      kept.sort(
        (a, b) => _newest.indexOf(a.id).compareTo(_newest.indexOf(b.id)),
      );
    }
    return QuestionsPage(
      product: 'Nova X Pro 5G · 256 GB',
      topics: _topics,
      total: 38,
      answerCount: 112,
      questions: kept,
    );
  }
}

const List<String> _topics = <String>[
  'Battery',
  'Camera',
  'SIM & network',
  'In the box',
  'Charging',
];

/// Newest first, by id.
const List<String> _newest = <String>[
  'q-8k',
  'q-protector',
  'q-calls',
  'q-battery',
  'q-charger',
  'q-esim',
];

/// Most helpful first, as the server ranks them.
const List<ProductQuestion> _all = <ProductQuestion>[
  ProductQuestion(
    id: 'q-esim',
    question: 'Does it support dual eSIM?',
    topic: 'SIM & network',
    answers: <Answer>[
      Answer(
        text: 'Yes. You can use two eSIMs, or one nano-SIM with one eSIM.',
        author: 'Nova Official Store',
        by: AnswerBy.seller,
        helpful: 12,
      ),
      Answer(
        text: 'I use du and Etisalat eSIMs together with no issues.',
        author: 'Ahmed K.',
        by: AnswerBy.buyer,
        helpful: 5,
      ),
      Answer(
        text: 'Yes, and you can switch the data line in Settings.',
        author: 'Meera P.',
        by: AnswerBy.buyer,
        helpful: 1,
      ),
    ],
  ),
  ProductQuestion(
    id: 'q-charger',
    question: 'Is a charger included in the box?',
    topic: 'Charging',
    answers: <Answer>[
      Answer(
        text:
            'No. The box has a USB-C cable only. The 45 W Nova charger works '
            'best.',
        author: 'Nova Official Store',
        by: AnswerBy.seller,
        helpful: 31,
      ),
      Answer(
        text: 'Any USB-C PD charger works; mine charges fine at 30 W.',
        author: 'Priya N.',
        by: AnswerBy.buyer,
        helpful: 7,
      ),
    ],
  ),
  ProductQuestion(
    id: 'q-battery',
    question: 'How long does the battery last with heavy use?',
    topic: 'Battery',
    answers: <Answer>[
      Answer(
        text:
            'About a day and a half for me with 5G, maps and camera on. '
            'Screen time is around 8 hours.',
        author: 'Ahmed K.',
        by: AnswerBy.buyer,
        helpful: 54,
      ),
      Answer(
        text: 'A full day of gaming and video, with about 20% left at night.',
        author: 'Omar S.',
        by: AnswerBy.buyer,
        helpful: 21,
      ),
      Answer(
        text: 'Rated for 29 hours of video playback.',
        author: 'Nova Official Store',
        by: AnswerBy.seller,
        helpful: 15,
      ),
      Answer(
        text: 'Two days with light use and the always-on display off.',
        author: 'Meera P.',
        by: AnswerBy.buyer,
        helpful: 8,
      ),
      Answer(
        text: 'Battery saver adds a few hours when you need it.',
        author: 'Lina H.',
        by: AnswerBy.buyer,
        helpful: 3,
      ),
      Answer(
        text: 'Easily lasts a long-haul flight with downloads.',
        author: 'Yusuf A.',
        by: AnswerBy.buyer,
        helpful: 2,
      ),
    ],
  ),
  ProductQuestion(
    id: 'q-calls',
    question: 'Does the UAE version support FaceTime and WhatsApp calls?',
    topic: 'SIM & network',
    answers: <Answer>[
      Answer(
        text:
            'Yes. Both work out of the box on the UAE model with the latest '
            'update.',
        author: 'Nova Official Store',
        by: AnswerBy.seller,
        helpful: 47,
      ),
      Answer(
        text: 'WhatsApp video calls work fine for me in Abu Dhabi.',
        author: 'Omar S.',
        by: AnswerBy.buyer,
        helpful: 12,
      ),
      Answer(
        text: 'FaceTime works after you sign in with your Apple ID app.',
        author: 'Priya N.',
        by: AnswerBy.buyer,
        helpful: 4,
      ),
      Answer(
        text: 'Yes, and Wi-Fi calling is on by default.',
        author: 'Yusuf A.',
        by: AnswerBy.buyer,
        helpful: 2,
      ),
    ],
  ),
  ProductQuestion(
    id: 'q-protector',
    question: 'Is the screen protector pre-installed?',
    topic: 'In the box',
    answers: <Answer>[
      Answer(
        text:
            'Yes, a factory film is on the screen. We still recommend '
            'tempered glass.',
        author: 'Tekvo Support',
        by: AnswerBy.seller,
        helpful: 9,
      ),
    ],
  ),
  ProductQuestion(
    id: 'q-8k',
    question: 'Can I record 8K video at 30 fps?',
    topic: 'Camera',
    answers: <Answer>[
      Answer(
        text:
            'Yes, at 24 and 30 fps from the main camera. Files are large, '
            'so 512 GB helps.',
        author: 'Lina H.',
        by: AnswerBy.buyer,
        helpful: 18,
      ),
      Answer(
        text: 'Yes. 8K is in the camera app under More, then Video size.',
        author: 'Nova Official Store',
        by: AnswerBy.seller,
        helpful: 6,
      ),
    ],
  ),
];
