
import 'package:flutter_riverpod/flutter_riverpod.dart';
final searchBarProvider = NotifierProvider<SearchBarNotifier,String>(() => SearchBarNotifier());

class SearchBarNotifier extends Notifier<String> {


  @override
  String build() {
    return "";
  }

  void setString(String s){
    state = s;
  }
}

