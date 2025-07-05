\# DCC Symptom Tracker App



A Flutter mobile application designed to help patients with Discordant Chronic Comorbidities (DCCs) track daily symptoms, monitor trends, and generate concise health insights.



\## 📱 Features



\- 📅 \*\*Calendar-Based Logging\*\*: Intuitive calendar interface to log symptoms daily.

\- 📊 \*\*Symptom Trend Analysis\*\*: Visualize symptom trends over time with charts.

\- 🧠 \*\*AI Health Insights\*\*: (Optional) Integrates with OpenAI API to generate health summaries.

\- 🗃️ \*\*Local Data Storage\*\*: Stores data using `sqflite` for offline access.

\- 📤 \*\*Export Reports\*\*: Allows users to export symptom reports for clinical visits.

\- 🔔 \*\*Notifications\*\*: Daily reminders to log symptoms.



\## 💡 Technologies Used



\- \*\*Flutter\*\* \& \*\*Dart\*\*

\- \*\*sqflite\*\* – local storage

\- \*\*Provider\*\* – state management

\- \*\*charts\_flutter\*\* – symptom trend visualization

\- \*\*HTTP\*\* – API requests

\- \*\*OpenAI GPT-4\*\* (optional, API key required via `--dart-define`)



\## 🔐 Environment Setup



This app expects an OpenAI API key provided securely at runtime:



```bash

flutter run --dart-define=OPENAI\_API\_KEY=your\_openai\_key\_here



