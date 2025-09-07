# Translator App

A modern, feature-rich mobile translator application built with Flutter that provides completely offline translation capabilities using Google ML Kit.

## Features

- **100% Offline**: Complete offline translation using Google ML Kit models
- **Privacy-First**: All translations happen locally on your device
- **Fast Performance**: Instant translations with downloaded models
- **Modern UI**: Beautiful, intuitive interface with smooth animations and gradients
- **Text-to-Speech**: Listen to translations in multiple languages
- **Share & Copy**: Easy sharing and clipboard functionality
- **Translation History**: Keep track of your translations
- **Model Management**: Download, manage, and delete offline language models
- **No Internet Required**: Works completely without internet connection

## Offline Translation Setup

The app includes a powerful offline translation system using Google ML Kit:

1. **Access Model Management**: Tap the download icon in the app bar
2. **Download Models**: Select languages you want to use offline
3. **Automatic Fallback**: The app automatically uses offline models when available

### Supported Offline Languages

The app supports 40+ languages for offline translation including:
- Swahili, English, Spanish, French, German, Italian, Portuguese
- Russian, Japanese, Korean, Chinese, Arabic, Hindi
- And many more...

## Architecture

The app follows Clean Architecture principles with:

### Presentation Layer
- **BLoC Pattern**: State management with `flutter_bloc`
- **Modern UI**: Custom widgets with animations and gradients
- **Responsive Design**: Adapts to different screen sizes

### Domain Layer
- **Use Cases**: Business logic for translation operations
- **Repository Interfaces**: Abstract data access contracts
- **Entities**: Core business objects

### Data Layer
- **Hybrid Data Source**: Combines local and remote translation
- **Local Translation Service**: Google ML Kit integration
- **Remote Data Source**: DeepL API integration
- **Repository Implementation**: Concrete data access

### Core Layer
- **Services**: Clipboard, Text-to-Speech, Share functionality
- **Constants**: App-wide configuration
- **Error Handling**: Comprehensive exception management
- **Environment Config**: Secure API key management

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

