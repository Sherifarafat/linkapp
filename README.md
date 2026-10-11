# Link

تطبيق Flutter متعدد المنصات. تُبنى واجهة Home تدريجيًا، وصفحتها مسؤولة عن تركيب المكونات المفصولة داخل `presentation/widgets`.

## هيكل المشروع

```text
lib/
├── app/
│   ├── app.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/
│   └── home/
│       └── presentation/
│           ├── pages/
│           │   └── home_page.dart
│           └── widgets/
│               ├── home_header.dart
│               ├── menu_button.dart
│               ├── profile_avatar.dart
│               ├── home_bottom_bar.dart
│               ├── bottom_nav_item.dart
│               └── add_button.dart
└── main.dart

assets/
└── icons/
    ├── icon_01.png
    ├── icon_02.png
    ├── icon_03.png
    └── icon_04.png
```

الألوان العامة موجودة في `lib/app/theme/app_colors.dart`. صورة الأفاتار تُحمّل من رابط الشبكة داخل `profile_avatar.dart`، مع بديل مرئي عند فشل التحميل. تُضاف الأيقونات الجديدة إلى `assets/icons/`، والمجلد مسجل في `pubspec.yaml`.
