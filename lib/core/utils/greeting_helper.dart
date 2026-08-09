/// Helper for time-based Indonesian greetings using device local time.
abstract final class GreetingHelper {
  static String greetingFor(DateTime dateTime) {
    final hour = dateTime.hour;

    if (hour >= 5 && hour <= 10) {
      return 'Selamat Pagi';
    }

    if (hour >= 11 && hour <= 14) {
      return 'Selamat Siang';
    }

    if (hour >= 15 && hour <= 17) {
      return 'Selamat Sore';
    }

    return 'Selamat Malam';
  }

  static String greeting() => greetingFor(DateTime.now());
}
