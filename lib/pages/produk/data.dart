import 'package:flutter/material.dart';
import 'package:tes_android/widgets/toast.dart';
import 'package:tes_android/core/database/db_helper.dart';

class Data extends StatefulWidget {
  const Data({super.key});

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  List<Map<String, dynamic>> _allSongs = [];
  List<Map<String, dynamic>> _filteredSongs = [];
  String _selectedGenre = 'Semua';
  String _searchQuery = '';
  String _sortBy = 'Judul';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  // fungsi mengambil data lagu dari db
  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    final db = await DBHelper.instance.database;
    _allSongs = await db.query('songs');
    _filterAndSortSongs();
    setState(() => _isLoading = false);
  }

  // fungsi filter dan urutkan data lagu
  void _filterAndSortSongs() {
    setState(() {
      _filteredSongs = _allSongs.where((song) {
        bool matchesGenre =
            _selectedGenre == 'Semua' || song['genre'] == _selectedGenre;
        bool matchesSearch = song['title'].toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        return matchesGenre && matchesSearch;
      }).toList();
      _sortSongs();
    });
  }

  // fungsi mengurutkan data lagu berdasarkan judul atau penyanyi
  void _sortSongs() {
    if (_sortBy == 'Judul') {
      _filteredSongs.sort(
        (a, b) => a['title'].toString().toLowerCase().compareTo(
          b['title'].toString().toLowerCase(),
        ),
      );
    } else {
      _filteredSongs.sort(
        (a, b) => a['singer'].toString().toLowerCase().compareTo(
          b['singer'].toString().toLowerCase(),
        ),
      );
    }
  }

  // deklrasi warna berdasarkan genre
  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Pop':
        return Colors.purple;
      case 'Jazz':
        return Colors.orange;
      case 'Dangdut':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // fungsi dialog tambah dan edit data lagu
  void _showAddEditDialog({Map<String, dynamic>? song}) {
    final isEdit = song != null;
    final titleController = TextEditingController(text: song?['title'] ?? '');
    final singerController = TextEditingController(text: song?['singer'] ?? '');
    String selectedGenre = song?['genre'] ?? 'Pop';
    String? titleError;
    String? singerError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Edit Lagu' : 'Tambah Lagu',
                style: const TextStyle(
                  color: Color(0xFF2a5298),
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      onChanged: (value) {
                        setDialogState(() {
                          titleError = value.isEmpty
                              ? 'Judul lagu wajib diisi'
                              : null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Judul Lagu',
                        prefixIcon: const Icon(
                          Icons.music_note,
                          color: Color(0xFF2a5298),
                        ),
                        errorText: titleError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: titleError != null
                                ? Colors.red
                                : const Color(0xFF2a5298),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: singerController,
                      onChanged: (value) {
                        setDialogState(() {
                          singerError = value.isEmpty
                              ? 'Penyanyi wajib diisi'
                              : null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Penyanyi',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFF2a5298),
                        ),
                        errorText: singerError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: singerError != null
                                ? Colors.red
                                : const Color(0xFF2a5298),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Genre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGenre,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF2a5298),
                          ),
                          items: ['Pop', 'Jazz', 'Dangdut'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getGenreColor(value),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setDialogState(() => selectedGenre = newValue!);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setDialogState(() {
                      titleError = titleController.text.isEmpty
                          ? 'Judul lagu wajib diisi'
                          : null;
                      singerError = singerController.text.isEmpty
                          ? 'Penyanyi wajib diisi'
                          : null;
                    });

                    if (titleError != null || singerError != null) return;

                    final db = await DBHelper.instance.database;
                    final data = {
                      'title': titleController.text,
                      'singer': singerController.text,
                      'genre': selectedGenre,
                    };

                    if (isEdit) {
                      await db.update(
                        'songs',
                        data,
                        where: 'id = ?',
                        whereArgs: [song['id']],
                      );
                    } else {
                      await db.insert('songs', data);
                    }

                    await _loadSongs();
                    Navigator.pop(context);
                    Toast.showSuccessToast(
                      context,
                      isEdit
                          ? 'Lagu berhasil diperbarui!'
                          : 'Lagu berhasil ditambahkan!',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a5298),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(isEdit ? 'Perbarui' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // fungsi menghapus data lagu
  void _deleteSong(Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hapus Lagu',
            style: TextStyle(
              color: Color(0xFF2a5298),
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${song['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = await DBHelper.instance.database;
                await db.delete(
                  'songs',
                  where: 'id = ?',
                  whereArgs: [song['id']],
                );
                await _loadSongs();
                Navigator.pop(context);
                Toast.showSuccessToast(context, 'Lagu berhasil dihapus!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Data Lagu'),
        backgroundColor: const Color(0xFF2a5298),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterAndSortSongs();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari judul lagu...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF2a5298),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                                _filterAndSortSongs();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGenre,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.filter_list,
                                color: Color(0xFF2a5298),
                              ),
                              items: ['Semua', 'Pop', 'Jazz', 'Dangdut'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGenre = newValue!;
                                  _filterAndSortSongs();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.sort,
                                color: Color(0xFF2a5298),
                              ),
                              items: ['Judul', 'Penyanyi'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    'Urutkan: $value',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sortBy = newValue!;
                                  _filterAndSortSongs();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[100],
                  child: Text(
                    '${_filteredSongs.length} lagu ditemukan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
                Expanded(
                  child: _filteredSongs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada lagu ditemukan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 80,
                          ),
                          itemCount: _filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = _filteredSongs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _getGenreColor(
                                          song['genre'],
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.music_note,
                                        color: _getGenreColor(song['genre']),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2a5298),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  song['singer'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getGenreColor(
                                                song['genre'],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              song['genre'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _showAddEditDialog(song: song),
                                          icon: const Icon(Icons.edit),
                                          color: Colors.blue,
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          onPressed: () => _deleteSong(song),
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF2a5298),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Lagu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
