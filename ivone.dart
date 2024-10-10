import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

// ANSI escape codes
const String clearScreen = "\x1B[2J\x1B[H";
const String hideCursor = "\x1B[?25l";
const String showCursor = "\x1B[?25h";
const String resetCursor = "\x1B[H"; // Menaruh kursor di posisi (0,0)
const String resetColor = "\x1B[0m"; // Reset ke warna default

// ANSI escape codes untuk warna
List<String> colors = []; // List warna yang akan diisi secara dinamis

final class Huruf extends LinkedListEntry<Huruf> {
  String isi; // Menyimpan huruf
  String color; // Menyimpan warna
  Huruf(this.isi, {this.color = resetColor});
}

// Fungsi untuk menghasilkan warna acak dari 256 color ANSI
String getRandomAnsiColor() {
  Random random = Random();
  int colorCode = random.nextInt(256); // Menghasilkan angka acak dari 0-255
  return "\x1B[38;5;${colorCode}m"; // Warna teks 8-bit ANSI
}

void main() {
  stdout.write("Masukkan Nama Anda: ");
  String? nama = stdin.readLineSync() ?? '';

  stdout.write("Masukkan Jumlah Warna yang Diinginkan: ");
  int? jumlahWarna = int.tryParse(stdin.readLineSync() ?? '') ?? 0;

  // Generate list warna acak sesuai input user
  colors = List.generate(jumlahWarna, (_) => getRandomAnsiColor());

  // Ambil ukuran terminal
  final width = stdout.terminalColumns; // Lebar terminal
  final height = stdout.terminalLines; // Tinggi terminal
  final totalChars = width * height; // Total karakter yang bisa dicetak
  final String chars = nama.isNotEmpty ? nama : "USER"; // Karakter yang akan dicetak jika nama kosong

  // Membuat grid LinkedList dari Huruf
  final List<LinkedList<Huruf>> grid = List.generate(height, (_) {
    final row = LinkedList<Huruf>();
    for (int i = 0; i < width; i++) {
      row.add(Huruf(' ')); // Isi baris dengan spasi kosong
    }
    return row;
  });

  int index = 0; // Indeks untuk karakter yang akan dicetak
  bool namaSelesai = false; // Menandai apakah pencetakan nama selesai
  int colorIndex = 0; // Indeks warna untuk mengubah warna teks

  // Fungsi untuk mencetak grid
  void printGrid() {
    stdout.write(resetCursor); // Pindah kursor ke (0, 0)
    for (var row in grid) {
      for (var huruf in row) {
        stdout.write("${huruf.color}${huruf.isi}"); // Cetak isi huruf dengan warna
      }
    }
    stdout.write(resetColor); // Reset warna setelah mencetak grid
  }

  // Fungsi animasi
  Future<void> animate() async {
    // Fase 1: Mencetak nama
    while (index < totalChars && !namaSelesai) {
      // Hitung posisi baris dan kolom
      int row = (index ~/ width) % height; // Baris
      int col = (index % width); // Kolom

      // Dapatkan linked list baris saat ini
      var currentRow = grid[row];
      var currentNode = currentRow.first;

      // Akses node tertentu di linked list (berdasarkan kolom)
      for (int i = 0; i < col; i++) {
        currentNode = currentNode.next!;
      }

      // Tentukan arah pergerakan
      if ((row % 2) == 0) {
        // Baris genap: kiri ke kanan
        currentNode.isi = chars[index % chars.length];
      } else {
        // Baris ganjil: kanan ke kiri
        int reverseCol = width - 1 - col; // Hitung kolom terbalik
        currentNode = currentRow.first;
        for (int i = 0; i < reverseCol; i++) {
          currentNode = currentNode.next!;
        }
        currentNode.isi = chars[index % chars.length];
      }

      stdout.write("${hideCursor}"); // Sembunyikan kursor
      printGrid();
      index++;

      await Future.delayed(Duration(milliseconds: 5)); // Delay sebelum langkah berikutnya

      // Cek apakah nama sudah selesai dicetak
      if (index >= totalChars) {
        namaSelesai = true;
        index = 0; // Reset indeks untuk perubahan warna
      }
    }

    // Fase 2: Mengubah warna teks setelah pencetakan selesai
    while (namaSelesai && index < totalChars && colorIndex < colors.length) {
      // Hitung posisi baris dan kolom
      int row = (index ~/ width) % height; // Baris
      int col = (index % width); // Kolom

      // Dapatkan linked list baris saat ini
      var currentRow = grid[row];
      var currentNode = currentRow.first;

      // Akses node tertentu di linked list (berdasarkan kolom)
      for (int i = 0; i < col; i++) {
        currentNode = currentNode.next!;
      }

      // Tentukan arah pergerakan
      if ((row % 2) == 0) {
        // Baris genap: kiri ke kanan
        currentNode.color = colors[colorIndex % colors.length]; // Ubah warna huruf
      } else {
        // Baris ganjil: kanan ke kiri
        int reverseCol = width - 1 - col; // Hitung kolom terbalik
        currentNode = currentRow.first;
        for (int i = 0; i < reverseCol; i++) {
          currentNode = currentNode.next!;
        }
        currentNode.color = colors[colorIndex % colors.length]; // Ubah warna huruf
      }

      stdout.write("${hideCursor}"); // Sembunyikan kursor
      printGrid();
      index++;

      await Future.delayed(Duration(milliseconds: 5)); // Delay sebelum langkah berikutnya

      // Ubah warna secara berulang
      if (index >= totalChars) {
        colorIndex++; // Ubah ke warna berikutnya
        index = 0; // Reset indeks untuk siklus berikutnya
      }
    }

    stdout.write(showCursor); // Tampilkan kursor kembali setelah animasi selesai
  }

  // Jalankan animasi
  animate();
}
