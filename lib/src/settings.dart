class Settings {
  int screenshotInterval;
  bool updateScreenshots;

  Settings(this.screenshotInterval, this.updateScreenshots);

  Settings.fromJson(Map<String, dynamic> json)
      : screenshotInterval = json['screenshotInterval'] ?? 2000,
        updateScreenshots = json['updateScreenshots'] ?? true;

  Map<String, dynamic> toJson() => {
    'screenshotInterval': screenshotInterval,
    'updateScreenshots': updateScreenshots
  };
}