# TO Best — دليل النشر والتوزيع

---

## 1. المتطلبات الأساسية

| الأداة | الإصدار المطلوب |
|--------|----------------|
| Flutter SDK | 3.22.0 أو أحدث |
| Java JDK | 17 |
| Android SDK | API 34 |
| Gradle | 8.6 |

---

## 2. إعداد التوقيع (Keystore)

### أ. إنشاء Keystore جديدة (مرة واحدة فقط)
```bash
keytool -genkey -v \
  -keystore release.keystore \
  -alias tobest \
  -keyalg RSA -keysize 2048 \
  -validity 10000
```
احتفظ بالملف وكلمة المرور في مكان آمن.

### ب. إنشاء `android/key.properties`
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=tobest
storeFile=/path/to/release.keystore
```
⚠️ **لا تضف هذا الملف لـ git**

---

## 3. بناء APK (للتوزيع المباشر)

```bash
cd to_best
flutter pub get
flutter gen-l10n
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --build-name=8.2.0 \
  --build-number=1
```
الملف يكون في: `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. بناء AAB (للـ Google Play)

```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --build-name=8.2.0 \
  --build-number=1
```
الملف يكون في: `build/app/outputs/bundle/release/app-release.aab`

---

## 5. Codemagic (بناء بدون كمبيوتر) ⭐

### إعداد Codemagic:
1. افتح **codemagic.io** وسجّل دخول بـ GitHub/GitLab
2. أضف المشروع (TO Best repository)
3. اختر **codemagic.yaml** كملف الإعداد
4. أضف **Environment Variables** في Codemagic:

| المتغير | القيمة |
|---------|--------|
| `CM_KEYSTORE` | محتوى ملف keystore مُحوَّل إلى Base64 |
| `CM_KEYSTORE_PASSWORD` | كلمة مرور الـ keystore |
| `CM_KEY_PASSWORD` | كلمة مرور الـ key |
| `CM_KEY_ALIAS` | `tobest` |

#### تحويل keystore إلى Base64:
```bash
base64 release.keystore | pbcopy   # macOS
base64 release.keystore            # Linux
```

5. اضغط **Start new build** أو دفع Commit جديد للـ `main` branch

### الناتج:
- `app-release.apk` — جاهز للتوزيع المباشر
- `app-release.aab` — لـ Google Play Store

---

## 6. طرق النشر (بدون كمبيوتر) 🔑

### الطريقة الأولى: Codemagic + رابط مباشر
1. ابنِ الـ APK عبر Codemagic
2. حمّل الـ APK من artifacts
3. ارفعه على **Google Drive** أو **Telegram** أو **Firebase App Distribution**
4. شارك رابط التحميل مع المستخدمين

### الطريقة الثانية: Firebase App Distribution (الأفضل للاختبار)
1. أنشئ مشروع Firebase
2. فعّل **App Distribution**
3. في Codemagic، أضف خطوة:
```yaml
- name: Distribute to Firebase
  script: |
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
      --app $FIREBASE_APP_ID \
      --groups testers \
      --token $FIREBASE_TOKEN
```
4. المستخدمون يستلمون notification مباشرة

### الطريقة الثالثة: GitHub Actions + Releases
```yaml
# .github/workflows/release.yml
name: Release APK
on:
  push:
    tags: ['v*']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.22.3' }
      - run: flutter pub get
      - run: flutter gen-l10n
      - run: flutter build apk --release
      - uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
```
المستخدمون يحمّلون من صفحة Releases مباشرة.

### الطريقة الرابعة: Google Play Store (الرسمية)
1. ارفع الـ AAB على [Google Play Console](https://play.google.com/console)
2. اختر `Internal Testing` ثم `Production`
3. المستخدمون يحدّثون تلقائياً من Store

---

## 7. تحديث نظام الـ Update في التطبيق

عند رفع نسخة جديدة:

1. **رفع APK الجديد** على أي من الطرق أعلاه
2. **في Google Apps Script** (`Code.gs`)، حدّث قيم الـ `CHECK_VERSION`:
```javascript
const minBuild      = NEW_MIN_BUILD;   // ← رقم البناء الأدنى المدعوم
const latestVersion = 'X.Y.Z';
const downloadUrl   = 'https://رابط-التحميل-الجديد';
```
3. المستخدمون يتلقّون إشعار التحديث تلقائياً عند فتح التطبيق

---

## 8. ملاحظات مهمة

- ⚠️ **لا تُشارك ملف `key.properties` أو `release.keystore`** في Git
- ✅ **احتفظ بنسخة احتياطية من Keystore** — بدونها لا يمكن تحديث التطبيق
- 🔑 **الـ `packageName`** هو `com.tobest.app` — لا تغيّره بعد النشر الأول
- 📱 **الحد الأدنى:** Android 6.0 (API 23)
- 📦 **حجم APK المتوقع:** 18-25 MB

---

## 9. التحقق من سلامة الـ APK قبل التوزيع

```bash
# تحقق من التوقيع
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk

# تحقق من الأذونات
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk

# تحقق من الحجم
ls -lh build/app/outputs/flutter-apk/app-release.apk
```
