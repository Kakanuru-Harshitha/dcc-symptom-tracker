#!/usr/bin/env python3
import shutil
from pathlib import Path

# 1) List all your project entries here (use forward slashes):
FILES = [
    "lib/models",
    "lib/models/daily_metrics.dart",
    "lib/models/log_entry.dart",
    "lib/models/medication.dart",
    "lib/models/metrics_provider.dart",
    "lib/models/symptom.dart",
    "lib/models/trend_point.dart",
    "lib/providers",
    "lib/providers/log_provider.dart",
    "lib/providers/med_provider.dart",
    "lib/providers/settings_provider.dart",
    "lib/screens",
    "lib/screens/calendar_screen.dart",
    "lib/screens/home_screen.dart",
    "lib/screens/log_symptom_screen.dart",
    "lib/screens/med_edit_screen.dart",
    "lib/screens/med_list_screen.dart",
    "lib/screens/report_screen.dart",
    "lib/screens/settings_screen.dart",
    "lib/screens/trends_screen.dart",
    "lib/services",
    "lib/services/ai_service.dart",
    "lib/services/database_service.dart",
    "lib/services/notification_service.dart",
    "lib/services/report_service.dart",
    "lib/services/trend_service.dart",
    "lib/themes",
    "lib/themes/app_theme.dart",
    "lib/utils",
    "lib/utils/constants.dart",
    "lib/widgets",
    "lib/widgets/body_map.dart",
    "lib/widgets/calendar_strip.dart",
    "lib/widgets/med_list_item.dart",
    "lib/widgets/severity_slider.dart",
    "lib/widgets/trend_chart.dart",
    "lib/main.dart",
]

# # 2) Destination base folder for copies
# CODE_DIR = Path("code")

# # 3) Copy directories (as stubs) and files into code/, preserving relative paths
# for rel in FILES:
#     src = Path(rel)
#     dst = CODE_DIR / src
#     if src.is_dir():
#         dst.mkdir(parents=True, exist_ok=True)
#     elif src.is_file():
#         dst.parent.mkdir(parents=True, exist_ok=True)
#         shutil.copy2(src, dst)
#     else:
#         # create stub directory if it doesn't exist on disk
#         dst.mkdir(parents=True, exist_ok=True)
# print(f"Copied {len(FILES)} entries into '{CODE_DIR}/'")

# 4) Build an in-memory directory tree from FILES
def build_tree(paths):
    tree = {}
    for path in paths:
        parts = [p for p in path.split("/") if p]
        node = tree
        for part in parts:
            node = node.setdefault(part, {})
    return tree

def tree_to_lines(tree, prefix=""):
    lines = []
    items = sorted(tree.items())
    for idx, (name, subtree) in enumerate(items):
        last = (idx == len(items) - 1)
        connector = "└── " if last else "├── "
        lines.append(f"{prefix}{connector}{name}")
        if subtree:
            extension = "    " if last else "│   "
            lines += tree_to_lines(subtree, prefix + extension)
    return lines

project_tree = build_tree(FILES)
tree_lines = ["```"] + tree_to_lines(project_tree) + ["```"]

# 5) Concatenate all file contents into all_codes.txt
with open("all_codes.txt", "w", encoding="utf-8") as txt_out:
    for rel in FILES:
        p = Path(rel)
        if p.is_file():
            txt_out.write(f"--- {rel} ---\n")
            txt_out.write(p.read_text(encoding="utf-8"))
            txt_out.write("\n\n")
print("Created 'all_codes.txt'")

# 6) Generate codes.md with project structure and per-file fenced code blocks
LANG_MAP = {
    ".dart": "dart",
    ".sh": "bash",
    ".md": "markdown",
}

with open("codes.md", "w", encoding="utf-8") as md_out:
    # 6a) Project Structure section
    md_out.write("# Project Structure\n\n")
    md_out.write("\n".join(tree_lines))
    md_out.write("\n\n")
    # 6b) Each file's content
    for rel in FILES:
        p = Path(rel)
        if p.is_file():
            md_out.write(f"## `{rel}`\n\n")
            lang = LANG_MAP.get(p.suffix, "")
            md_out.write(f"```{lang}\n")
            md_out.write(p.read_text(encoding="utf-8"))
            md_out.write("\n```\n\n")
print("Generated 'codes.md'")
