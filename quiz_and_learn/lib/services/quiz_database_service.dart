import '../models/quiz_question.dart';

class QuizDatabaseService {
  static final QuizDatabaseService _instance = QuizDatabaseService._internal();
  factory QuizDatabaseService() => _instance;
  QuizDatabaseService._internal();

  // Get all questions for a specific category and difficulty
  List<QuizQuestion> getQuestionsByCategoryAndDifficulty(
    QuizCategory category,
    QuizDifficulty difficulty, {
    int limit = 10,
  }) {
    final questions = _getAllQuestions()
        .where((q) => q.category == category && q.difficulty == difficulty)
        .toList();

    questions.shuffle();
    return questions.take(limit).toList();
  }

  // Get all available categories
  List<QuizCategory> getAvailableCategories() {
    return QuizCategory.values.toList();
  }

  // Get all available difficulties
  List<QuizDifficulty> getAvailableDifficulties() {
    return QuizDifficulty.values.toList();
  }

  // Get random questions for mixed category quiz
  List<QuizQuestion> getRandomQuestions({int count = 15}) {
    final allQuestions = _getAllQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  // Private method to get all questions
  List<QuizQuestion> _getAllQuestions() {
    return [
      ..._getGeneralQuestions(),
      ..._getScienceQuestions(),
      ..._getHistoryQuestions(),
      ..._getGeographyQuestions(),
      ..._getMathematicsQuestions(),
      ..._getLiteratureQuestions(),
      ..._getTechnologyQuestions(),
      ..._getSportsQuestions(),
      ..._getEntertainmentQuestions(),
      ..._getHealthQuestions(),
      ..._getEnvironmentQuestions(),
      ..._getEconomicsQuestions(),
      ..._getPoliticsQuestions(),
      ..._getArtQuestions(),
      ..._getMusicQuestions(),
    ];
  }

  // General Knowledge Questions
  List<QuizQuestion> _getGeneralQuestions() {
    return [
      QuizQuestion(
        id: 'gen_001',
        question: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswer: 2,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.easy,
        explanation: 'Paris is the capital and largest city of France.',
        points: 10,
        tags: ['capital', 'france', 'europe'],
      ),
      QuizQuestion(
        id: 'gen_002',
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Mars is called the Red Planet due to its reddish appearance.',
        points: 10,
        tags: ['planets', 'space', 'mars'],
      ),
      QuizQuestion(
        id: 'gen_003',
        question: 'What is the largest ocean on Earth?',
        options: [
          'Atlantic Ocean',
          'Indian Ocean',
          'Arctic Ocean',
          'Pacific Ocean'
        ],
        correctAnswer: 3,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The Pacific Ocean is the largest and deepest ocean on Earth.',
        points: 10,
        tags: ['oceans', 'geography', 'earth'],
      ),
      QuizQuestion(
        id: 'gen_004',
        question: 'How many continents are there on Earth?',
        options: ['5', '6', '7', '8'],
        correctAnswer: 2,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.easy,
        explanation:
            'There are 7 continents: Asia, Africa, North America, South America, Antarctica, Europe, and Australia.',
        points: 10,
        tags: ['continents', 'geography', 'earth'],
      ),
      QuizQuestion(
        id: 'gen_005',
        question: 'What is the chemical symbol for gold?',
        options: ['Ag', 'Au', 'Fe', 'Cu'],
        correctAnswer: 1,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.medium,
        explanation: 'Au comes from the Latin word "aurum" meaning gold.',
        points: 15,
        tags: ['chemistry', 'elements', 'gold'],
      ),
      QuizQuestion(
        id: 'gen_006',
        question: 'Which country has the most time zones?',
        options: ['Russia', 'United States', 'France', 'China'],
        correctAnswer: 0,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.medium,
        explanation: 'Russia spans 11 time zones, the most of any country.',
        points: 15,
        tags: ['time zones', 'geography', 'russia'],
      ),
      QuizQuestion(
        id: 'gen_007',
        question: 'What is the longest river in the world?',
        options: ['Amazon', 'Nile', 'Yangtze', 'Mississippi'],
        correctAnswer: 1,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The Nile River is approximately 6,650 km long, making it the longest river in the world.',
        points: 15,
        tags: ['rivers', 'geography', 'nile'],
      ),
      QuizQuestion(
        id: 'gen_008',
        question: 'Which element has the atomic number 1?',
        options: ['Helium', 'Hydrogen', 'Carbon', 'Oxygen'],
        correctAnswer: 1,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Hydrogen has atomic number 1 and is the lightest element.',
        points: 15,
        tags: ['chemistry', 'elements', 'hydrogen'],
      ),
      QuizQuestion(
        id: 'gen_009',
        question: 'What is the largest desert in the world?',
        options: ['Sahara', 'Antarctic', 'Arabian', 'Gobi'],
        correctAnswer: 1,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The Antarctic Desert is the largest desert in the world, covering about 14.2 million square kilometers.',
        points: 20,
        tags: ['deserts', 'geography', 'antarctica'],
      ),
      QuizQuestion(
        id: 'gen_010',
        question: 'Which country has the highest population in the world?',
        options: ['India', 'China', 'United States', 'Indonesia'],
        correctAnswer: 1,
        category: QuizCategory.general,
        difficulty: QuizDifficulty.hard,
        explanation:
            'China has the world\'s largest population with over 1.4 billion people.',
        points: 20,
        tags: ['population', 'demographics', 'china'],
      ),
    ];
  }

  // Science Questions
  List<QuizQuestion> _getScienceQuestions() {
    return [
      QuizQuestion(
        id: 'sci_001',
        question: 'What is the hardest natural substance on Earth?',
        options: ['Steel', 'Iron', 'Diamond', 'Granite'],
        correctAnswer: 2,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.easy,
        explanation: 'Diamond is the hardest known natural material.',
        points: 10,
        tags: ['minerals', 'hardness', 'diamond'],
      ),
      QuizQuestion(
        id: 'sci_002',
        question: 'What is the chemical formula for water?',
        options: ['H2O2', 'CO2', 'H2O', 'NaCl'],
        correctAnswer: 2,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.easy,
        explanation: 'H2O represents two hydrogen atoms and one oxygen atom.',
        points: 10,
        tags: ['chemistry', 'water', 'molecules'],
      ),
      QuizQuestion(
        id: 'sci_003',
        question: 'What is the largest organ in the human body?',
        options: ['Heart', 'Liver', 'Skin', 'Brain'],
        correctAnswer: 2,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The skin is the largest organ, covering about 20 square feet in adults.',
        points: 10,
        tags: ['anatomy', 'human body', 'organs'],
      ),
      QuizQuestion(
        id: 'sci_004',
        question: 'What is the speed of light?',
        options: ['186,000 mph', '186,000 km/s', '186,000 m/s', '186,000 km/h'],
        correctAnswer: 1,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Light travels at approximately 186,000 kilometers per second in a vacuum.',
        points: 15,
        tags: ['physics', 'light', 'speed'],
      ),
      QuizQuestion(
        id: 'sci_005',
        question: 'What is the atomic number of carbon?',
        options: ['4', '6', '8', '12'],
        correctAnswer: 1,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.medium,
        explanation: 'Carbon has atomic number 6, meaning it has 6 protons.',
        points: 15,
        tags: ['chemistry', 'elements', 'carbon'],
      ),
      QuizQuestion(
        id: 'sci_006',
        question: 'What is the process by which plants make food?',
        options: ['Respiration', 'Photosynthesis', 'Digestion', 'Fermentation'],
        correctAnswer: 1,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Photosynthesis is the process where plants convert sunlight into food.',
        points: 10,
        tags: ['biology', 'plants', 'photosynthesis'],
      ),
      QuizQuestion(
        id: 'sci_007',
        question: 'What is the SI unit of force?',
        options: ['Joule', 'Watt', 'Newton', 'Pascal'],
        correctAnswer: 2,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The Newton (N) is the SI unit of force, named after Isaac Newton.',
        points: 15,
        tags: ['physics', 'force', 'units'],
      ),
      QuizQuestion(
        id: 'sci_008',
        question: 'What is the chemical symbol for iron?',
        options: ['Ir', 'Fe', 'In', 'Fr'],
        correctAnswer: 1,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.medium,
        explanation: 'Fe comes from the Latin word "ferrum" meaning iron.',
        points: 15,
        tags: ['chemistry', 'elements', 'iron'],
      ),
      QuizQuestion(
        id: 'sci_009',
        question: 'What is the theory of relativity associated with?',
        options: [
          'Isaac Newton',
          'Albert Einstein',
          'Galileo Galilei',
          'Nikola Tesla'
        ],
        correctAnswer: 1,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Albert Einstein developed the theory of relativity in the early 20th century.',
        points: 20,
        tags: ['physics', 'relativity', 'einstein'],
      ),
      QuizQuestion(
        id: 'sci_010',
        question: 'What is the largest planet in our solar system?',
        options: ['Saturn', 'Jupiter', 'Neptune', 'Uranus'],
        correctAnswer: 1,
        category: QuizCategory.science,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Jupiter is the largest planet, with a mass more than twice that of Saturn.',
        points: 15,
        tags: ['astronomy', 'planets', 'jupiter'],
      ),
    ];
  }

  // History Questions
  List<QuizQuestion> _getHistoryQuestions() {
    return [
      QuizQuestion(
        id: 'his_001',
        question: 'In which year did World War II end?',
        options: ['1943', '1944', '1945', '1946'],
        correctAnswer: 2,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.easy,
        explanation:
            'World War II ended in 1945 with the surrender of Germany and Japan.',
        points: 10,
        tags: ['world war ii', '20th century', 'war'],
      ),
      QuizQuestion(
        id: 'his_002',
        question: 'Who was the first President of the United States?',
        options: [
          'John Adams',
          'Thomas Jefferson',
          'George Washington',
          'Benjamin Franklin'
        ],
        correctAnswer: 2,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.easy,
        explanation:
            'George Washington served as the first President from 1789 to 1797.',
        points: 10,
        tags: ['us history', 'presidents', 'founding fathers'],
      ),
      QuizQuestion(
        id: 'his_003',
        question: 'In which year did Columbus discover America?',
        options: ['1492', '1498', '1500', '1502'],
        correctAnswer: 0,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Christopher Columbus reached the Americas in 1492, though he thought he had reached Asia.',
        points: 15,
        tags: ['exploration', 'columbus', 'americas'],
      ),
      QuizQuestion(
        id: 'his_004',
        question: 'Who was the first Emperor of Rome?',
        options: ['Julius Caesar', 'Augustus', 'Nero', 'Constantine'],
        correctAnswer: 1,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Augustus was the first Roman Emperor, ruling from 27 BC to 14 AD.',
        points: 15,
        tags: ['roman empire', 'augustus', 'ancient rome'],
      ),
      QuizQuestion(
        id: 'his_005',
        question: 'What year did the French Revolution begin?',
        options: ['1789', '1799', '1804', '1815'],
        correctAnswer: 0,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The French Revolution began in 1789 with the storming of the Bastille.',
        points: 15,
        tags: ['french revolution', '18th century', 'france'],
      ),
      QuizQuestion(
        id: 'his_006',
        question: 'Who was the last Tsar of Russia?',
        options: ['Nicholas I', 'Alexander II', 'Nicholas II', 'Alexander III'],
        correctAnswer: 2,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Nicholas II was the last Tsar of Russia, executed in 1918 during the Russian Revolution.',
        points: 15,
        tags: ['russian history', 'tsars', 'nicholas ii'],
      ),
      QuizQuestion(
        id: 'his_007',
        question: 'In which year did the Berlin Wall fall?',
        options: ['1987', '1989', '1991', '1993'],
        correctAnswer: 1,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The Berlin Wall fell on November 9, 1989, marking the end of the Cold War era.',
        points: 15,
        tags: ['cold war', 'berlin wall', 'germany'],
      ),
      QuizQuestion(
        id: 'his_008',
        question: 'Who was the first female Prime Minister of the UK?',
        options: [
          'Queen Elizabeth II',
          'Margaret Thatcher',
          'Theresa May',
          'Indira Gandhi'
        ],
        correctAnswer: 1,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Margaret Thatcher became the first female Prime Minister of the UK in 1979.',
        points: 15,
        tags: ['uk history', 'prime ministers', 'margaret thatcher'],
      ),
      QuizQuestion(
        id: 'his_009',
        question: 'What year did the Titanic sink?',
        options: ['1910', '1912', '1914', '1916'],
        correctAnswer: 1,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The RMS Titanic sank on April 15, 1912, after hitting an iceberg.',
        points: 10,
        tags: ['titanic', 'maritime history', '20th century'],
      ),
      QuizQuestion(
        id: 'his_010',
        question: 'Who was the first President to be assassinated?',
        options: [
          'Abraham Lincoln',
          'James Garfield',
          'William McKinley',
          'John F. Kennedy'
        ],
        correctAnswer: 0,
        category: QuizCategory.history,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Abraham Lincoln was the first US President to be assassinated, in 1865.',
        points: 20,
        tags: ['us history', 'assassination', 'abraham lincoln'],
      ),
    ];
  }

  // Geography Questions
  List<QuizQuestion> _getGeographyQuestions() {
    return [
      QuizQuestion(
        id: 'geo_001',
        question: 'What is the largest country in the world by area?',
        options: ['China', 'Canada', 'United States', 'Russia'],
        correctAnswer: 3,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Russia is the largest country by land area, covering over 17 million square kilometers.',
        points: 10,
        tags: ['countries', 'size', 'russia'],
      ),
      QuizQuestion(
        id: 'geo_002',
        question: 'Which mountain range runs through South America?',
        options: ['Rocky Mountains', 'Alps', 'Himalayas', 'Andes'],
        correctAnswer: 3,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The Andes is the longest continental mountain range in the world.',
        points: 10,
        tags: ['mountains', 'south america', 'andes'],
      ),
      QuizQuestion(
        id: 'geo_003',
        question: 'What is the capital of Australia?',
        options: ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
        correctAnswer: 2,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Canberra is the capital city of Australia, not Sydney or Melbourne.',
        points: 10,
        tags: ['capitals', 'australia', 'cities'],
      ),
      QuizQuestion(
        id: 'geo_004',
        question: 'Which desert is located in northern Africa?',
        options: [
          'Gobi Desert',
          'Sahara Desert',
          'Arabian Desert',
          'Kalahari Desert'
        ],
        correctAnswer: 1,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The Sahara Desert is the largest hot desert in the world, covering much of northern Africa.',
        points: 10,
        tags: ['deserts', 'africa', 'sahara'],
      ),
      QuizQuestion(
        id: 'geo_005',
        question: 'What is the longest river in Asia?',
        options: ['Ganges', 'Yangtze', 'Mekong', 'Yellow River'],
        correctAnswer: 1,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The Yangtze River is the longest river in Asia and the third longest in the world.',
        points: 15,
        tags: ['rivers', 'asia', 'yangtze'],
      ),
      QuizQuestion(
        id: 'geo_006',
        question: 'Which European country has the most islands?',
        options: ['Greece', 'Sweden', 'Norway', 'Finland'],
        correctAnswer: 1,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Sweden has over 267,000 islands, making it the country with the most islands in Europe.',
        points: 15,
        tags: ['islands', 'europe', 'sweden'],
      ),
      QuizQuestion(
        id: 'geo_007',
        question: 'What is the deepest point in the world\'s oceans?',
        options: [
          'Mariana Trench',
          'Puerto Rico Trench',
          'Java Trench',
          'Philippine Trench'
        ],
        correctAnswer: 0,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The Mariana Trench reaches a depth of about 11,000 meters (36,000 feet).',
        points: 15,
        tags: ['oceans', 'depth', 'mariana trench'],
      ),
      QuizQuestion(
        id: 'geo_008',
        question: 'Which country is home to the world\'s highest waterfall?',
        options: ['Venezuela', 'Brazil', 'Guyana', 'Colombia'],
        correctAnswer: 0,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Angel Falls in Venezuela is the world\'s highest uninterrupted waterfall at 979 meters.',
        points: 20,
        tags: ['waterfalls', 'venezuela', 'angel falls'],
      ),
      QuizQuestion(
        id: 'geo_009',
        question: 'What is the largest lake by surface area in Africa?',
        options: [
          'Lake Victoria',
          'Lake Tanganyika',
          'Lake Malawi',
          'Lake Chad'
        ],
        correctAnswer: 0,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Lake Victoria is Africa\'s largest lake by surface area and the world\'s largest tropical lake.',
        points: 20,
        tags: ['lakes', 'africa', 'lake victoria'],
      ),
      QuizQuestion(
        id: 'geo_010',
        question: 'Which strait separates Asia from North America?',
        options: [
          'Bering Strait',
          'Strait of Gibraltar',
          'Strait of Malacca',
          'Strait of Hormuz'
        ],
        correctAnswer: 0,
        category: QuizCategory.geography,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The Bering Strait separates Russia (Asia) from Alaska (North America) and is only about 85 km wide.',
        points: 20,
        tags: ['straits', 'asia', 'north america', 'bering strait'],
      ),
    ];
  }

  // Mathematics Questions
  List<QuizQuestion> _getMathematicsQuestions() {
    return [
      QuizQuestion(
        id: 'math_001',
        question: 'What is 7 x 8?',
        options: ['54', '56', '58', '60'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.easy,
        explanation: '7 x 8 = 56',
        points: 10,
        tags: ['multiplication', 'basic math', 'arithmetic'],
      ),
      QuizQuestion(
        id: 'math_002',
        question: 'What is the square root of 64?',
        options: ['6', '7', '8', '9'],
        correctAnswer: 2,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.easy,
        explanation: '8 x 8 = 64, so the square root of 64 is 8.',
        points: 10,
        tags: ['square roots', 'basic math', 'arithmetic'],
      ),
      QuizQuestion(
        id: 'math_003',
        question: 'What is 15 + 27?',
        options: ['40', '42', '43', '45'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.easy,
        explanation: '15 + 27 = 42',
        points: 10,
        tags: ['addition', 'basic math', 'arithmetic'],
      ),
      QuizQuestion(
        id: 'math_004',
        question: 'What is 100 ÷ 4?',
        options: ['20', '25', '30', '40'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.easy,
        explanation: '100 ÷ 4 = 25',
        points: 10,
        tags: ['division', 'basic math', 'arithmetic'],
      ),
      QuizQuestion(
        id: 'math_005',
        question: 'What is the value of π (pi) to two decimal places?',
        options: ['3.12', '3.14', '3.16', '3.18'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'π (pi) is approximately 3.14159, so to two decimal places it\'s 3.14.',
        points: 15,
        tags: ['pi', 'geometry', 'constants'],
      ),
      QuizQuestion(
        id: 'math_006',
        question: 'What is 12² (12 squared)?',
        options: ['120', '144', '148', '156'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.medium,
        explanation: '12² = 12 × 12 = 144',
        points: 15,
        tags: ['squares', 'exponents', 'arithmetic'],
      ),
      QuizQuestion(
        id: 'math_007',
        question: 'What is the area of a circle with radius 5?',
        options: ['25π', '50π', '75π', '100π'],
        correctAnswer: 0,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.medium,
        explanation: 'Area = πr² = π × 5² = π × 25 = 25π',
        points: 15,
        tags: ['geometry', 'circles', 'area'],
      ),
      QuizQuestion(
        id: 'math_008',
        question: 'What is the sum of angles in a triangle?',
        options: ['90°', '180°', '270°', '360°'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The sum of all angles in any triangle is always 180 degrees.',
        points: 15,
        tags: ['geometry', 'triangles', 'angles'],
      ),
      QuizQuestion(
        id: 'math_009',
        question: 'What is the cube root of 27?',
        options: ['2', '3', '4', '5'],
        correctAnswer: 1,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.medium,
        explanation: '3³ = 3 × 3 × 3 = 27, so the cube root of 27 is 3.',
        points: 15,
        tags: ['cube roots', 'exponents', 'arithmetic'],
      ),
      QuizQuestion(
        id: 'math_010',
        question: 'What is the slope of a horizontal line?',
        options: ['0', '1', 'Undefined', 'Infinity'],
        correctAnswer: 0,
        category: QuizCategory.mathematics,
        difficulty: QuizDifficulty.hard,
        explanation:
            'A horizontal line has a slope of 0 because there is no vertical change.',
        points: 20,
        tags: ['algebra', 'slope', 'linear equations'],
      ),
    ];
  }

  // Literature Questions
  List<QuizQuestion> _getLiteratureQuestions() {
    return [
      QuizQuestion(
        id: 'lit_001',
        question: 'Who wrote "Romeo and Juliet"?',
        options: [
          'Charles Dickens',
          'William Shakespeare',
          'Jane Austen',
          'Mark Twain'
        ],
        correctAnswer: 1,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.easy,
        explanation:
            'William Shakespeare wrote this famous tragedy in the late 16th century.',
        points: 10,
        tags: ['shakespeare', 'plays', 'tragedy'],
      ),
      QuizQuestion(
        id: 'lit_002',
        question: 'What is the main character in "The Great Gatsby"?',
        options: [
          'Nick Carraway',
          'Jay Gatsby',
          'Daisy Buchanan',
          'Tom Buchanan'
        ],
        correctAnswer: 1,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Jay Gatsby is the titular character, though Nick Carraway is the narrator.',
        points: 15,
        tags: ['american literature', 'fitzgerald', 'novels'],
      ),
      QuizQuestion(
        id: 'lit_003',
        question: 'Who wrote "Pride and Prejudice"?',
        options: [
          'Charlotte Brontë',
          'Emily Brontë',
          'Jane Austen',
          'Mary Shelley'
        ],
        correctAnswer: 2,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.easy,
        explanation: 'Jane Austen wrote "Pride and Prejudice" in 1813.',
        points: 10,
        tags: ['jane austen', 'british literature', 'romance'],
      ),
      QuizQuestion(
        id: 'lit_004',
        question: 'What type of poem is a sonnet?',
        options: ['14 lines', '16 lines', '18 lines', '20 lines'],
        correctAnswer: 0,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.easy,
        explanation: 'A sonnet is a 14-line poem with a specific rhyme scheme.',
        points: 10,
        tags: ['poetry', 'sonnet', 'rhyme'],
      ),
      QuizQuestion(
        id: 'lit_005',
        question: 'Who is the author of "1984"?',
        options: [
          'Aldous Huxley',
          'George Orwell',
          'Ray Bradbury',
          'H.G. Wells'
        ],
        correctAnswer: 1,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.medium,
        explanation: 'George Orwell wrote "1984" as a dystopian novel in 1949.',
        points: 15,
        tags: ['dystopian', 'orwell', 'political fiction'],
      ),
      QuizQuestion(
        id: 'lit_006',
        question: 'What is the setting of "Lord of the Flies"?',
        options: [
          'A deserted island',
          'A boarding school',
          'A war zone',
          'A city'
        ],
        correctAnswer: 0,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.medium,
        explanation: 'The novel is set on a deserted tropical island.',
        points: 15,
        tags: ['golding', 'island', 'survival'],
      ),
      QuizQuestion(
        id: 'lit_007',
        question: 'Who wrote "To Kill a Mockingbird"?',
        options: [
          'Harper Lee',
          'Truman Capote',
          'Carson McCullers',
          'Flannery O\'Connor'
        ],
        correctAnswer: 0,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Harper Lee wrote this classic novel about racial injustice in the American South.',
        points: 15,
        tags: ['american literature', 'harper lee', 'social justice'],
      ),
      QuizQuestion(
        id: 'lit_008',
        question: 'What is the main theme of "Animal Farm"?',
        options: [
          'Environmental conservation',
          'Political corruption',
          'Animal rights',
          'Farm life'
        ],
        correctAnswer: 1,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The novel is an allegory about political corruption and the Russian Revolution.',
        points: 20,
        tags: ['orwell', 'allegory', 'political satire'],
      ),
      QuizQuestion(
        id: 'lit_009',
        question: 'Who is the protagonist of "The Catcher in the Rye"?',
        options: [
          'Holden Caulfield',
          'Phoebe Caulfield',
          'Mr. Antolini',
          'Stradlater'
        ],
        correctAnswer: 0,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Holden Caulfield is the teenage protagonist and narrator of the novel.',
        points: 20,
        tags: ['salinger', 'coming of age', 'teenage angst'],
      ),
      QuizQuestion(
        id: 'lit_010',
        question:
            'What literary device is used when a story begins in the middle of action?',
        options: ['Flashback', 'In medias res', 'Foreshadowing', 'Irony'],
        correctAnswer: 1,
        category: QuizCategory.literature,
        difficulty: QuizDifficulty.hard,
        explanation:
            '"In medias res" means "in the middle of things" and is a narrative technique.',
        points: 20,
        tags: ['literary devices', 'narrative', 'storytelling'],
      ),
    ];
  }

  // Technology Questions
  List<QuizQuestion> _getTechnologyQuestions() {
    return [
      QuizQuestion(
        id: 'tech_001',
        question: 'What does CPU stand for?',
        options: [
          'Central Processing Unit',
          'Computer Personal Unit',
          'Central Personal Unit',
          'Computer Processing Unit'
        ],
        correctAnswer: 0,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.easy,
        explanation:
            'CPU stands for Central Processing Unit, the main processor of a computer.',
        points: 10,
        tags: ['computers', 'hardware', 'cpu'],
      ),
      QuizQuestion(
        id: 'tech_002',
        question: 'What year was the first iPhone released?',
        options: ['2005', '2006', '2007', '2008'],
        correctAnswer: 2,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.medium,
        explanation: 'The first iPhone was released by Apple in 2007.',
        points: 15,
        tags: ['apple', 'iphone', 'smartphones'],
      ),
      QuizQuestion(
        id: 'tech_003',
        question: 'What does RAM stand for?',
        options: [
          'Random Access Memory',
          'Read Access Memory',
          'Random Available Memory',
          'Read Available Memory'
        ],
        correctAnswer: 0,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.easy,
        explanation:
            'RAM stands for Random Access Memory, which provides fast access to data.',
        points: 10,
        tags: ['computers', 'hardware', 'ram'],
      ),
      QuizQuestion(
        id: 'tech_004',
        question:
            'What is the main programming language used for Android development?',
        options: ['Swift', 'Java', 'Python', 'C++'],
        correctAnswer: 1,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Java is the primary language for Android development, though Kotlin is also popular.',
        points: 15,
        tags: ['android', 'programming', 'java'],
      ),
      QuizQuestion(
        id: 'tech_005',
        question: 'What does HTML stand for?',
        options: [
          'HyperText Markup Language',
          'High Tech Modern Language',
          'Hyper Transfer Markup Language',
          'Home Tool Markup Language'
        ],
        correctAnswer: 0,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.easy,
        explanation:
            'HTML stands for HyperText Markup Language, used for creating web pages.',
        points: 10,
        tags: ['web development', 'html', 'programming'],
      ),
      QuizQuestion(
        id: 'tech_006',
        question: 'What year was the World Wide Web invented?',
        options: ['1989', '1991', '1993', '1995'],
        correctAnswer: 0,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Tim Berners-Lee invented the World Wide Web in 1989 while working at CERN.',
        points: 15,
        tags: ['internet', 'www', 'tim berners-lee'],
      ),
      QuizQuestion(
        id: 'tech_007',
        question: 'What does AI stand for?',
        options: [
          'Artificial Intelligence',
          'Advanced Internet',
          'Automated Information',
          'Artificial Internet'
        ],
        correctAnswer: 0,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.easy,
        explanation:
            'AI stands for Artificial Intelligence, the simulation of human intelligence by machines.',
        points: 10,
        tags: ['artificial intelligence', 'ai', 'technology'],
      ),
      QuizQuestion(
        id: 'tech_008',
        question: 'What is the largest social media platform in the world?',
        options: ['Facebook', 'YouTube', 'Instagram', 'TikTok'],
        correctAnswer: 1,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.medium,
        explanation:
            'YouTube is the largest social media platform with over 2.5 billion monthly active users.',
        points: 15,
        tags: ['social media', 'youtube', 'platforms'],
      ),
      QuizQuestion(
        id: 'tech_009',
        question: 'What does VPN stand for?',
        options: [
          'Virtual Private Network',
          'Virtual Public Network',
          'Verified Private Network',
          'Virtual Personal Network'
        ],
        correctAnswer: 0,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.medium,
        explanation:
            'VPN stands for Virtual Private Network, which provides secure, encrypted connections.',
        points: 15,
        tags: ['vpn', 'security', 'networking'],
      ),
      QuizQuestion(
        id: 'tech_010',
        question:
            'What is the primary programming language used for iOS development?',
        options: ['Java', 'Kotlin', 'Swift', 'Objective-C'],
        correctAnswer: 2,
        category: QuizCategory.technology,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Swift is the primary language for iOS development, introduced by Apple in 2014.',
        points: 15,
        tags: ['ios', 'swift', 'apple development'],
      ),
    ];
  }

  // Sports Questions
  List<QuizQuestion> _getSportsQuestions() {
    return [
      QuizQuestion(
        id: 'sport_001',
        question: 'Which country has won the most FIFA World Cups?',
        options: ['Germany', 'Argentina', 'Brazil', 'Italy'],
        correctAnswer: 2,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Brazil has won 5 FIFA World Cups, more than any other country.',
        points: 15,
        tags: ['football', 'fifa', 'world cup', 'brazil'],
      ),
      QuizQuestion(
        id: 'sport_002',
        question: 'How many players are on a basketball court at once?',
        options: ['8', '10', '12', '14'],
        correctAnswer: 1,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.easy,
        explanation:
            'There are 5 players from each team on the court at once, totaling 10 players.',
        points: 10,
        tags: ['basketball', 'team sports', 'players'],
      ),
      QuizQuestion(
        id: 'sport_003',
        question: 'What is the national sport of Japan?',
        options: ['Karate', 'Sumo', 'Judo', 'Baseball'],
        correctAnswer: 1,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Sumo wrestling is considered the national sport of Japan.',
        points: 10,
        tags: ['japan', 'sumo', 'national sports'],
      ),
      QuizQuestion(
        id: 'sport_004',
        question: 'How many innings are in a standard baseball game?',
        options: ['7', '8', '9', '10'],
        correctAnswer: 2,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.easy,
        explanation: 'A standard baseball game consists of 9 innings.',
        points: 10,
        tags: ['baseball', 'innings', 'rules'],
      ),
      QuizQuestion(
        id: 'sport_005',
        question: 'Which tennis player has won the most Grand Slam titles?',
        options: [
          'Roger Federer',
          'Rafael Nadal',
          'Novak Djokovic',
          'Pete Sampras'
        ],
        correctAnswer: 2,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Novak Djokovic holds the record for most Grand Slam titles in men\'s tennis.',
        points: 15,
        tags: ['tennis', 'grand slams', 'djokovic'],
      ),
      QuizQuestion(
        id: 'sport_006',
        question: 'What is the distance of a marathon?',
        options: ['26.2 miles', '13.1 miles', '39.3 miles', '52.4 miles'],
        correctAnswer: 0,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.medium,
        explanation: 'A marathon is exactly 26.2 miles (42.195 kilometers).',
        points: 15,
        tags: ['running', 'marathon', 'distance'],
      ),
      QuizQuestion(
        id: 'sport_007',
        question: 'Which country invented cricket?',
        options: ['Australia', 'India', 'England', 'South Africa'],
        correctAnswer: 2,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.medium,
        explanation: 'Cricket originated in England in the 16th century.',
        points: 15,
        tags: ['cricket', 'england', 'origins'],
      ),
      QuizQuestion(
        id: 'sport_008',
        question: 'What is the fastest land animal?',
        options: ['Cheetah', 'Lion', 'Gazelle', 'Leopard'],
        correctAnswer: 0,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.easy,
        explanation: 'The cheetah can reach speeds up to 70 mph (113 km/h).',
        points: 10,
        tags: ['animals', 'speed', 'cheetah'],
      ),
      QuizQuestion(
        id: 'sport_009',
        question: 'How many players are on a soccer team during a match?',
        options: ['9', '10', '11', '12'],
        correctAnswer: 2,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Each soccer team has 11 players on the field during a match.',
        points: 10,
        tags: ['soccer', 'football', 'team size'],
      ),
      QuizQuestion(
        id: 'sport_010',
        question: 'Which Olympic sport involves throwing a heavy metal ball?',
        options: ['Shot Put', 'Discus', 'Hammer Throw', 'Javelin'],
        correctAnswer: 0,
        category: QuizCategory.sports,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Shot put involves throwing a heavy metal ball as far as possible.',
        points: 15,
        tags: ['olympics', 'track and field', 'shot put'],
      ),
    ];
  }

  // Entertainment Questions
  List<QuizQuestion> _getEntertainmentQuestions() {
    return [
      QuizQuestion(
        id: 'ent_001',
        question: 'Who played Iron Man in the Marvel Cinematic Universe?',
        options: [
          'Chris Evans',
          'Robert Downey Jr.',
          'Chris Hemsworth',
          'Mark Ruffalo'
        ],
        correctAnswer: 1,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.easy,
        explanation: 'Robert Downey Jr. played Tony Stark/Iron Man in the MCU.',
        points: 10,
        tags: ['marvel', 'iron man', 'robert downey jr'],
      ),
      QuizQuestion(
        id: 'ent_002',
        question: 'What year did "The Lion King" animated movie premiere?',
        options: ['1992', '1994', '1996', '1998'],
        correctAnswer: 1,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.medium,
        explanation: 'The animated "Lion King" was released by Disney in 1994.',
        points: 15,
        tags: ['disney', 'animation', 'movies'],
      ),
      QuizQuestion(
        id: 'ent_003',
        question: 'Which band released "Bohemian Rhapsody"?',
        options: ['The Beatles', 'Queen', 'Led Zeppelin', 'Pink Floyd'],
        correctAnswer: 1,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.easy,
        explanation: 'Queen released "Bohemian Rhapsody" in 1975.',
        points: 10,
        tags: ['queen', 'music', 'bohemian rhapsody'],
      ),
      QuizQuestion(
        id: 'ent_004',
        question: 'What is the highest-grossing movie of all time?',
        options: [
          'Avatar',
          'Avengers: Endgame',
          'Titanic',
          'Star Wars: The Force Awakens'
        ],
        correctAnswer: 0,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.medium,
        explanation: 'Avatar (2009) is the highest-grossing movie of all time.',
        points: 15,
        tags: ['movies', 'box office', 'avatar'],
      ),
      QuizQuestion(
        id: 'ent_005',
        question: 'Who directed "The Godfather"?',
        options: [
          'Martin Scorsese',
          'Francis Ford Coppola',
          'Steven Spielberg',
          'Quentin Tarantino'
        ],
        correctAnswer: 1,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.medium,
        explanation: 'Francis Ford Coppola directed "The Godfather" in 1972.',
        points: 15,
        tags: ['movies', 'directors', 'coppola'],
      ),
      QuizQuestion(
        id: 'ent_006',
        question:
            'Which TV show features dragons and is based on George R.R. Martin\'s books?',
        options: [
          'The Walking Dead',
          'Breaking Bad',
          'Game of Thrones',
          'Stranger Things'
        ],
        correctAnswer: 2,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Game of Thrones is based on "A Song of Ice and Fire" by George R.R. Martin.',
        points: 10,
        tags: ['tv shows', 'game of thrones', 'fantasy'],
      ),
      QuizQuestion(
        id: 'ent_007',
        question: 'What year did the first Star Wars movie premiere?',
        options: ['1975', '1977', '1979', '1981'],
        correctAnswer: 1,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.medium,
        explanation: 'Star Wars: A New Hope was released in 1977.',
        points: 15,
        tags: ['star wars', 'movies', '1977'],
      ),
      QuizQuestion(
        id: 'ent_008',
        question: 'Which artist released the album "Thriller"?',
        options: ['Prince', 'Michael Jackson', 'Madonna', 'Whitney Houston'],
        correctAnswer: 1,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.easy,
        explanation: 'Michael Jackson released "Thriller" in 1982.',
        points: 10,
        tags: ['michael jackson', 'music', 'thriller'],
      ),
      QuizQuestion(
        id: 'ent_009',
        question: 'What is the longest-running animated TV show?',
        options: [
          'The Simpsons',
          'South Park',
          'Family Guy',
          'SpongeBob SquarePants'
        ],
        correctAnswer: 0,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The Simpsons has been running since 1989, making it the longest-running animated show.',
        points: 20,
        tags: ['tv shows', 'the simpsons', 'animation'],
      ),
      QuizQuestion(
        id: 'ent_010',
        question: 'Which movie won the Academy Award for Best Picture in 2020?',
        options: ['Parasite', 'Joker', '1917', 'Once Upon a Time in Hollywood'],
        correctAnswer: 0,
        category: QuizCategory.entertainment,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Parasite became the first foreign-language film to win Best Picture at the Oscars.',
        points: 20,
        tags: ['oscars', 'best picture', 'parasite'],
      ),
    ];
  }

  // Health Questions
  List<QuizQuestion> _getHealthQuestions() {
    return [
      QuizQuestion(
        id: 'health_001',
        question: 'How many bones are in the adult human body?',
        options: ['156', '206', '256', '306'],
        correctAnswer: 1,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.medium,
        explanation: 'An adult human has 206 bones in their body.',
        points: 15,
        tags: ['anatomy', 'bones', 'human body'],
      ),
      QuizQuestion(
        id: 'health_002',
        question: 'What is the main function of the heart?',
        options: ['Digestion', 'Pumping blood', 'Breathing', 'Thinking'],
        correctAnswer: 1,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The heart\'s main function is to pump blood throughout the body.',
        points: 10,
        tags: ['heart', 'circulatory system', 'organs'],
      ),
      QuizQuestion(
        id: 'health_003',
        question: 'What is the largest organ in the human body?',
        options: ['Heart', 'Liver', 'Brain', 'Skin'],
        correctAnswer: 3,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The skin is the largest organ, covering about 20 square feet.',
        points: 10,
        tags: ['anatomy', 'skin', 'organs'],
      ),
      QuizQuestion(
        id: 'health_004',
        question: 'How many chambers does the human heart have?',
        options: ['2', '3', '4', '5'],
        correctAnswer: 2,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The human heart has 4 chambers: 2 atria and 2 ventricles.',
        points: 10,
        tags: ['heart', 'anatomy', 'chambers'],
      ),
      QuizQuestion(
        id: 'health_005',
        question: 'What vitamin is produced when skin is exposed to sunlight?',
        options: ['Vitamin A', 'Vitamin C', 'Vitamin D', 'Vitamin E'],
        correctAnswer: 2,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Vitamin D is produced when skin is exposed to UVB sunlight.',
        points: 15,
        tags: ['vitamins', 'sunlight', 'vitamin d'],
      ),
      QuizQuestion(
        id: 'health_006',
        question: 'What is the normal body temperature in Celsius?',
        options: ['35°C', '36°C', '37°C', '38°C'],
        correctAnswer: 2,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Normal human body temperature is approximately 37°C (98.6°F).',
        points: 15,
        tags: ['body temperature', 'physiology', 'normal range'],
      ),
      QuizQuestion(
        id: 'health_007',
        question: 'How many teeth does an adult typically have?',
        options: ['28', '30', '32', '34'],
        correctAnswer: 2,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.medium,
        explanation: 'Adults typically have 32 teeth, including wisdom teeth.',
        points: 15,
        tags: ['teeth', 'dental', 'anatomy'],
      ),
      QuizQuestion(
        id: 'health_008',
        question: 'What is the main function of red blood cells?',
        options: [
          'Fight infection',
          'Carry oxygen',
          'Form blood clots',
          'Produce antibodies'
        ],
        correctAnswer: 1,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Red blood cells carry oxygen from the lungs to the body tissues.',
        points: 15,
        tags: ['blood', 'red blood cells', 'oxygen'],
      ),
      QuizQuestion(
        id: 'health_009',
        question: 'What is the average lifespan of a red blood cell?',
        options: ['30 days', '60 days', '90 days', '120 days'],
        correctAnswer: 3,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Red blood cells live for about 120 days before being replaced.',
        points: 20,
        tags: ['blood', 'red blood cells', 'lifespan'],
      ),
      QuizQuestion(
        id: 'health_010',
        question: 'What percentage of the human body is water?',
        options: ['45-50%', '55-60%', '65-70%', '75-80%'],
        correctAnswer: 1,
        category: QuizCategory.health,
        difficulty: QuizDifficulty.hard,
        explanation: 'Water makes up about 55-60% of the adult human body.',
        points: 20,
        tags: ['water', 'body composition', 'physiology'],
      ),
    ];
  }

  // Environment Questions
  List<QuizQuestion> _getEnvironmentQuestions() {
    return [
      QuizQuestion(
        id: 'env_001',
        question: 'What gas do plants absorb from the atmosphere?',
        options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
        correctAnswer: 1,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Plants absorb carbon dioxide (CO2) during photosynthesis.',
        points: 10,
        tags: ['plants', 'photosynthesis', 'carbon dioxide'],
      ),
      QuizQuestion(
        id: 'env_002',
        question: 'What is the main cause of global warming?',
        options: [
          'Volcanic eruptions',
          'Greenhouse gases',
          'Solar flares',
          'Ocean currents'
        ],
        correctAnswer: 1,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Greenhouse gases trap heat in the atmosphere, causing global warming.',
        points: 15,
        tags: ['global warming', 'climate change', 'greenhouse gases'],
      ),
      QuizQuestion(
        id: 'env_003',
        question: 'What is the largest rainforest in the world?',
        options: [
          'Congo Rainforest',
          'Amazon Rainforest',
          'Borneo Rainforest',
          'Daintree Rainforest'
        ],
        correctAnswer: 1,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.easy,
        explanation:
            'The Amazon Rainforest is the largest rainforest in the world.',
        points: 10,
        tags: ['rainforests', 'amazon', 'ecosystems'],
      ),
      QuizQuestion(
        id: 'env_004',
        question: 'What percentage of Earth\'s surface is covered by water?',
        options: ['50%', '60%', '70%', '80%'],
        correctAnswer: 2,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.easy,
        explanation: 'About 70% of Earth\'s surface is covered by water.',
        points: 10,
        tags: ['earth', 'water', 'oceans'],
      ),
      QuizQuestion(
        id: 'env_005',
        question: 'What is the ozone layer made of?',
        options: ['Oxygen', 'Ozone (O₃)', 'Carbon dioxide', 'Nitrogen'],
        correctAnswer: 1,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.medium,
        explanation: 'The ozone layer is made of ozone molecules (O₃).',
        points: 15,
        tags: ['ozone', 'atmosphere', 'protection'],
      ),
      QuizQuestion(
        id: 'env_006',
        question:
            'What is the process called when water changes from liquid to gas?',
        options: [
          'Condensation',
          'Evaporation',
          'Precipitation',
          'Sublimation'
        ],
        correctAnswer: 1,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Evaporation is the process of water changing from liquid to gas.',
        points: 15,
        tags: ['water cycle', 'evaporation', 'states of matter'],
      ),
      QuizQuestion(
        id: 'env_007',
        question: 'What is the main component of natural gas?',
        options: ['Methane', 'Ethane', 'Propane', 'Butane'],
        correctAnswer: 0,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.medium,
        explanation: 'Methane (CH₄) is the main component of natural gas.',
        points: 15,
        tags: ['natural gas', 'methane', 'fossil fuels'],
      ),
      QuizQuestion(
        id: 'env_008',
        question: 'What is the term for the variety of life on Earth?',
        options: ['Ecosystem', 'Biome', 'Biodiversity', 'Habitat'],
        correctAnswer: 2,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.medium,
        explanation: 'Biodiversity refers to the variety of life on Earth.',
        points: 15,
        tags: ['biodiversity', 'ecology', 'life'],
      ),
      QuizQuestion(
        id: 'env_009',
        question: 'What is the main greenhouse gas?',
        options: [
          'Carbon dioxide (CO₂)',
          'Methane (CH₄)',
          'Nitrous oxide (N₂O)',
          'Water vapor (H₂O)'
        ],
        correctAnswer: 0,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Carbon dioxide (CO₂) is the main greenhouse gas contributing to climate change.',
        points: 20,
        tags: ['greenhouse gases', 'carbon dioxide', 'climate change'],
      ),
      QuizQuestion(
        id: 'env_010',
        question:
            'What is the process of converting waste into reusable material called?',
        options: ['Composting', 'Recycling', 'Landfilling', 'Incineration'],
        correctAnswer: 1,
        category: QuizCategory.environment,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Recycling is the process of converting waste into reusable material.',
        points: 20,
        tags: ['recycling', 'waste management', 'sustainability'],
      ),
    ];
  }

  // Economics Questions
  List<QuizQuestion> _getEconomicsQuestions() {
    return [
      QuizQuestion(
        id: 'econ_001',
        question: 'What does GDP stand for?',
        options: [
          'Gross Domestic Product',
          'Global Development Plan',
          'General Development Process',
          'Gross Development Plan'
        ],
        correctAnswer: 0,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'GDP stands for Gross Domestic Product, the total value of goods and services produced.',
        points: 15,
        tags: ['economics', 'gdp', 'macroeconomics'],
      ),
      QuizQuestion(
        id: 'econ_002',
        question: 'What is inflation?',
        options: [
          'Increase in prices',
          'Decrease in prices',
          'Increase in employment',
          'Decrease in employment'
        ],
        correctAnswer: 0,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Inflation is a general increase in prices and fall in the purchasing value of money.',
        points: 10,
        tags: ['inflation', 'economics', 'prices'],
      ),
      QuizQuestion(
        id: 'econ_003',
        question: 'What is the opposite of inflation?',
        options: ['Recession', 'Deflation', 'Depression', 'Stagnation'],
        correctAnswer: 1,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Deflation is a decrease in the general price level of goods and services.',
        points: 10,
        tags: ['deflation', 'economics', 'prices'],
      ),
      QuizQuestion(
        id: 'econ_004',
        question: 'What is a monopoly?',
        options: [
          'A market with many sellers',
          'A market with one seller',
          'A market with two sellers',
          'A market with no sellers'
        ],
        correctAnswer: 1,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'A monopoly is a market structure with only one seller of a product.',
        points: 15,
        tags: ['monopoly', 'market structure', 'economics'],
      ),
      QuizQuestion(
        id: 'econ_005',
        question: 'What is the law of supply and demand?',
        options: [
          'Prices always increase',
          'Prices always decrease',
          'Prices adjust to balance supply and demand',
          'Supply always equals demand'
        ],
        correctAnswer: 2,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Prices adjust to balance the quantity supplied and quantity demanded.',
        points: 15,
        tags: ['supply and demand', 'market forces', 'economics'],
      ),
      QuizQuestion(
        id: 'econ_006',
        question: 'What is a recession?',
        options: [
          'A period of economic growth',
          'A period of economic decline',
          'A period of stable prices',
          'A period of high inflation'
        ],
        correctAnswer: 1,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'A recession is a period of economic decline, typically marked by falling GDP.',
        points: 15,
        tags: ['recession', 'economic cycles', 'gdp'],
      ),
      QuizQuestion(
        id: 'econ_007',
        question: 'What is the primary function of a central bank?',
        options: [
          'To make profits',
          'To control the money supply',
          'To lend to individuals',
          'To collect taxes'
        ],
        correctAnswer: 1,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Central banks control the money supply and interest rates in an economy.',
        points: 15,
        tags: ['central bank', 'monetary policy', 'economics'],
      ),
      QuizQuestion(
        id: 'econ_008',
        question: 'What is opportunity cost?',
        options: [
          'The cost of production',
          'The value of the next best alternative',
          'The total cost of a decision',
          'The fixed cost of a business'
        ],
        correctAnswer: 1,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Opportunity cost is the value of the next best alternative that is foregone.',
        points: 20,
        tags: ['opportunity cost', 'decision making', 'economics'],
      ),
      QuizQuestion(
        id: 'econ_009',
        question: 'What is the Phillips Curve?',
        options: [
          'A relationship between inflation and unemployment',
          'A relationship between supply and demand',
          'A relationship between GDP and interest rates',
          'A relationship between exports and imports'
        ],
        correctAnswer: 0,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The Phillips Curve shows the inverse relationship between inflation and unemployment.',
        points: 20,
        tags: ['phillips curve', 'inflation', 'unemployment'],
      ),
      QuizQuestion(
        id: 'econ_010',
        question: 'What is the Laffer Curve?',
        options: [
          'A relationship between tax rates and tax revenue',
          'A relationship between interest rates and investment',
          'A relationship between wages and productivity',
          'A relationship between inflation and money supply'
        ],
        correctAnswer: 0,
        category: QuizCategory.economics,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The Laffer Curve illustrates the relationship between tax rates and tax revenue.',
        points: 20,
        tags: ['laffer curve', 'taxation', 'economics'],
      ),
    ];
  }

  // Politics Questions
  List<QuizQuestion> _getPoliticsQuestions() {
    return [
      QuizQuestion(
        id: 'pol_001',
        question: 'What is democracy?',
        options: [
          'Rule by one person',
          'Rule by the people',
          'Rule by the military',
          'Rule by the wealthy'
        ],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Democracy is a system of government where power comes from the people.',
        points: 10,
        tags: ['democracy', 'government', 'political systems'],
      ),
      QuizQuestion(
        id: 'pol_002',
        question: 'What are the three branches of US government?',
        options: [
          'Executive, Legislative, Judicial',
          'Federal, State, Local',
          'House, Senate, President',
          'Congress, Supreme Court, President'
        ],
        correctAnswer: 0,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The US government has three branches: Executive (President), Legislative (Congress), and Judicial (Courts).',
        points: 15,
        tags: ['us government', 'branches', 'constitution'],
      ),
      QuizQuestion(
        id: 'pol_003',
        question: 'What is a monarchy?',
        options: [
          'Rule by the people',
          'Rule by one person (king/queen)',
          'Rule by the military',
          'Rule by religious leaders'
        ],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.easy,
        explanation:
            'A monarchy is a form of government where a single person (monarch) rules.',
        points: 10,
        tags: ['monarchy', 'government', 'political systems'],
      ),
      QuizQuestion(
        id: 'pol_004',
        question: 'What is the capital of the United States?',
        options: ['New York', 'Los Angeles', 'Washington D.C.', 'Chicago'],
        correctAnswer: 2,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.easy,
        explanation: 'Washington D.C. is the capital of the United States.',
        points: 10,
        tags: ['us capital', 'washington dc', 'government'],
      ),
      QuizQuestion(
        id: 'pol_005',
        question: 'What is the main function of the United Nations?',
        options: [
          'To make laws',
          'To maintain international peace and security',
          'To collect taxes',
          'To control world trade'
        ],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The UN\'s main purpose is to maintain international peace and security.',
        points: 15,
        tags: ['united nations', 'international relations', 'peace'],
      ),
      QuizQuestion(
        id: 'pol_006',
        question: 'What is the electoral college?',
        options: [
          'A college for politicians',
          'A system for electing the US President',
          'A voting machine',
          'A political party'
        ],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'The electoral college is the system used to elect the US President.',
        points: 15,
        tags: ['electoral college', 'us elections', 'presidency'],
      ),
      QuizQuestion(
        id: 'pol_007',
        question: 'What is the term for a government by the wealthy?',
        options: ['Democracy', 'Oligarchy', 'Plutocracy', 'Aristocracy'],
        correctAnswer: 2,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.hard,
        explanation:
            'Plutocracy is a form of government where the wealthy rule.',
        points: 20,
        tags: ['plutocracy', 'government types', 'wealth'],
      ),
      QuizQuestion(
        id: 'pol_008',
        question: 'What is the Magna Carta?',
        options: [
          'A modern constitution',
          'A medieval document limiting royal power',
          'A peace treaty',
          'A trade agreement'
        ],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The Magna Carta (1215) was a medieval document that limited royal power in England.',
        points: 20,
        tags: ['magna carta', 'medieval history', 'constitutional law'],
      ),
      QuizQuestion(
        id: 'pol_009',
        question:
            'What is the term for a government with no central authority?',
        options: ['Democracy', 'Anarchy', 'Dictatorship', 'Republic'],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.hard,
        explanation: 'Anarchy is a state of society without government or law.',
        points: 20,
        tags: ['anarchy', 'government types', 'political theory'],
      ),
      QuizQuestion(
        id: 'pol_010',
        question: 'What is the primary purpose of political parties?',
        options: [
          'To collect taxes',
          'To organize and represent political views',
          'To enforce laws',
          'To appoint judges'
        ],
        correctAnswer: 1,
        category: QuizCategory.politics,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Political parties organize and represent different political views and interests.',
        points: 15,
        tags: ['political parties', 'democracy', 'representation'],
      ),
    ];
  }

  // Art Questions
  List<QuizQuestion> _getArtQuestions() {
    return [
      QuizQuestion(
        id: 'art_001',
        question: 'Who painted "The Starry Night"?',
        options: [
          'Pablo Picasso',
          'Vincent van Gogh',
          'Claude Monet',
          'Salvador Dalí'
        ],
        correctAnswer: 1,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.medium,
        explanation: 'Vincent van Gogh painted "The Starry Night" in 1889.',
        points: 15,
        tags: ['van gogh', 'post-impressionism', 'paintings'],
      ),
      QuizQuestion(
        id: 'art_002',
        question: 'What art movement was Pablo Picasso associated with?',
        options: ['Impressionism', 'Cubism', 'Surrealism', 'Expressionism'],
        correctAnswer: 1,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Pablo Picasso was a co-founder of Cubism, along with Georges Braque.',
        points: 15,
        tags: ['picasso', 'cubism', 'modern art'],
      ),
      QuizQuestion(
        id: 'art_003',
        question: 'Who painted the "Mona Lisa"?',
        options: ['Leonardo da Vinci', 'Michelangelo', 'Raphael', 'Donatello'],
        correctAnswer: 0,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Leonardo da Vinci painted the "Mona Lisa" between 1503-1519.',
        points: 10,
        tags: ['leonardo da vinci', 'renaissance', 'mona lisa'],
      ),
      QuizQuestion(
        id: 'art_004',
        question: 'What is the technique of painting on wet plaster called?',
        options: ['Fresco', 'Tempera', 'Oil painting', 'Watercolor'],
        correctAnswer: 0,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Fresco is a technique where paint is applied to wet plaster.',
        points: 15,
        tags: ['fresco', 'painting techniques', 'wall art'],
      ),
      QuizQuestion(
        id: 'art_005',
        question: 'Which artist is known for cutting off his own ear?',
        options: [
          'Vincent van Gogh',
          'Paul Gauguin',
          'Henri Toulouse-Lautrec',
          'Edvard Munch'
        ],
        correctAnswer: 0,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Vincent van Gogh famously cut off part of his left ear in 1888.',
        points: 10,
        tags: ['van gogh', 'art history', 'famous artists'],
      ),
      QuizQuestion(
        id: 'art_006',
        question: 'What is the primary color that is NOT a primary color?',
        options: ['Red', 'Blue', 'Green', 'Yellow'],
        correctAnswer: 2,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Green is a secondary color, while red, blue, and yellow are primary colors.',
        points: 15,
        tags: ['color theory', 'primary colors', 'art fundamentals'],
      ),
      QuizQuestion(
        id: 'art_007',
        question: 'Who created the sculpture "David"?',
        options: ['Leonardo da Vinci', 'Michelangelo', 'Donatello', 'Bernini'],
        correctAnswer: 1,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Michelangelo created the famous "David" sculpture between 1501-1504.',
        points: 15,
        tags: ['michelangelo', 'sculpture', 'renaissance'],
      ),
      QuizQuestion(
        id: 'art_008',
        question: 'What art style is characterized by dreamlike imagery?',
        options: ['Realism', 'Surrealism', 'Impressionism', 'Expressionism'],
        correctAnswer: 1,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Surrealism is characterized by dreamlike, fantastical imagery.',
        points: 15,
        tags: ['surrealism', 'dream art', 'modern art'],
      ),
      QuizQuestion(
        id: 'art_009',
        question: 'Which museum houses the "Venus de Milo"?',
        options: [
          'British Museum',
          'Louvre Museum',
          'Vatican Museums',
          'Uffizi Gallery'
        ],
        correctAnswer: 1,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The "Venus de Milo" is displayed at the Louvre Museum in Paris.',
        points: 20,
        tags: ['louvre', 'ancient greece', 'sculpture'],
      ),
      QuizQuestion(
        id: 'art_010',
        question: 'What is the art of paper folding called?',
        options: ['Origami', 'Kirigami', 'Quilling', 'Decoupage'],
        correctAnswer: 0,
        category: QuizCategory.art,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Origami is the Japanese art of paper folding without cutting.',
        points: 10,
        tags: ['origami', 'japanese art', 'paper crafts'],
      ),
    ];
  }

  // Music Questions
  List<QuizQuestion> _getMusicQuestions() {
    return [
      QuizQuestion(
        id: 'music_001',
        question: 'How many strings does a standard guitar have?',
        options: ['4', '5', '6', '7'],
        correctAnswer: 2,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.easy,
        explanation: 'A standard guitar has 6 strings.',
        points: 10,
        tags: ['guitar', 'instruments', 'strings'],
      ),
      QuizQuestion(
        id: 'music_002',
        question: 'What is the highest female singing voice?',
        options: ['Alto', 'Mezzo-soprano', 'Soprano', 'Contralto'],
        correctAnswer: 2,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.medium,
        explanation: 'Soprano is the highest female singing voice.',
        points: 15,
        tags: ['singing', 'voice types', 'music'],
      ),
      QuizQuestion(
        id: 'music_003',
        question: 'What is the main instrument in a piano trio?',
        options: ['Piano', 'Violin', 'Cello', 'All three equally'],
        correctAnswer: 0,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.medium,
        explanation:
            'A piano trio consists of piano, violin, and cello, with piano as the main instrument.',
        points: 15,
        tags: ['classical music', 'piano trio', 'chamber music'],
      ),
      QuizQuestion(
        id: 'music_004',
        question: 'How many keys does a standard piano have?',
        options: ['76', '88', '92', '96'],
        correctAnswer: 1,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.easy,
        explanation: 'A standard piano has 88 keys (52 white and 36 black).',
        points: 10,
        tags: ['piano', 'instruments', 'keys'],
      ),
      QuizQuestion(
        id: 'music_005',
        question: 'What is the time signature for a waltz?',
        options: ['2/4', '3/4', '4/4', '6/8'],
        correctAnswer: 1,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.medium,
        explanation:
            'A waltz is typically in 3/4 time, giving it a "one-two-three" feel.',
        points: 15,
        tags: ['waltz', 'time signature', 'dance music'],
      ),
      QuizQuestion(
        id: 'music_006',
        question: 'What is the main instrument in jazz music?',
        options: ['Saxophone', 'Trumpet', 'Piano', 'All of the above'],
        correctAnswer: 3,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.easy,
        explanation:
            'Jazz music features many instruments, with saxophone, trumpet, and piano all being prominent.',
        points: 10,
        tags: ['jazz', 'instruments', 'music genres'],
      ),
      QuizQuestion(
        id: 'music_007',
        question: 'Who composed "Symphony No. 9"?',
        options: [
          'Wolfgang Amadeus Mozart',
          'Ludwig van Beethoven',
          'Johann Sebastian Bach',
          'Franz Schubert'
        ],
        correctAnswer: 1,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.medium,
        explanation:
            'Beethoven composed "Symphony No. 9" (the "Choral Symphony") in 1824.',
        points: 15,
        tags: ['beethoven', 'classical music', 'symphony'],
      ),
      QuizQuestion(
        id: 'music_008',
        question: 'What is a group of four musicians called?',
        options: ['Trio', 'Quartet', 'Quintet', 'Sextet'],
        correctAnswer: 1,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.easy,
        explanation: 'A quartet is a group of four musicians or singers.',
        points: 10,
        tags: ['musical groups', 'ensemble', 'music terms'],
      ),
      QuizQuestion(
        id: 'music_009',
        question: 'What is the Italian term for "loud" in music?',
        options: ['Piano', 'Forte', 'Mezzo', 'Adagio'],
        correctAnswer: 1,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.medium,
        explanation: '"Forte" means loud in Italian musical notation.',
        points: 15,
        tags: ['musical terms', 'dynamics', 'italian music'],
      ),
      QuizQuestion(
        id: 'music_010',
        question: 'Which instrument is known as the "king of instruments"?',
        options: ['Piano', 'Violin', 'Organ', 'Trumpet'],
        correctAnswer: 2,
        category: QuizCategory.music,
        difficulty: QuizDifficulty.hard,
        explanation:
            'The pipe organ is often called the "king of instruments" due to its size and complexity.',
        points: 20,
        tags: ['organ', 'classical music', 'instruments'],
      ),
    ];
  }

  // Enhanced methods for better question management

  // Get questions by difficulty level only
  List<QuizQuestion> getQuestionsByDifficulty(QuizDifficulty difficulty,
      {int limit = 15}) {
    final questions =
        _getAllQuestions().where((q) => q.difficulty == difficulty).toList();

    questions.shuffle();
    return questions.take(limit).toList();
  }

  // Get questions by category only
  List<QuizQuestion> getQuestionsByCategory(QuizCategory category,
      {int limit = 15}) {
    final questions =
        _getAllQuestions().where((q) => q.category == category).toList();

    questions.shuffle();
    return questions.take(limit).toList();
  }

  // Get questions by tags
  List<QuizQuestion> getQuestionsByTags(List<String> tags, {int limit = 10}) {
    final questions = _getAllQuestions()
        .where((q) => q.tags.any((tag) => tags.contains(tag)))
        .toList();

    questions.shuffle();
    return questions.take(limit).toList();
  }

  // Get total question count
  int getTotalQuestionCount() {
    return _getAllQuestions().length;
  }

  // Get question count by category
  int getQuestionCountByCategory(QuizCategory category) {
    return _getAllQuestions().where((q) => q.category == category).length;
  }

  // Get question count by difficulty
  int getQuestionCountByDifficulty(QuizDifficulty difficulty) {
    return _getAllQuestions().where((q) => q.difficulty == difficulty).length;
  }

  // Get available tags
  List<String> getAvailableTags() {
    final allTags = <String>{};
    for (final question in _getAllQuestions()) {
      allTags.addAll(question.tags);
    }
    return allTags.toList()..sort();
  }
}
