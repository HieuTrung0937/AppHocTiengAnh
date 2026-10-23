/// Từ điển tiếng Anh tích hợp sẵn (Hardcoded)
/// Nguồn: SGK Global Success + Từ vựng thông dụng THPT
class BuiltinDictionary {
  /// Danh sách từ vựng mặc định
  static const List<Map<String, dynamic>> words = [
    // Lớp 10 - Unit 1: Family Life
    {'id': 'dict_001', 'word': 'responsibility', 'phonetic': '/rɪˌspɒn.səˈbɪl.ə.ti/', 'meaning': 'trách nhiệm', 'partOfSpeech': 'danh từ', 'example': 'Parents have responsibility for their children.', 'difficulty': 3},
    {'id': 'dict_002', 'word': 'household chore', 'phonetic': '/ˈhaʊs.həʊld tʃɔːr/', 'meaning': 'việc nhà', 'partOfSpeech': 'danh từ', 'example': 'We share household chores equally.', 'difficulty': 2},
    {'id': 'dict_003', 'word': 'bond', 'phonetic': '/bɒnd/', 'meaning': 'sự gắn kết', 'partOfSpeech': 'danh từ', 'example': 'Family bonds are very important.', 'difficulty': 3},
    
    // Lớp 10 - Unit 2: Humans and the Environment
    {'id': 'dict_004', 'word': 'deforestation', 'phonetic': '/diːˌfɒr.ɪsteɪ.ʃən/', 'meaning': 'nạn phá rừng', 'partOfSpeech': 'danh từ', 'example': 'Deforestation causes climate change.', 'difficulty': 4},
    {'id': 'dict_005', 'word': 'endangered species', 'phonetic': '/ɪnˈdeɪn.dʒəd ˈspiː.ʃiːz/', 'meaning': 'loài nguy cấp', 'partOfSpeech': 'danh từ', 'example': 'Tigers are endangered species.', 'difficulty': 4},
    {'id': 'dict_006', 'word': 'carbon footprint', 'phonetic': '/ˈkɑː.bən ˈfʊt.prɪnt/', 'meaning': 'dấu chân carbon', 'partOfSpeech': 'danh từ', 'example': 'Reduce your carbon footprint by recycling.', 'difficulty': 4},
    
    // Lớp 11 - Unit 1: The Generation Gap
    {'id': 'dict_007', 'word': 'generation gap', 'phonetic': '/dʒen.əˈreɪ.ʃən ˈɡæp/', 'meaning': 'khoảng cách thế hệ', 'partOfSpeech': 'danh từ', 'example': 'The generation gap causes misunderstandings.', 'difficulty': 3},
    {'id': 'dict_008', 'word': 'conflict', 'phonetic': '/ˈkɒn.flɪkt/', 'meaning': 'xung đột', 'partOfSpeech': 'danh từ', 'example': 'There is conflict between parents and teens.', 'difficulty': 3},
    {'id': 'dict_009', 'word': 'perspective', 'phonetic': '/pəˈspek.tɪv/', 'meaning': 'góc nhìn', 'partOfSpeech': 'danh từ', 'example': 'Try to see things from their perspective.', 'difficulty': 4},
    
    // Lớp 11 - Unit 2: Relationships
    {'id': 'dict_010', 'word': 'romantic relationship', 'phonetic': '/rəʊˈmæn.tɪk rɪˈleɪ.ʃən.ʃɪp/', 'meaning': 'mối quan hệ lãng mạn', 'partOfSpeech': 'danh từ', 'example': 'They have a romantic relationship.', 'difficulty': 3},
    {'id': 'dict_011', 'word': 'maintain', 'phonetic': '/meɪnˈteɪn/', 'meaning': 'duy trì', 'partOfSpeech': 'động từ', 'example': 'It takes effort to maintain a friendship.', 'difficulty': 3},
    {'id': 'dict_012', 'word': 'trustworthy', 'phonetic': '/ˈtrʌst.wɜː.ði/', 'meaning': 'đáng tin cậy', 'partOfSpeech': 'tính từ', 'example': 'A good friend should be trustworthy.', 'difficulty': 3},
    
    // Lớp 12 - Unit 1: Life Stories
    {'id': 'dict_013', 'word': 'achievement', 'phonetic': '/əˈtʃiːv.mənt/', 'meaning': 'thành tựu', 'partOfSpeech': 'danh từ', 'example': 'Winning the prize was her greatest achievement.', 'difficulty': 3},
    {'id': 'dict_014', 'word': 'adversity', 'phonetic': '/ədˈvɜː.sə.ti/', 'meaning': 'nghịch cảnh', 'partOfSpeech': 'danh từ', 'example': 'He succeeded despite adversity.', 'difficulty': 5},
    {'id': 'dict_015', 'word': 'inspire', 'phonetic': '/ɪnˈspaɪər/', 'meaning': 'truyền cảm hứng', 'partOfSpeech': 'động từ', 'example': 'Her story inspired many people.', 'difficulty': 3},
    
    // Từ vựng bổ sung thông dụng
    {'id': 'dict_016', 'word': 'environment', 'phonetic': '/ɪnˈvaɪ.rən.mənt/', 'meaning': 'môi trường', 'partOfSpeech': 'danh từ', 'example': 'Protect the environment for future generations.', 'difficulty': 2},
    {'id': 'dict_017', 'word': 'sustainable', 'phonetic': '/səsteɪ.nə.bəl/', 'meaning': 'bền vững', 'partOfSpeech': 'tính từ', 'example': 'We need sustainable development.', 'difficulty': 4},
    {'id': 'dict_018', 'word': 'recycle', 'phonetic': '/riːˈsaɪ.kəl/', 'meaning': 'tái chế', 'partOfSpeech': 'động từ', 'example': 'Recycle paper and plastic bottles.', 'difficulty': 2},
    {'id': 'dict_019', 'word': 'pollution', 'phonetic': '/pəˈluː.ʃən/', 'meaning': 'ô nhiễm', 'partOfSpeech': 'danh từ', 'example': 'Air pollution is a serious problem.', 'difficulty': 2},
    {'id': 'dict_020', 'word': 'ecosystem', 'phonetic': '/iː.kəʊsɪs.təm/', 'meaning': 'hệ sinh thái', 'partOfSpeech': 'danh từ', 'example': 'Coral reefs are important ecosystems.', 'difficulty': 4},
  ];
}
