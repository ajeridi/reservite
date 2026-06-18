class DatetimeUtils {
  static String dayOfWeekToString(int dow){
    return switch (dow) {
      1 => "Lundi",
      2 => "Mardi",
      3 => "Mercredi",
      4 => "Jeudi",
      5 => "Vendredi",
      6 => "Samedi",
      7 => "Dimanche",
      _ => "Not valid dow"
    };
  }
}