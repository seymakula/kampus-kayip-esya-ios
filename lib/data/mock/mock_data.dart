import '../models/models.dart';

// API hazır olana kadar (1–2. haftalar) kullanılan örnek veri.
// Bina koordinatları yaklaşıktır; gerçek değerler web'deki /api/locations'tan gelecek.

const mockCategories = <Category>[
  Category(id: 1, name: 'Elektronik'),
  Category(id: 2, name: 'Cüzdan'),
  Category(id: 3, name: 'Anahtar'),
  Category(id: 4, name: 'Kimlik/Kart'),
  Category(id: 5, name: 'Giyim'),
  Category(id: 6, name: 'Çanta'),
  Category(id: 7, name: 'Kırtasiye'),
  Category(id: 8, name: 'Aksesuar'),
  Category(id: 9, name: 'Şişe/Termos'),
  Category(id: 10, name: 'Şemsiye'),
];

const mockLocations = <Location>[
  Location(id: 1, name: 'Mühendislik Fakültesi', latitude: 39.7792, longitude: 32.8062),
  Location(id: 2, name: 'Merkez Kütüphane', latitude: 39.7801, longitude: 32.8049),
  Location(id: 3, name: 'Merkez Yemekhane', latitude: 39.7785, longitude: 32.8040),
  Location(id: 4, name: 'Spor Salonu', latitude: 39.7773, longitude: 32.8075),
  Location(id: 5, name: 'Rektörlük', latitude: 39.7808, longitude: 32.8068),
  Location(id: 6, name: 'Öğrenci Yurdu', latitude: 39.7765, longitude: 32.8031),
  Location(id: 7, name: 'Ring Durağı', latitude: 39.7797, longitude: 32.8083),
];

const mockUsers = <User>[
  User(id: 1, fullName: 'Şeyma Kula', email: 'seyma.kula@ogrenci.ankara.edu.tr', studentNo: '23291513'),
  User(id: 2, fullName: 'Barış Coşkun', email: 'baris.coskun@ogrenci.ankara.edu.tr', studentNo: '23291721'),
  User(id: 3, fullName: 'Elif Yıldız', email: 'elif.yildiz@ogrenci.ankara.edu.tr', studentNo: '22290145'),
  User(id: 4, fullName: 'Mehmet Demir', email: 'mehmet.demir@ogrenci.ankara.edu.tr', studentNo: '21290877'),
];

/// Oturum açmış kabul edilen mock kullanıcı.
const mockCurrentUser = User(id: 1, fullName: 'Şeyma Kula', email: 'seyma.kula@ogrenci.ankara.edu.tr', studentNo: '23291513');

Category _cat(int id) => mockCategories.firstWhere((c) => c.id == id);
Location _loc(int id) => mockLocations.firstWhere((l) => l.id == id);

/// Sabit "şimdi": göreli tarihler testlerde ve ekran görüntülerinde değişmesin diye.
final _now = DateTime.utc(2026, 10, 30, 12);
DateTime _ago({int days = 0, int hours = 0}) => _now.subtract(Duration(days: days, hours: hours));

int _photoId = 0;
List<ItemPhoto> _photos(List<String> names) => [
      for (var i = 0; i < names.length; i++)
        ItemPhoto(id: ++_photoId, url: 'assets/mock/${names[i]}.jpg', sortOrder: i),
    ];

Item _item({
  required int id,
  required ItemType type,
  ItemStatus status = ItemStatus.published,
  required String title,
  required String description,
  required int categoryId,
  required int locationId,
  required int eventDaysAgo,
  int createdHoursAfterEvent = 2,
  required int ownerId,
  String? verificationQuestion,
  List<String> photos = const [],
}) {
  final eventDate = _ago(days: eventDaysAgo);
  return Item(
    id: id,
    type: type,
    status: status,
    title: title,
    description: description,
    category: _cat(categoryId),
    location: _loc(locationId),
    eventDate: eventDate,
    createdAt: eventDate.add(Duration(hours: createdHoursAfterEvent)),
    ownerId: ownerId,
    verificationQuestion: type == ItemType.found ? verificationQuestion : null,
    photos: _photos(photos),
  );
}

final List<Item> mockItems = [
  _item(id: 1, type: ItemType.found, title: 'Kahverengi deri cüzdan', description: 'Yemekhanede pencere kenarındaki masada bulundu. İçinde kartlar var, para yok.', categoryId: 2, locationId: 3, eventDaysAgo: 0, ownerId: 2, verificationQuestion: 'Cüzdanın içinde hangi bankanın kartı var?', photos: ['cuzdan_kahve']),
  _item(id: 2, type: ItemType.lost, title: 'Kırmızı anahtarlıklı anahtar', description: 'Üç anahtar ve kırmızı plastik anahtarlık. Kütüphane ile ring durağı arasında düşürdüm.', categoryId: 3, locationId: 2, eventDaysAgo: 1, ownerId: 3, photos: ['anahtar_kirmizi']),
  _item(id: 3, type: ItemType.found, title: 'AirPods kutusu', description: 'Beyaz AirPods şarj kutusu, içinde tek kulaklık var. Mühendislik B blok 2. kat koridorunda bulundu.', categoryId: 1, locationId: 1, eventDaysAgo: 1, ownerId: 4, verificationQuestion: 'Kutunun arkasında ne yazıyor / ne çıkartması var?', photos: ['airpods']),
  _item(id: 4, type: ItemType.found, title: 'Öğrenci kimlik kartı', description: 'Spor salonu soyunma odasında bulundu. Kart bilgileri ilanda paylaşılmadı.', categoryId: 4, locationId: 4, eventDaysAgo: 2, ownerId: 1, verificationQuestion: 'Kartın üzerindeki öğrenci numarasının son 3 hanesi nedir?', photos: ['ogrenci_kimlik']),
  _item(id: 5, type: ItemType.lost, title: 'Yeşil çelik termos', description: '500 ml, üzerinde dağ çıkartması olan yeşil termos. Rektörlük önündeki bankta unuttum.', categoryId: 9, locationId: 5, eventDaysAgo: 2, ownerId: 1, photos: ['termos_yesil']),
  _item(id: 6, type: ItemType.found, title: 'Siyah katlanır şemsiye', description: 'Ring durağında bankın altında bulundu.', categoryId: 10, locationId: 7, eventDaysAgo: 3, ownerId: 3, verificationQuestion: 'Şemsiyenin sapının rengi nedir?', photos: ['semsiye_siyah']),
  _item(id: 7, type: ItemType.lost, title: 'Casio bilimsel hesap makinesi', description: 'fx-991 model, arkasında isim etiketi var. Mühendislik D-104 sınıfında sınavdan sonra kaldı.', categoryId: 1, locationId: 1, eventDaysAgo: 3, ownerId: 4, photos: ['hesap_makinesi']),
  _item(id: 8, type: ItemType.found, title: 'Mavi spiralli defter', description: 'Diferansiyel denklemler notları var. Kütüphane 3. kat çalışma masasında bulundu.', categoryId: 7, locationId: 2, eventDaysAgo: 4, ownerId: 2, verificationQuestion: 'Defterin ilk sayfasında ne yazıyor?', photos: ['defter_mavi']),
  _item(id: 9, type: ItemType.lost, title: 'Siyah çerçeveli numaralı gözlük', description: 'Kahverengi kılıfı ile birlikte. Yemekhane ya da kütüphanede kaybettim.', categoryId: 8, locationId: 3, eventDaysAgo: 4, ownerId: 3, photos: ['gozluk']),
  _item(id: 10, type: ItemType.found, title: 'Lacivert kapüşonlu mont', description: 'M beden, cebinde bir toka var. Spor salonu tribününde bulundu.', categoryId: 5, locationId: 4, eventDaysAgo: 5, ownerId: 4, verificationQuestion: 'Montun markası nedir?', photos: ['mont_lacivert']),
  _item(id: 11, type: ItemType.lost, title: 'USB-C şarj aleti', description: '65W beyaz laptop şarj aleti ve kablosu. Kütüphane priz masasında kaldı.', categoryId: 1, locationId: 2, eventDaysAgo: 5, ownerId: 2, photos: ['sarj_aleti']),
  _item(id: 12, type: ItemType.found, title: 'Gri sırt çantası', description: 'Ring durağında sahipsiz bulundu, güvenlik birimine haber verildi.', categoryId: 6, locationId: 7, eventDaysAgo: 6, ownerId: 1, verificationQuestion: 'Çantanın ön cebinde ne var?', photos: ['canta_gri']),
  _item(id: 13, type: ItemType.lost, title: 'Gümüş bilezik', description: 'İnce zincirli, üzerinde küçük kalp figürü var. Manevi değeri yüksek.', categoryId: 8, locationId: 6, eventDaysAgo: 7, ownerId: 3, photos: ['bilezik']),
  _item(id: 14, type: ItemType.found, title: 'Beyaz kablolu kulaklık', description: 'Yurt çalışma salonunda bulundu.', categoryId: 1, locationId: 6, eventDaysAgo: 8, ownerId: 2, verificationQuestion: 'Kulaklığın girişi hangi tip?', photos: ['kulaklik_beyaz']),
  _item(id: 15, type: ItemType.lost, title: 'Bordo yün atkı', description: 'El örgüsü, uçlarında püskül var. Rektörlük binası girişinde düşmüş olabilir.', categoryId: 5, locationId: 5, eventDaysAgo: 9, ownerId: 4, photos: ['atki']),
  _item(id: 16, type: ItemType.found, title: '32 GB USB bellek', description: 'Mühendislik bilgisayar laboratuvarında bilgisayara takılı unutulmuş.', categoryId: 1, locationId: 1, eventDaysAgo: 10, ownerId: 3, verificationQuestion: 'Bellekteki bir klasörün adını yazın.', photos: ['usb_bellek']),
  _item(id: 17, type: ItemType.lost, title: 'Algoritmalar ders kitabı', description: 'Introduction to Algorithms, içinde sarı yapışkan notlar var.', categoryId: 7, locationId: 2, eventDaysAgo: 11, ownerId: 1, photos: ['kitap_algoritma']),
  _item(id: 18, type: ItemType.found, title: 'Gri örgü bere', description: 'Yemekhane girişindeki askılıkta bulundu.', categoryId: 5, locationId: 3, eventDaysAgo: 12, ownerId: 4, verificationQuestion: 'Berenin üzerinde hangi desen var?', photos: ['bere']),
  // Onay bekleyen ve fotoğrafsız örnekler: listede görünmemeli / boş kapak durumu test edilir.
  _item(id: 19, type: ItemType.lost, status: ItemStatus.pending, title: 'Mavi kalem kutusu', description: 'Fermuarlı, içinde teknik kalemler var.', categoryId: 7, locationId: 1, eventDaysAgo: 0, ownerId: 1),
  _item(id: 20, type: ItemType.found, status: ItemStatus.resolved, title: 'Telefon kılıfı', description: 'Sahibine teslim edildi.', categoryId: 8, locationId: 3, eventDaysAgo: 14, ownerId: 2, verificationQuestion: 'Kılıfın rengi nedir?'),
];

final mockClaims = <Claim>[
  Claim(id: 1, itemId: 4, itemTitle: 'Öğrenci kimlik kartı', kind: ClaimKind.owner, status: ClaimStatus.pending, claimantId: 3, claimantName: 'Elif Y.', answer: '145', createdAt: _ago(days: 1)),
  Claim(id: 2, itemId: 12, itemTitle: 'Gri sırt çantası', kind: ClaimKind.owner, status: ClaimStatus.approved, claimantId: 4, claimantName: 'Mehmet D.', answer: 'Mavi bir powerbank', createdAt: _ago(days: 4)),
  Claim(id: 3, itemId: 2, itemTitle: 'Kırmızı anahtarlıklı anahtar', kind: ClaimKind.finder, status: ClaimStatus.pending, claimantId: 1, claimantName: 'Şeyma K.', createdAt: _ago(hours: 6)),
];

final mockMessages = <Message>[
  Message(id: 1, claimId: 2, senderId: 4, content: 'Merhaba, çanta bende olabilir mi diye yazdım.', sentAt: _ago(days: 3, hours: 5), isRead: true),
  Message(id: 2, claimId: 2, senderId: 1, content: 'Evet, ön cepteki powerbank doğru. Yarın 12:00 gibi yemekhane önünde buluşalım mı?', sentAt: _ago(days: 3, hours: 4), isRead: true),
  Message(id: 3, claimId: 2, senderId: 4, content: 'Olur, teşekkürler!', sentAt: _ago(days: 3, hours: 3)),
];

final mockNotifications = <AppNotification>[
  AppNotification(id: 1, content: 'Elif Y. "Öğrenci kimlik kartı" ilanınız için talep gönderdi.', linkUrl: '/items/4', createdAt: _ago(days: 1)),
  AppNotification(id: 2, content: 'Mehmet D. size yeni bir mesaj gönderdi.', linkUrl: '/claims/2/chat', createdAt: _ago(days: 3, hours: 3)),
  AppNotification(id: 3, content: '"Yeşil çelik termos" ilanınız yayınlandı.', linkUrl: '/items/5', isRead: true, createdAt: _ago(days: 2)),
];
