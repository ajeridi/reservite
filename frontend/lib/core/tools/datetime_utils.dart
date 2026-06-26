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


  static int stringToDow(String day){
    return switch (day) {
       "Lundi" => 1,
        "Mardi" => 2,
        "Mercredi" => 3,
        "Jeudi" => 4,
        "Vendredi" => 5,
        "Samedi" => 6,
        "Dimanche" => 7,
      _ => 0,
    };
  }
}