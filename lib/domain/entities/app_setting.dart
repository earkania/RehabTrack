class AppSetting {
  final String key;
  final String value;

  const AppSetting({required this.key, required this.value});

  AppSetting copyWith({String? key, String? value}) {
    return AppSetting(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}
