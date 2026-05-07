# Panduan Tanya Jawab Dosen - Memorimage

File ini disiapkan untuk membantu menjelaskan project Memorimage saat demo UTS.
Formatnya dibuat praktis: pertanyaan yang mungkin muncul, jawaban singkat, dan
contoh perubahan kode jika dosen meminta modifikasi langsung.

## Ringkasan Jawaban 30 Detik

Memorimage adalah game memori gambar berbasis Flutter. User login memakai
username, lalu game menampilkan beberapa gambar target secara berurutan selama
3 detik per gambar. Setelah itu user menjawab pilihan ganda gambar. Setiap soal
punya timer 30 detik. Jika benar, skor bertambah sesuai sisa detik. Skor terbaik
disimpan secara lokal memakai SharedPreferences dan bisa dilihat di halaman High
Score. Aplikasi sudah bisa berjalan sebagai Flutter web dan sudah dideploy ke
https://demo.aaroncandra.vip.

## Struktur Yang Perlu Diingat

- File utama aplikasi: `lib/main.dart`
- Dependency penyimpanan lokal: `shared_preferences`
- Asset gambar game: `assets/memorimage/`
- Asset ranking: `assets/ranks/`
- Konfigurasi asset dan dependency: `pubspec.yaml`
- Konstanta penting:
  - `_roundsPerGame = 5`
  - `_memorizeSeconds = 3`
  - `_answerSeconds = 30`
  - `_usernameKey = 'memorimage_username'`
  - `_highScoresKey = 'memorimage_high_scores'`

## Pertanyaan Konsep Dan Jawaban

1. Apa tujuan aplikasi ini?
   Jawaban: Membuat game memori gambar. Pemain mengingat gambar yang muncul,
   lalu memilih gambar yang sama dari beberapa opsi.

2. Kenapa namanya Memorimage?
   Jawaban: Gabungan dari memory dan image, karena fokus game adalah mengingat
   gambar.

3. Requirement utama apa saja yang dipenuhi?
   Jawaban: Login username, menu utama dengan drawer, game hafalan gambar,
   timer, scoring, result screen, high score, penyimpanan lokal, dan animasi.

4. Kenapa memakai Flutter?
   Jawaban: Flutter bisa membuat UI responsif untuk mobile dan web dari satu
   codebase, cocok untuk project game ringan seperti ini.

5. Apakah aplikasi ini memakai database online?
   Jawaban: Tidak. High score dan username disimpan lokal menggunakan
   SharedPreferences.

6. Apa kekurangan SharedPreferences?
   Jawaban: Data hanya tersimpan di device atau browser yang sama. Jika cache
   browser dihapus, data bisa hilang.

7. Kenapa tidak memakai Firebase atau Supabase?
   Jawaban: Requirement project cukup memakai penyimpanan lokal. Firebase atau
   Supabase bisa ditambahkan jika leaderboard harus online dan multi-device.

8. Data apa saja yang disimpan?
   Jawaban: Username login dan daftar high score.

9. Dalam format apa high score disimpan?
   Jawaban: Disimpan sebagai list string JSON. Setiap entry berisi username dan
   score.

10. Bagaimana alur login?
    Jawaban: User mengisi username, username di-trim, lalu disimpan ke
    SharedPreferences. Saat aplikasi dibuka lagi, app membaca key username dan
    langsung masuk ke menu jika username masih ada.

11. Apa yang terjadi saat logout?
    Jawaban: Key username dihapus dari SharedPreferences, lalu state app
    dikembalikan ke halaman login.

12. Kenapa `MyApp` dibuat StatefulWidget?
    Jawaban: Karena app perlu menyimpan state session username dan loading
    status.

13. Kenapa beberapa screen StatelessWidget?
    Jawaban: Karena screen seperti Main Menu tidak mengelola perubahan state
    internal yang kompleks. Datanya diterima lewat constructor.

14. Kenapa GameScreen StatefulWidget?
    Jawaban: Karena game punya state yang berubah terus, seperti fase game,
    timer, score, index soal, opsi jawaban, dan jawaban terkunci.

15. Apa fase game yang ada?
    Jawaban: Ada `preparing`, `memorizing`, dan `answering` melalui enum
    `GamePhase`.

16. Bagaimana gambar target dipilih?
    Jawaban: Kode mengambil kategori objek, mengacak kategori, lalu memilih
    satu gambar dari tiap kategori untuk target.

17. Kenapa opsi jawaban berasal dari kategori yang sama?
    Jawaban: Supaya tebakan lebih menantang. Misalnya target adalah botol merah,
    maka pilihan berupa beberapa botol dengan warna berbeda.

18. Bagaimana memastikan jawaban benar ada di opsi?
    Jawaban: Target berasal dari `kGameItems`. Saat opsi dibuat, semua item
    dengan kategori yang sama diambil, sehingga target pasti termasuk di
    dalamnya.

19. Berapa jumlah opsi jawaban?
    Jawaban: Saat ini 4 opsi, karena tiap kategori punya 4 variasi warna.

20. Berapa durasi melihat gambar?
    Jawaban: 3 detik per gambar, diatur oleh `_memorizeSeconds`.

21. Berapa durasi menjawab soal?
    Jawaban: 30 detik per soal, diatur oleh `_answerSeconds`.

22. Bagaimana skor dihitung?
    Jawaban: Jika benar, skor ditambah sisa detik pada timer. Jika menjawab
    cepat, skor lebih tinggi.

23. Berapa skor maksimal?
    Jawaban: Dengan 5 soal dan 30 detik per soal, maksimal teoritis 150 poin.

24. Apa yang terjadi jika waktu habis?
    Jawaban: Jawaban dikunci, skor tidak bertambah, lalu otomatis lanjut ke
    soal berikutnya.

25. Bagaimana mencegah user klik jawaban berkali-kali?
    Jawaban: Menggunakan `_answerLocked`. Setelah memilih jawaban atau timeout,
    input berikutnya diabaikan.

26. Kenapa timer harus di-cancel?
    Jawaban: Supaya tidak ada timer yang tetap berjalan setelah screen berubah.
    Timer di-cancel di `dispose`, saat pindah fase, dan saat game selesai.

27. Apa risiko kalau timer tidak di-cancel?
    Jawaban: Bisa terjadi memory leak, setState dipanggil setelah widget hilang,
    atau timer ganda berjalan bersamaan.

28. Kenapa ada pengecekan `mounted`?
    Jawaban: Untuk memastikan widget masih ada sebelum memanggil `setState` atau
    navigasi setelah operasi async/timer.

29. Kenapa memakai AnimatedSwitcher?
    Jawaban: Untuk memberi transisi halus saat fase tampilan berubah.

30. Animasi apa saja yang digunakan?
    Jawaban: `AnimatedSwitcher`, `ScaleTransition`, `AnimatedContainer`, dan
    `TweenAnimationBuilder` untuk skor di result screen.

31. Bagaimana high score disimpan?
    Jawaban: Saat result screen dibuka, `saveIfPersonalBest` mengecek skor
    terbaik username tersebut. Jika skor baru lebih tinggi, data lama user itu
    diganti.

32. Apakah user yang sama bisa punya banyak skor?
    Jawaban: Tidak. Yang disimpan hanya personal best dari username tersebut.

33. Kalau dua skor sama, urutannya bagaimana?
    Jawaban: Jika skor sama, diurutkan berdasarkan username secara alfabetis.

34. Kenapa High Score menampilkan top 3?
    Jawaban: Karena requirement memakai ranking 1 sampai 3. Tetapi repository
    sudah menyimpan sampai 10 entry terbaik.

35. Apa yang terjadi kalau data high score rusak?
    Jawaban: `ScoreEntry.fromStorage` akan mencoba decode JSON. Jika gagal,
    data rusak diabaikan.

36. Kenapa memakai FutureBuilder di High Score?
    Jawaban: Karena data SharedPreferences dibaca secara async, jadi UI perlu
    menunggu hasilnya.

37. Apa fungsi `Navigator.push`?
    Jawaban: Membuka screen baru di atas screen sekarang.

38. Apa fungsi `Navigator.pushReplacement`?
    Jawaban: Mengganti screen saat ini. Dipakai dari game ke result agar user
    tidak kembali ke game yang sudah selesai.

39. Apa fungsi `popUntil((route) => route.isFirst)`?
    Jawaban: Mengembalikan navigasi ke halaman pertama, yaitu main menu.

40. Bagaimana aplikasi responsif?
    Jawaban: Menggunakan `ConstrainedBox`, `ListView`, `Wrap`, dan `LayoutBuilder`.
    Opsi jawaban 4 kolom di layar lebar dan 2 kolom di layar kecil.

41. Kenapa memakai asset lokal, bukan gambar internet?
    Jawaban: Asset lokal lebih stabil, bisa offline, dan tidak tergantung koneksi
    atau hak akses URL.

42. Di mana asset didaftarkan?
    Jawaban: Di `pubspec.yaml`, bagian `flutter/assets`.

43. Apa fungsi `GameItem`?
    Jawaban: Model data untuk setiap gambar. Isinya id, category, objectName,
    colorName, dan assetPath.

44. Apa fungsi `kGameItems`?
    Jawaban: Daftar master semua gambar yang bisa dipakai dalam game.

45. Bagaimana menambah gambar baru?
    Jawaban: Tambahkan file PNG ke `assets/memorimage/`, lalu tambahkan entry
    baru di `kGameItems`.

46. Kenapa kategori penting?
    Jawaban: Kategori dipakai untuk membuat opsi jawaban yang mirip. Contoh:
    semua opsi untuk target pensil berasal dari kategori `pencil`.

47. Apa title Italia di result screen?
    Jawaban: Gelar berdasarkan jumlah jawaban benar, misalnya 5 benar mendapat
    `Maestro dell'Indovinello`.

48. Bagaimana cara mengganti gelar result?
    Jawaban: Ubah fungsi `titleForCorrectAnswers`.

49. Apa command untuk menjalankan project?
    Jawaban: `flutter run` atau untuk web bisa `flutter run -d chrome`.

50. Apa command untuk build web?
    Jawaban: `flutter build web`.

51. Apa command untuk mengecek error statis?
    Jawaban: `flutter analyze`.

52. Apa command untuk menjalankan test?
    Jawaban: `flutter test`.

53. Apakah project sudah dideploy?
    Jawaban: Sudah, ke `https://demo.aaroncandra.vip`.

54. Bagaimana deployment web dilakukan?
    Jawaban: Build Flutter web menghasilkan folder `build/web`, lalu isi folder
    tersebut diupload ke webroot domain di CloudPanel.

55. Kenapa perlu SSL?
    Jawaban: Agar domain bisa diakses lewat HTTPS tanpa warning browser.

56. SSL yang dipakai apa?
    Jawaban: Let's Encrypt.

57. Apa kekurangan aplikasi saat ini?
    Jawaban: Leaderboard masih lokal, belum online. Jumlah kategori gambar juga
    masih terbatas.

58. Kalau browser cache dibersihkan, apa yang terjadi?
    Jawaban: Username dan high score lokal bisa hilang.

59. Kalau user refresh browser saat game berlangsung?
    Jawaban: State ronde aktif tidak disimpan, jadi app kembali berdasarkan
    session username yang tersimpan.

60. Bagaimana kalau ingin menyimpan progress game saat refresh?
    Jawaban: Simpan state game seperti target, index soal, score, dan timer ke
    SharedPreferences atau database, lalu restore saat app dibuka.

61. Apakah kode sudah memisahkan business logic dan UI?
    Jawaban: Sebagian sudah, seperti `HighScoreRepository`, `ScoreEntry`,
    `GameItem`, dan fungsi title. Untuk project lebih besar bisa dipisah ke
    beberapa file.

62. Kenapa semua masih di `main.dart`?
    Jawaban: Karena scope UTS kecil dan lebih mudah dinilai dalam satu file.
    Jika dikembangkan, bisa dipisah menjadi folder screens, models, dan services.

63. Apa yang akan dipisah jika refactor?
    Jawaban: Model `GameItem` dan `ScoreEntry`, repository high score, screen
    login/menu/game/result/high score, serta constants.

64. Bagaimana testing yang bisa ditambah?
    Jawaban: Unit test untuk sorting high score, parsing ScoreEntry, title result,
    dan widget test untuk login serta tampilan high score.

65. Apa contoh edge case yang sudah ditangani?
    Jawaban: Username kosong ditolak, data high score rusak diabaikan, timer
    dibatalkan saat screen dispose, dan tombol jawaban dikunci setelah dipilih.

66. Apa edge case yang masih bisa ditambah?
    Jawaban: Validasi panjang username, reset high score, mode offline/online,
    dan penyimpanan progress game.

67. Kenapa `Random` dipakai?
    Jawaban: Untuk mengacak kategori target dan opsi jawaban agar tiap game tidak
    selalu sama.

68. Apakah random ini aman untuk security?
    Jawaban: Tidak didesain untuk security. Untuk game biasa, `Random` cukup.

69. Kalau ingin urutan soal deterministik untuk testing?
    Jawaban: Inject `Random` dengan seed atau buat service random yang bisa
    dimock saat test.

70. Apa bagian tersulit dari project ini?
    Jawaban: Mengatur alur game berbasis timer supaya transisi memory phase,
    answer phase, timeout, scoring, dan result tetap sinkron.

## Skenario Jika Dosen Minta Ubah Code

### 1. Mengubah jumlah soal menjadi 10 atau 20

Ubah konstanta:

```dart
const int _roundsPerGame = 10;
```

Catatan penting: kode target saat ini memilih satu gambar per kategori, sedangkan
kategori hanya 6. Jadi untuk 10 atau 20 soal, ubah `_buildTargets` agar memilih
dari semua item, bukan satu per kategori.

Ganti fungsi `_buildTargets` menjadi:

```dart
List<GameItem> _buildTargets() {
  final shuffled = List<GameItem>.from(kGameItems)..shuffle(_random);
  return shuffled.take(_roundsPerGame).toList();
}
```

Ini aman untuk 10 atau 20 soal karena total item saat ini 24.

Jika ingin lebih dari 24 soal, pakai versi yang mengizinkan pengulangan:

```dart
List<GameItem> _buildTargets() {
  final targets = <GameItem>[];

  while (targets.length < _roundsPerGame) {
    final shuffled = List<GameItem>.from(kGameItems)..shuffle(_random);
    targets.addAll(shuffled);
  }

  return targets.take(_roundsPerGame).toList();
}
```

### 2. Mengubah waktu hafalan dari 3 detik menjadi 5 detik

```dart
const int _memorizeSeconds = 5;
```

### 3. Mengubah timer jawaban dari 30 detik menjadi 15 detik

```dart
const int _answerSeconds = 15;
```

### 4. Mengubah jumlah opsi jawaban menjadi 6

Saat ini opsi berasal dari kategori yang sama dan tiap kategori hanya punya 4
warna. Jika mau 6 opsi tanpa menambah asset, ambil distractor dari semua item:

```dart
List<GameItem> _buildOptions(GameItem target) {
  final distractors =
      kGameItems.where((item) => item.id != target.id).toList()
        ..shuffle(_random);

  final options = <GameItem>[target, ...distractors.take(5)]..shuffle(_random);
  return options;
}
```

### 5. Menampilkan high score top 10

Ubah repository:

```dart
static Future<List<ScoreEntry>> loadTopScores() async {
  final scores = await _loadScores();
  return scores.take(10).toList();
}
```

Lalu ubah `_ScoreCard`, karena asset `rank_4.png` sampai `rank_10.png` belum ada.
Gunakan gambar hanya untuk rank 1-3, sisanya pakai CircleAvatar:

```dart
final rankAsset = rank <= 3 ? 'assets/ranks/rank_$rank.png' : null;
```

Di bagian UI:

```dart
rankAsset != null
    ? Image.asset(rankAsset, width: 72, height: 72)
    : CircleAvatar(
        radius: 36,
        child: Text('$rank'),
      ),
```

### 6. Mengubah penyimpanan high score dari top 10 menjadi top 20

Di `saveIfPersonalBest`, ubah:

```dart
.take(20)
```

### 7. Menambahkan tombol reset high score

Tambahkan method di `HighScoreRepository`:

```dart
static Future<void> clearScores() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_highScoresKey);
}
```

Lalu panggil dari tombol di `HighScoreScreen`.

### 8. Menambahkan validasi panjang username

Di validator `TextFormField` login:

```dart
if (value.trim().length < 3) {
  return 'Username minimal 3 karakter';
}
```

### 9. Mengubah scoring agar jawaban salah mengurangi poin

Di `_selectOption`, tambahkan else:

```dart
if (isCorrect) {
  _score += _answerSecondsLeft;
  _correctAnswers += 1;
} else {
  _score = max(0, _score - 5);
}
```

Pastikan `dart:math` sudah diimport, dan saat ini memang sudah ada.

### 10. Mengubah scoring agar benar selalu 10 poin

Ganti bagian skor:

```dart
_score += 10;
```

### 11. Menampilkan jawaban benar setelah user salah

Saat ini sudah ada indikator hijau untuk jawaban benar dan merah untuk pilihan
yang salah di `_OptionTile`. Jika dosen minta teks, tambahkan state message
seperti `_feedbackText`, lalu tampilkan di question view.

### 12. Menambah kategori gambar baru

Langkah:

1. Tambahkan PNG ke `assets/memorimage/`
2. Pastikan `pubspec.yaml` sudah include folder `assets/memorimage/`
3. Tambahkan 4 entry baru di `kGameItems`, misalnya `phone_red`, `phone_blue`,
   `phone_green`, `phone_yellow`

Contoh:

```dart
GameItem(
  id: 'phone_red',
  category: 'phone',
  objectName: 'handphone',
  colorName: 'merah',
  assetPath: 'assets/memorimage/phone_red.png',
),
```

### 13. Menambah mode difficulty

Tambahkan parameter ke `GameScreen`, misalnya:

```dart
final int rounds;
final int answerSeconds;
final int memorizeSeconds;
```

Lalu dari Main Menu buat tombol Easy, Normal, Hard yang mengirim nilai berbeda.

### 14. Menambah halaman instruksi

Tambahkan screen baru `InstructionScreen`, lalu dari main menu tambahkan tombol:

```dart
OutlinedButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const InstructionScreen(),
      ),
    );
  },
  icon: const Icon(Icons.info),
  label: const Text('Instruksi'),
)
```

### 15. Menambahkan suara benar/salah

Butuh dependency tambahan, misalnya `audioplayers`. Tambahkan di `pubspec.yaml`,
daftarkan asset audio, lalu panggil saat `isCorrect` true atau false.

### 16. Mengubah title web browser

Di `web/index.html`, ubah:

```html
<title>Memorimage</title>
```

Jika app web sudah build, jalankan ulang:

```bash
flutter build web
```

### 17. Mengubah warna tema

Ubah `seedColor`, `primary`, `secondary`, atau `tertiary` di fungsi
`_buildTheme`.

### 18. Mengubah layout opsi mobile

Di `_buildQuestionView`, ubah:

```dart
final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;
```

Misalnya tablet 3 kolom:

```dart
final crossAxisCount = constraints.maxWidth >= 900
    ? 4
    : constraints.maxWidth >= 600
    ? 3
    : 2;
```

### 19. Menyimpan semua skor, bukan hanya personal best

Di `saveIfPersonalBest`, jangan hapus entry username lama. Cukup add score baru,
lalu sort. Tetapi nama method sebaiknya diganti dari `saveIfPersonalBest`
menjadi `saveScore`.

### 20. Menambahkan tanggal pada high score

Tambahkan field `createdAt` di `ScoreEntry`, simpan sebagai ISO string:

```dart
DateTime.now().toIso8601String()
```

Lalu tampilkan di `_ScoreCard`.

### 21. Menghapus auto login

Di `_loadSession`, jangan baca username dari SharedPreferences. Set `_username`
selalu null. Atau tetap baca tetapi tambahkan opsi "remember me".

### 22. Menambah tombol "Ganti Username"

Tambahkan menu drawer yang memanggil logout atau membuka dialog input username
baru. Jika hanya ingin cepat, pakai fungsi `_logout`.

### 23. Mengubah agar game langsung mulai setelah login

Di `_login`, setelah set username, app masuk menu. Jika ingin langsung game,
struktur navigasi perlu dipindah atau gunakan state tambahan untuk membuka
`GameScreen` setelah login.

### 24. Menampilkan preview semua gambar sebelum mulai

Tambahkan screen gallery yang membaca `kGameItems`, lalu tampilkan GridView.

### 25. Membuat leaderboard online

Pilihan:

- Firebase Firestore
- Supabase table
- REST API backend sendiri

Data minimal: username, score, created_at.

### 26. Menambahkan pause game

Tambahkan state `_isPaused`. Saat pause, cancel timer. Saat resume, buat ulang
timer dengan sisa detik yang sama.

### 27. Menambahkan konfirmasi keluar saat game berlangsung

Gunakan `PopScope` di `GameScreen`, lalu tampilkan dialog sebelum keluar.

### 28. Mengubah durasi jeda setelah jawaban

Ubah di `_queueNextQuestion`:

```dart
_transitionTimer = Timer(const Duration(milliseconds: 750), () {
```

Misalnya menjadi 1500 ms.

### 29. Menambah loading/error state high score

FutureBuilder saat ini punya loading dan empty state. Jika ingin error state,
tambahkan:

```dart
if (snapshot.hasError) {
  return const Center(child: Text('Gagal memuat high score'));
}
```

### 30. Memisahkan file agar rapi

Struktur yang bisa dibuat:

```text
lib/
  main.dart
  models/game_item.dart
  models/score_entry.dart
  repositories/high_score_repository.dart
  screens/login_screen.dart
  screens/main_menu_screen.dart
  screens/game_screen.dart
  screens/result_screen.dart
  screens/high_score_screen.dart
```

## Pertanyaan Jebakan Yang Mungkin Muncul

1. Kalau `_roundsPerGame` langsung diubah ke 10, apakah pasti jalan?
   Jawaban: Belum tentu dengan logic target saat ini, karena target memilih satu
   item per kategori dan kategori hanya 6. Harus ubah `_buildTargets` atau tambah
   kategori baru.

2. Kalau high score ditampilkan top 10, apakah cukup ubah `take(3)`?
   Jawaban: Belum cukup. `_ScoreCard` memakai asset `rank_$rank.png`, sementara
   asset hanya rank 1 sampai 3. Rank 4 ke atas perlu fallback UI.

3. Kenapa max score 150, bukan 155?
   Jawaban: Ada 5 soal dan tiap soal maksimal 30 poin. Skor didapat dari sisa
   timer saat menjawab benar.

4. Kenapa opsi selalu 4?
   Jawaban: Karena tiap kategori punya 4 varian warna.

5. Apakah jawaban benar bisa tidak muncul?
   Jawaban: Tidak, karena opsi diambil dari kategori yang sama dengan target dan
   target sendiri ada di kategori itu.

6. Apakah high score semua user tersimpan?
   Jawaban: Tersimpan lokal untuk browser/device yang sama, bukan server global.

7. Apakah logout menghapus high score?
   Jawaban: Tidak. Logout hanya menghapus username session. High score tetap ada.

8. Kenapa `pushReplacement` dipakai ke ResultScreen?
   Jawaban: Supaya user tidak bisa back ke game yang sudah selesai.

9. Apakah timer tetap jalan saat pindah screen?
   Jawaban: Tidak, timer dicancel di `dispose` dan saat game selesai.

10. Kalau app dibuka di HP, apakah layout rusak?
    Jawaban: Tidak seharusnya, karena memakai ListView, ConstrainedBox, Wrap, dan
    grid 2 kolom untuk layar kecil.

## Checklist Sebelum Demo

- Buka `https://demo.aaroncandra.vip`
- Login dengan username sederhana, misalnya `Aaron`
- Klik Play Game
- Hafalkan 5 gambar
- Jawab beberapa soal dengan benar
- Tunjukkan result screen dan title Italia
- Buka High Scores
- Logout dan login lagi untuk menunjukkan session/persistence
- Siapkan jawaban bahwa high score bersifat lokal, bukan global online

## Jawaban Jika Dosen Minta "Ubah Sekarang"

Gunakan pola jawaban ini:

"Bisa Pak/Bu. Bagian itu dikontrol oleh konstanta/fungsi di `lib/main.dart`.
Misalnya jumlah soal dikontrol oleh `_roundsPerGame`, timer hafalan oleh
`_memorizeSeconds`, timer jawaban oleh `_answerSeconds`, dan high score oleh
`HighScoreRepository`. Saya ubah nilainya, lalu jalankan `flutter analyze` dan
`flutter test` untuk memastikan tidak ada error."

