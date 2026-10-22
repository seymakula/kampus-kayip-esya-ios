/// Tüm rota yolları tek yerde. Ekranlar `context.go(AppRoutes.search)`
/// gibi kullanır, yol dizgesi elle yazılmaz.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  // Alt menü sekmeleri
  static const home = '/';
  static const search = '/search';
  static const createItem = '/create';
  static const messages = '/messages';
  static const profile = '/profile';

  static const notifications = '/notifications';
  static const itemDetailPattern = '/items/:id';
  static String itemDetail(int id) => '/items/$id';
}
