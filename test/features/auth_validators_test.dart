import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_kayip_esya/features/auth/auth_validators.dart';

void main() {
  group('schoolEmail', () {
    test('öğrenci ve personel adreslerini kabul eder', () {
      expect(
        AuthValidators.schoolEmail('baris.coskun@ogrenci.ankara.edu.tr'),
        isNull,
      );
      expect(AuthValidators.schoolEmail('hoca@ankara.edu.tr'), isNull);
      expect(
        AuthValidators.schoolEmail('  Baris@Ogrenci.Ankara.edu.tr '),
        isNull,
      );
    });

    test('boş, biçimsiz ve okul dışı adresleri reddeder', () {
      expect(AuthValidators.schoolEmail(''), 'E-posta adresini gir.');
      expect(
        AuthValidators.schoolEmail('baris'),
        'Geçerli bir e-posta adresi gir.',
      );
      expect(
        AuthValidators.schoolEmail('a b@ankara.edu.tr'),
        'Geçerli bir e-posta adresi gir.',
      );
      expect(
        AuthValidators.schoolEmail('baris@gmail.com'),
        contains('Okul e-postanı'),
      );
      // Alan adının sonuna eklenmiş sahte okul adı kabul edilmez.
      expect(
        AuthValidators.schoolEmail('x@fakeankara.edu.tr'),
        contains('Okul e-postanı'),
      );
      expect(
        AuthValidators.schoolEmail('x@ankara.edu.tr.com'),
        contains('Okul e-postanı'),
      );
    });
  });

  test('loginPassword yalnızca boşluğu kontrol eder', () {
    expect(AuthValidators.loginPassword(''), isNotNull);
    expect(AuthValidators.loginPassword('a'), isNull);
  });

  test('newPassword uzunluk, harf ve rakam ister', () {
    expect(AuthValidators.newPassword(''), 'Bir şifre belirle.');
    expect(AuthValidators.newPassword('ab1'), contains('en az 8'));
    expect(
      AuthValidators.newPassword('abcdefgh'),
      contains('harf ve bir rakam'),
    );
    expect(
      AuthValidators.newPassword('12345678'),
      contains('harf ve bir rakam'),
    );
    expect(AuthValidators.newPassword('şifre123'), isNull);
  });

  test('confirmPassword güncel şifreyle karşılaştırır', () {
    var password = 'sifre123';
    final validate = AuthValidators.confirmPassword(() => password);

    expect(validate(''), 'Şifreni tekrar gir.');
    expect(validate('sifre124'), 'Şifreler eşleşmiyor.');
    expect(validate('sifre123'), isNull);

    password = 'baska456';
    expect(validate('sifre123'), 'Şifreler eşleşmiyor.');
  });

  test('fullName ad ve soyad ister', () {
    expect(AuthValidators.fullName(' '), isNotNull);
    expect(AuthValidators.fullName('Barış'), 'Ad ve soyadını birlikte yaz.');
    expect(AuthValidators.fullName('Barış  Coşkun'), isNull);
  });

  test('studentNo yalnızca 5–12 haneli rakam kabul eder', () {
    expect(AuthValidators.studentNo(''), isNotNull);
    expect(AuthValidators.studentNo('23A91721'), contains('rakam'));
    expect(AuthValidators.studentNo('1234'), contains('5–12'));
    expect(AuthValidators.studentNo('1234567890123'), contains('5–12'));
    expect(AuthValidators.studentNo('23291721'), isNull);
  });
}
