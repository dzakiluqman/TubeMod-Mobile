class KeywordRepository {
  // Pindahkan data list dari screen kemarin ke sini agar bisa diakses bersama
  static final List<Map<String, String>> _keywords = [
    {'keyword': 'judol', 'category': 'spam'},
    {'keyword': 'slot gacor', 'category': 'gambling'},
    {'keyword': 'bodoh', 'category': 'hate'},
    {'keyword': 'anjing', 'category': 'hate'},
    {'keyword': 'klik link ini', 'category': 'spam'},
    {'keyword': 'scam', 'category': 'fraud'},
  ];

  static List<Map<String, String>> get keywords => _keywords;

  static int get count => _keywords.length;

  static void add(String keyword, String category) {
    _keywords.add({'keyword': keyword, 'category': category});
  }

  static void removeAt(int index) {
    _keywords.removeAt(index);
  }

  static void updateAt(int index, String keyword, String category) {
    _keywords[index] = {'keyword': keyword, 'category': category};
  }
}