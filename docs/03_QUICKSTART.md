# TO Best — Quick Start للمطور

---

## ⚡ تشغيل المشروع في 5 دقائق

### المتطلبات
```bash
flutter --version   # يجب أن يكون 3.22.0+
java -version       # يجب أن يكون 17+
```

### الخطوات
```bash
# 1. استنسخ المشروع
git clone https://github.com/YOUR_ORG/to_best.git
cd to_best

# 2. تثبيت المكتبات
flutter pub get

# 3. توليد ملفات الترجمة
flutter gen-l10n

# 4. التأكد من المتطلبات
flutter doctor

# 5. تشغيل التطبيق (debug)
flutter run
```

---

## 🔧 الإعداد الأولي

### إعداد رابط السيرفر
عند تشغيل التطبيق لأول مرة:
1. اضغط **"إعدادات السيرفر"** في شاشة الدخول
2. أدخل **Web App URL** من Google Apps Script
3. أدخل **Secret Key** (اختياري)
4. اضغط **"حفظ"**

### إعداد ملف `.env` (للتطوير)
لا يستخدم المشروع متغيرات بيئة في runtime — الـ URL يُخزَّن في `FlutterSecureStorage` عبر واجهة المستخدم.

---

## 📁 هيكل الملفات الرئيسية

```
lib/
├── main.dart          ← نقطة الدخول (init cache + sync)
├── app.dart           ← Router + Theme + Locale
├── core/              ← ثوابت، ألوان، theme، utils
├── services/
│   ├── api_service.dart       ← كل calls للسيرفر
│   ├── cache_service.dart     ← SQLite (بيانات مؤقتة)
│   └── sync_service.dart      ← Queue + retry
├── features/
│   ├── auth/          ← Login, Register, ForgotPassword
│   ├── home/          ← Dashboard
│   ├── workout/       ← تمرين + سجل
│   ├── nutrition/     ← وجبات + ماء
│   ├── attendance/    ← تقويم
│   ├── progress/      ← قياسات + charts
│   ├── chat/          ← دردشة (polling)
│   ├── profile/       ← ملف + إعدادات
│   └── admin/         ← لوحة الإدارة
└── widgets/           ← widgets مشتركة
```

---

## 🛠️ أوامر مفيدة

```bash
# تشغيل مع hot-reload
flutter run

# تشغيل في وضع release (أسرع للاختبار)
flutter run --release

# بناء APK debug
flutter build apk --debug

# بناء APK release
flutter build apk --release

# بناء AAB
flutter build appbundle --release

# تنظيف ملفات البناء
flutter clean && flutter pub get

# فحص المشكلات
flutter analyze

# تشغيل الاختبارات
flutter test

# تحديث المكتبات
flutter pub upgrade

# عرض المكتبات القديمة
flutter pub outdated
```

---

## 🔨 إضافة ميزة جديدة (الطريقة الصحيحة)

```
1. أنشئ model في: features/FEATURE/models/
2. أنشئ provider في: features/FEATURE/providers/
3. أنشئ screen في: features/FEATURE/screens/
4. أضف API call في: services/api_service.dart
5. أضف Route في: app.dart
6. أضف زر في: widgets/main_shell.dart (إذا لزم)
7. أضف ترجمة في: l10n/app_ar.arb + app_en.arb
8. شغّل: flutter gen-l10n
```

---

## 🧩 إضافة Provider جديد

```dart
// مثال: providers/my_feature_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyState {
  final List<String> items;
  const MyState({this.items = const []});
}

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(const MyState());
  
  void addItem(String item) {
    state = MyState(items: [...state.items, item]);
  }
}

final myProvider = StateNotifierProvider<MyNotifier, MyState>(
    (_) => MyNotifier());
```

---

## 📡 إضافة API call جديد

في `lib/services/api_service.dart`:
```dart
Future<Map<String, dynamic>?> myNewCall(String uid) async {
  return _post({'action': 'MY_ACTION', 'uid': uid});
}
```

في `Code.gs` (السيرفر):
```javascript
case 'MY_ACTION': {
  const { uid } = params;
  // ... منطق السيرفر
  return { ok: true, data: result };
}
```

---

## 🌐 إضافة ترجمة جديدة

1. أضف في `l10n/app_ar.arb`:
```json
"myKey": "القيمة العربية"
```
2. أضف في `l10n/app_en.arb`:
```json
"myKey": "English value"
```
3. شغّل:
```bash
flutter gen-l10n
```
4. استخدم في الكود:
```dart
// باستخدام localeProvider
final locale = ref.watch(localeProvider).languageCode;
final isAr   = locale == 'ar';
final text   = isAr ? 'القيمة العربية' : 'English value';
```

---

## 🐛 حل المشكلات الشائعة

| المشكلة | الحل |
|---------|------|
| `Not configured` | تحقق من Web App URL في إعدادات السيرفر |
| `Unauthorized` | تسجيل الخروج وإعادة الدخول |
| `Network error` | تحقق من الإنترنت، التطبيق يخزن مؤقتاً |
| `Build failed` | `flutter clean && flutter pub get` |
| ترجمات مفقودة | `flutter gen-l10n` |
| `Gradle build failed` | تحقق من Java 17 |

---

## 📦 المكتبات الرئيسية

| المكتبة | الغرض |
|---------|-------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `sqflite` | SQLite cache |
| `flutter_secure_storage` | Keystore |
| `shared_preferences` | إعدادات خفيفة |
| `connectivity_plus` | فحص الإنترنت |
| `fl_chart` | الرسوم البيانية |
| `webview_flutter` | تشغيل فيديوهات Drive |
| `image_picker` | رفع الصور |
| `cached_network_image` | تخزين الصور |
| `package_info_plus` | معلومات التطبيق |
| `url_launcher` | فتح روابط خارجية |

---

## 🔄 تحديث نظام التحديثات

لاحقاً عندما تريد إرسال تحديث إجباري أو اختياري:

1. ارفع الـ APK الجديد (Codemagic / يدوياً)
2. احصل على رابط التحميل
3. في `Code.gs`:
```javascript
// ابحث عن case 'CHECK_VERSION'
const minBuild   = 2;        // ← Build رقم أقل من هذا يُجبر التحديث
const latestVer  = '8.3.0';
const dlUrl      = 'https://your-link.com/app.apk';
```
4. احفظ وانشر السكريبت

**كل مستخدم يفتح التطبيق سيرى إشعار التحديث تلقائياً.**
