from pathlib import Path

# List of all file paths to create
file_paths = [
    "lib/main.dart",
    "lib/themes/app_theme.dart",
    "lib/utils/constants.dart",
    "lib/models/symptom.dart",
    "lib/models/medication.dart",
    "lib/models/log_entry.dart",
    "lib/models/trend_point.dart",
    "lib/services/database_service.dart",
    "lib/services/trend_service.dart",
    "lib/services/report_service.dart",
    "lib/services/notification_service.dart",
    "lib/providers/log_provider.dart",
    "lib/providers/med_provider.dart",
    "lib/providers/settings_provider.dart",
    "lib/screens/home_screen.dart",
    "lib/screens/log_symptom_screen.dart",
    "lib/screens/calendar_screen.dart",
    "lib/screens/trends_screen.dart",
    "lib/screens/med_list_screen.dart",
    "lib/screens/med_edit_screen.dart",
    "lib/screens/report_screen.dart",
    "lib/screens/settings_screen.dart",
    "lib/widgets/calendar_strip.dart",
    "lib/widgets/body_map.dart",
    "lib/widgets/severity_slider.dart",
    "lib/widgets/trend_chart.dart",
    "lib/widgets/med_list_item.dart",
]

# Create directories and files
for file_path in file_paths:
    path = Path(file_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.touch(exist_ok=True)

print("Folder structure and empty files have been created!")
