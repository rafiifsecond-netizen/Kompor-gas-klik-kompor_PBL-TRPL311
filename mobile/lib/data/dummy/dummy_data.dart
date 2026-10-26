const dummyTechnicians = <Map<String, dynamic>>[
  {
    'id': 1,
    'name': 'Andi Saputra',
    'rating': 4.9,
    'distance': '1,2 km',
    'specialization': 'Kompor gas & regulator',
    'price': 75000,
    'distance_km': 1.2
  },
  {
    'id': 2,
    'name': 'Budi Hartono',
    'rating': 4.8,
    'distance': '2,1 km',
    'specialization': 'Kompor tanam',
    'price': 90000,
    'distance_km': 2.1
  },
  {
    'id': 3,
    'name': 'Candra Wijaya',
    'rating': 4.8,
    'distance': '2,7 km',
    'specialization': 'Kebocoran gas',
    'price': 80000,
    'distance_km': 2.7
  },
  {
    'id': 4,
    'name': 'Dedi Kurniawan',
    'rating': 4.7,
    'distance': '3,4 km',
    'specialization': 'Regulator gas',
    'price': 70000,
    'distance_km': 3.4
  },
  {
    'id': 5,
    'name': 'Eko Prasetyo',
    'rating': 4.7,
    'distance': '4,1 km',
    'specialization': 'Kompor 1 tungku',
    'price': 65000,
    'distance_km': 4.1
  },
  {
    'id': 6,
    'name': 'Fajar Nugraha',
    'rating': 4.6,
    'distance': '4,8 km',
    'specialization': 'Instalasi kompor',
    'price': 100000,
    'distance_km': 4.8
  },
  {
    'id': 7,
    'name': 'Gunawan',
    'rating': 4.6,
    'distance': '5,2 km',
    'specialization': 'Servis berkala',
    'price': 85000,
    'distance_km': 5.2
  },
  {
    'id': 8,
    'name': 'Hendra Wijaya',
    'rating': 4.5,
    'distance': '6,0 km',
    'specialization': 'Selang dan regulator',
    'price': 75000,
    'distance_km': 6.0
  },
];

final dummyCustomerUser = <String, dynamic>{
  'id': 101,
  'name': 'Dewi Lestari',
  'email': 'dewi@example.com',
  'phone': '081234567890',
  'role': 'customer',
  'address': 'Batam, Kepulauan Riau',
  'is_active': true,
};

const dummyReviews = <Map<String, dynamic>>[
  {
    'id': 1,
    'customer': 'Dewi Lestari',
    'rating': 5,
    'comment': 'Teknisi ramah dan cepat.'
  },
  {
    'id': 2,
    'customer': 'Budi Santoso',
    'rating': 5,
    'comment': 'Kompor kembali normal.'
  },
  {
    'id': 3,
    'customer': 'Siti Aminah',
    'rating': 4,
    'comment': 'Pekerjaan rapi.'
  },
  {
    'id': 4,
    'customer': 'Rudi Hartono',
    'rating': 5,
    'comment': 'Sangat membantu.'
  },
  {
    'id': 5,
    'customer': 'Maya Putri',
    'rating': 4,
    'comment': 'Datang tepat waktu.'
  },
];

final dummyTechnicianUser = <String, dynamic>{
  'id': 201,
  'name': 'Andi Saputra',
  'email': 'agus.teknisi@klikkompor.com',
  'phone': '081234567891',
  'role': 'technician',
  'address': 'Batam Centre, Kepulauan Riau',
  'is_active': true,
};

final dummyServices = <Map<String, dynamic>>[
  {'id': 1, 'name': 'Servis Kompor Gas', 'price': 75000, 'duration': 60, 'description': 'Servis kompor gas dengan pemeriksaan dan perbaikan menyeluruh.', 'rating': 4.8, 'review_count': 120},
  {'id': 2, 'name': 'Servis Kompor Tanam', 'price': 125000, 'duration': 90, 'description': 'Perawatan dan perbaikan kompor tanam.', 'rating': 4.8, 'review_count': 80},
  {'id': 3, 'name': 'Cek Kebocoran Gas', 'price': 85000, 'duration': 45, 'description': 'Pemeriksaan keamanan instalasi dan kebocoran gas.', 'rating': 4.9, 'review_count': 95},
  {'id': 4, 'name': 'Ganti Regulator', 'price': 80000, 'duration': 45, 'description': 'Penggantian regulator kompor gas.', 'rating': 4.7, 'review_count': 64},
  {'id': 5, 'name': 'Ganti Selang Gas', 'price': 60000, 'duration': 30, 'description': 'Penggantian selang gas yang aman dan sesuai standar.', 'rating': 4.8, 'review_count': 72},
];

final dummyDamageTypes = <String, List<String>>{
  'regulator': ['Regulator bocor', 'Regulator rusak', 'Tekanan gas tidak stabil', 'Lainnya'],
  'selang': ['Selang bocor', 'Selang retak', 'Bau gas dari selang', 'Lainnya'],
  'instalasi': ['Pemasangan baru', 'Sambungan kurang rapat', 'Cek keamanan instalasi', 'Lainnya'],
  'default': ['Api kecil atau merah', 'Pemantik tidak berfungsi', 'Kompor tidak menyala', 'Bau atau kebocoran gas', 'Lainnya'],
};

final dummyOrders = <Map<String, dynamic>>[
  {'id': 1, 'status': 'pending', 'label': 'Menunggu Pembayaran'},
  {'id': 2, 'status': 'paid', 'label': 'Dibayar'},
  {'id': 3, 'status': 'in_progress', 'label': 'Dikerjakan'},
  {'id': 4, 'status': 'completed', 'label': 'Selesai'},
  {'id': 5, 'status': 'cancelled', 'label': 'Dibatalkan'},
  {'id': 6, 'status': 'on_the_way', 'label': 'Teknisi Menuju Lokasi'},
];

const dummyAdditionalCosts = <int, List<Map<String, dynamic>>>{
  1: [
    {
      'id': 1,
      'item_name': 'Seal burner',
      'quantity': 1,
      'subtotal': 25000,
      'status': 'pending'
    },
  ],
};

const dummyAddresses = <Map<String, dynamic>>[
  {
    'id': 1,
    'label': 'Rumah',
    'address': 'Jl. Sei Beduk No. 77, Batam',
    'is_default': true
  },
  {
    'id': 2,
    'label': 'Kantor',
    'address': 'Batam Centre Blok A No. 8',
    'is_default': false
  },
  {
    'id': 3,
    'label': 'Lainnya',
    'address': 'Taman Raya Blok C No. 15',
    'is_default': false
  },
];

const dummyNotifications = <Map<String, dynamic>>[
  {
    'id': 1,
    'user_id': 1,
    'title': 'Pesanan diterima',
    'message': 'Teknisi sedang menyiapkan kunjungan.',
    'type': 'order_update',
    'is_read': false,
    'created_at': '2026-10-27T09:00:00Z'
  },
  {
    'id': 2,
    'user_id': 1,
    'title': 'Pembayaran berhasil',
    'message': 'Pembayaran pesanan berhasil dicatat.',
    'type': 'payment',
    'is_read': true,
    'created_at': '2026-10-26T12:00:00Z'
  },
  {
    'id': 3,
    'user_id': 1,
    'title': 'Teknisi menuju lokasi',
    'message': 'Teknisi sedang menuju alamat Anda.',
    'type': 'order_update',
    'is_read': false,
    'created_at': '2026-10-25T10:00:00Z'
  },
  {
    'id': 4,
    'user_id': 1,
    'title': 'Pesan baru',
    'message': 'Teknisi mengirim pesan baru.',
    'type': 'chat',
    'is_read': true,
    'created_at': '2026-10-24T08:00:00Z'
  },
  {
    'id': 5,
    'user_id': 1,
    'title': 'Beri ulasan',
    'message': 'Bagikan pengalaman servis Anda.',
    'type': 'review',
    'is_read': false,
    'created_at': '2026-10-23T15:00:00Z'
  },
];

const dummyChatMessages = <int, List<Map<String, dynamic>>>{
  1: [
    {
      'id': 1,
      'message': 'Halo, saya sudah menerima pesanan Anda.',
      'sender_type': 'technician',
      'created_at': '2026-10-27T09:00:00Z'
    },
    {
      'id': 2,
      'message': 'Baik, teknisi. Kapan bisa datang?',
      'sender_type': 'customer',
      'created_at': '2026-10-27T09:02:00Z'
    },
    {
      'id': 3,
      'message': 'Saya menuju lokasi pukul 10.00.',
      'sender_type': 'technician',
      'created_at': '2026-10-27T09:03:00Z'
    },
    {
      'id': 4,
      'message': 'Siap, alamat sudah sesuai.',
      'sender_type': 'customer',
      'created_at': '2026-10-27T09:05:00Z'
    },
    {
      'id': 5,
      'message': 'Mohon siapkan area kompor.',
      'sender_type': 'technician',
      'created_at': '2026-10-27T09:06:00Z'
    },
    {
      'id': 6,
      'message': 'Baik, sampai bertemu.',
      'sender_type': 'customer',
      'created_at': '2026-10-27T09:07:00Z'
    },
  ],
};
