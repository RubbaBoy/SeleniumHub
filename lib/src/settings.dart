// TODO: Put in settings?
const DEBUG = true;

String get urlBase => DEBUG ? '//localhost:42069' : Uri.base.origin;

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