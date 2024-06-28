import 'dart:io';

// Node class for the singly linked list
class Node {
  String data;
  Node? next;

  Node(this.data);
}

// Singly linked list class
class LinkedList {
  Node? head;

  void insert(String data) {
    var newNode = Node(data);
    if (head == null) {
      head = newNode;
    } else {
      var temp = head;
      while (temp!.next != null) {
        temp = temp.next;
      }
      temp.next = newNode;
    }
  }

  void display() {
    var temp = head;
    while (temp != null) {
      stdout.write('${temp.data} -> ');
      temp = temp.next;
    }
    print('null');
  }
}

// Queue class using a singly linked list
class Queue {
  Node? front;
  Node? rear;

  void enqueue(String data) {
    var newNode = Node(data);
    if (rear == null) {
      front = rear = newNode;
    } else {
      rear!.next = newNode;
      rear = newNode;
    }
  }

  String? dequeue() {
    if (front == null) {
      return null;
    }
    var temp = front;
    front = front!.next;
    if (front == null) {
      rear = null;
    }
    return temp!.data;
  }

  void display() {
    var temp = front;
    while (temp != null) {
      stdout.write('${temp.data} -> ');
      temp = temp.next;
    }
    print('null');
  }
}

class Book {
  String title;
  int stock;

  Book(this.title, this.stock);
}

class Library {
  List<Book> books;
  Map<String, Map<String, DateTime>> borrowedBooks;
  LinkedList transactionHistory;
  Queue requestQueue;

  Library()
      : books = [
          Book('Belajar Dart', 5),
          Book('Flutter untuk Pemula', 3),
          Book('Pemrograman Java', 7),
          Book('Bendera Setengah Tiang', 8),
          Book('Biologi', 4),
          Book('Bunda Lisa', 3),
          Book('Dilan 1990', 2)
        ],
        borrowedBooks = {},
        transactionHistory = LinkedList(),
        requestQueue = Queue();

  void borrowBook(String title, String member, DateTime returnDate) {
    var book =
        books.firstWhere((b) => b.title == title, orElse: () => Book('', 0));
    if (book.title.isEmpty || book.stock <= 0) {
      print('Buku tidak tersedia untuk dipinjam');
      requestQueue.enqueue('$member menunggu buku $title');
      return;
    }

    borrowedBooks.putIfAbsent(member, () => {});
    borrowedBooks[member]![title] = returnDate;
    book.stock--;
    print('$member berhasil meminjam buku $title');
    transactionHistory.insert('$member meminjam $title pada ${DateTime.now()}');
  }

  void returnBook(String title, String member) {
    if (borrowedBooks.containsKey(member) &&
        borrowedBooks[member]!.containsKey(title)) {
      borrowedBooks[member]!.remove(title);
      var book = books.firstWhere((b) => b.title == title);
      book.stock++;
      print('$member telah mengembalikan buku $title');
      transactionHistory
          .insert('$member mengembalikan $title pada ${DateTime.now()}');

      // Proses permintaan dalam antrian jika ada
      String? nextRequest = requestQueue.dequeue();
      if (nextRequest != null) {
        var parts = nextRequest.split(' menunggu buku ');
        var nextMember = parts[0];
        var nextTitle = parts[1];
        borrowBook(
            nextTitle, nextMember, DateTime.now().add(Duration(days: 7)));
      }
    } else {
      print('$member tidak meminjam buku $title');
    }
  }

  void showStock() {
    print('Stok Buku:');
    books.forEach((book) {
      print('${book.title}: ${book.stock}');
    });
  }

  void showBorrowedBooks() {
    print('Buku yang Sedang Dipinjam:');
    borrowedBooks.forEach((member, books) {
      print(member);
      books.forEach((title, returnDate) {
        print('  - $title (Pengembalian: ${returnDate.toLocal()})');
      });
    });
  }

  void showTransactionHistory() {
    print('Riwayat Transaksi:');
    transactionHistory.display();
  }

  void showRequestQueue() {
    print('Antrian Permintaan Buku:');
    requestQueue.display();
  }
}

void main() {
  var library = Library();

  while (true) {
    try {
      stdout.write("Masukkan nama anggota: ");
      String member = stdin.readLineSync()!;

      stdout.write("Pilih operasi (pinjam/kembalikan): ");
      String operation = stdin.readLineSync()!.toLowerCase();

      if (operation != 'pinjam' && operation != 'kembalikan') {
        throw Exception("Operasi tidak valid");
      }

      stdout.write("Masukkan judul buku: ");
      String title = stdin.readLineSync()!;

      if (operation == 'pinjam') {
        DateTime returnDate =
            DateTime.now().add(Duration(days: 14)); // untuk peminjaman 14 hari
        library.borrowBook(title, member, returnDate);
      } else {
        library.returnBook(title, member);
      }

      stdout.write("Apakah ada operasi lain? (y/n): ");
      String answer = stdin.readLineSync()!.toLowerCase();
      if (answer != 'y') {
        break;
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  library.showStock();
  library.showBorrowedBooks();
  library.showTransactionHistory();
  library.showRequestQueue();
}
