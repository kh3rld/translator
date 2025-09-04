# Translator

A translator app

## Features

- DeepL translation API integration (free tier supported)
- Auto-detect source language option
- Copy, text-to-speech, and share actions on results
- Modern, animated UI with responsive dropdowns

## Prerequisites

- Flutter 3.35+
- A DeepL API key

## Setup

1) Install dependencies

```
flutter pub get
```

2) Create your `.env` file at project root (alongside `pubspec.yaml`):

```
DEEPL_API_KEY=your-deepl-key-here
DEEPL_API_BASE=https://api-free.deepl.com
```

3) Run

```
flutter run -d <device-id>
```

## Environment variables

- `DEEPL_API_KEY`: Your DeepL API key
- `DEEPL_API_BASE`: API base (default is `https://api-free.deepl.com`)

These are loaded via `flutter_dotenv` in `main.dart` and accessed by `EnvConfig`.

## Linting

```
flutter analyze
```
