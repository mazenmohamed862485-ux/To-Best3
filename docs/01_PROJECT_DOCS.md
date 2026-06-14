# TO Best — وثائق المشروع الشاملة

> **الإصدار:** 8.2.0 | **آخر تحديث:** 2025

---

## 1. فكرة المشروع

**TO Best** هو تطبيق متكامل لإدارة التدريب والتغذية يعمل تحت إشراف مدرب شخصي.  
يتصل التطبيق بـ Google Sheets / Apps Script كـ Backend ويوفر:

- 📋 برنامج تمرين شخصي مع تسجيل مفصّل للجلسات
- 🥗 تتبع التغذية والماء يومياً
- 📅 تتبع الإلتزام الشهري
- 📊 قياسات الجسم ورسوم بيانية للتقدم
- 💬 دردشة متعددة الغرف مع الكوتش
- 👤 إدارة الملف الشخصي والاشتراك
- 🛡️ لوحة إدارة كاملة للـ Admin/Super Admin

---

## 2. المعمارية التقنية

```
Backend:   Google Apps Script + Google Sheets (Web App URL)
Frontend:  Flutter 3.22+ (Android أولاً)
State:     Riverpod 2.x
Routing:   GoRouter
Cache:     SQLite (sqflite) — مؤقت فقط، السيرفر هو المصدر الأساسي
Sync:      SyncService — Queue + Retry عند توفر الإنترنت
```

### بنية المشروع

```
to_best/
├── lib/
│   ├── main.dart                    # نقطة الدخول
│   ├── app.dart                     # Router + Theme + Locale providers
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart   # ثوابت عامة
│   │   │   ├── app_colors.dart      # لوحة الألوان
│   │   │   └── api_constants.dart   # أسماء الـ actions
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Dark/Light theme
│   │   ├── utils/
│   │   │   ├── validators.dart      # التحقق من المدخلات
│   │   │   ├── date_helper.dart     # مساعدات التاريخ
│   │   │   └── extensions.dart      # Extensions على Flutter
│   │   └── errors/
│   │       └── app_error.dart       # نموذج الأخطاء
│   ├── services/
│   │   ├── api_service.dart         # HTTP layer (Dio)
│   │   ├── cache_service.dart       # SQLite cache
│   │   ├── sync_service.dart        # Offline sync queue
│   │   ├── secure_storage_service.dart  # keystore/token
│   │   └── update_service.dart      # فحص التحديثات
│   ├── features/
│   │   ├── auth/                    # تسجيل دخول/خروج
│   │   ├── home/                    # الشاشة الرئيسية
│   │   ├── workout/                 # التمرين
│   │   ├── nutrition/               # التغذية
│   │   ├── attendance/              # الإلتزام
│   │   ├── progress/                # التقدم
│   │   ├── chat/                    # الدردشة
│   │   ├── profile/                 # الملف الشخصي + الإعدادات
│   │   ├── admin/                   # لوحة الإدارة
│   │   └── update/                  # شاشة التحديث
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── common_widgets.dart      # Avatar, StatCard, MacroBar...
│       └── main_shell.dart          # Bottom navigation shell
├── android/                         # Android native config
├── assets/icons/                    # Logo dark + light
├── l10n/                            # app_ar.arb + app_en.arb
├── docs/                            # هذه الوثائق
├── codemagic.yaml                   # CI/CD
└── pubspec.yaml
```

---

## 3. الشاشات والوظائف

### 3.1 شاشة السبلاش (`/splash`)
- تشغيل الـ animation
- فحص التحديثات عبر `UpdateService`
- إذا كان التحديث إجبارياً: حجب الدخول + زر تحميل
- إذا كان اختيارياً: Dialog يسمح بالتأجيل
- توجيه المستخدم تلقائياً بحسب حالة الجلسة

### 3.2 تسجيل الدخول (`/login`)
- حقل Web App URL + Secret Key (إعداد أولي مخزّن في FlutterSecureStorage)
- تسجيل دخول بالبريد/كلمة المرور
- دخول كضيف بكود
- رابط لإنشاء حساب ونسيان كلمة المرور

### 3.3 إنشاء حساب (`/register`)
- الاسم، البريد، الهاتف، كلمة المرور
- كود خصم (promo) واختياري
- كود إحالة اختياري

### 3.4 الرئيسية (`/home`)
- تحية مخصصة بالاسم والوقت
- بطاقات: إلتزام اليوم، سعرات اليوم
- تسجيل حضور اليوم (جيم / راحة / غياب)
- ملخص التمرين والتغذية اليوم
- تنبيه انتهاء الاشتراك

### 3.5 التمرين (`/workout`)
- عرض البرنامج الحالي
- اختيار الجلسة (UL/AP/FB/ARNOLD/PPL/CUSTOM)
- تسجيل مفصّل: اسم التمرين، العضلة، السيتات، الوزن، التكرارات
- كشف الـ PR تلقائياً (🏆)
- عرض تاريخ التمرين ومقارنة القيم السابقة
- تبويب السجل التاريخي

### 3.6 التغذية (`/nutrition`)
- ملخص السعرات والماكروز (progress bars)
- إضافة وجبات مع التصنيف (إفطار/غداء/عشاء/سناك)
- تتبع شرب الماء (أزرار +0.25L)
- حذف وجبة بالـ Swipe

### 3.7 الإلتزام (`/attendance`)
- تقويم شهري تفاعلي
- إحصائيات (جيم / راحة / غياب)
- تسجيل أي يوم بالضغط عليه
- تنقل بين الأشهر

### 3.8 التقدم (`/progress`)
- إضافة قياسات جسم مفصّلة (وزن، دهون، صدر، خصر...)
- رسم بياني لمنحنى الوزن (fl_chart)
- قائمة تاريخية بكل القياسات

### 3.9 الدردشة (`/chat`)
- 3 غرف: عام، إعلانات، دعم
- إعلانات: للكتابة فيها Admin فقط
- رد على رسالة، تعديل، حذف، تثبيت (للـ Admin)
- رسالة مثبتة في أعلى الشاشة
- Polling كل 10 ثوانٍ
- cache محلي للرسائل

### 3.10 الملف الشخصي (`/profile`)
- صورة + الاسم + الدور
- تغيير صورة الملف الشخصي (رفع للسيرفر)
- حالة الاشتراك + إمكانية التجديد
- البرنامج الحالي
- كود الإحالة والنقاط
- تغيير كلمة المرور
- تسجيل الخروج

### 3.11 الإعدادات (`/settings`)
- ثيم: داكن / فاتح / نظام
- لون التطبيق (8 خيارات)
- اللغة: عربي (RTL) / إنجليزي (LTR)
- معلومات الإصدار

### 3.12 لوحة الإدارة (`/admin`) — للـ Admin/Super Admin فقط
- **المستخدمون:** بحث، قبول/تعليق/حذف، تسجيل خروج قسري
- **الطلبات:** قبول/رفض طلبات الاشتراك
- **الأكواد:** إنشاء/حذف أكواد الخصم (Super Admin)
- **الضيوف:** أكواد الدخول كضيف
- **المحظورون:** عرض + رفع الحظر

---

## 4. نظام التحديث

### آلية العمل
```
التطبيق يرسل إلى السيرفر: { action: CHECK_VERSION, version, build }
السيرفر يرد بـ:
  { updateStatus: 'none' | 'optional' | 'required' | 'blocked',
    latestVersion: '8.3.0',
    downloadUrl: 'https://...',
    message: '...' }
```

### أنواع التحديث
| النوع | السلوك |
|-------|---------|
| `none` | لا شيء، التطبيق يعمل عادياً |
| `optional` | Dialog يسمح بـ "لاحقاً" أو "تحديث الآن" |
| `required` | شاشة محجوبة + زر تحميل فقط، لا يمكن التجاوز |
| `blocked` | مثل required لكن بسبب حظر صريح للنسخة |

### كيفية تحديثه مستقبلاً
في Google Apps Script (Code.gs)، ابحث عن `CHECK_VERSION` وأضف:
```javascript
case 'CHECK_VERSION': {
  const clientVersion = params.version;
  const clientBuild   = parseInt(params.build || '0');
  const minBuild      = 2;   // ← غيّر هذا لإجبار التحديث
  const latestVersion = '8.3.0';
  const downloadUrl   = 'https://your-download-link.com/to_best.apk';
  
  if (clientBuild < minBuild) {
    return { updateStatus: 'required', latestVersion, downloadUrl,
             message: 'هذه النسخة قديمة. يرجى التحديث.' };
  }
  if (clientBuild < 5) {  // optional update threshold
    return { updateStatus: 'optional', latestVersion, downloadUrl };
  }
  return { updateStatus: 'none' };
}
```

---

## 5. المزامنة وإدارة البيانات

### تسلسل الأولوية
```
1. السيرفر (المصدر الأساسي دائماً)
2. SQLite Cache (عرض سريع ريثما يأتي الجواب من السيرفر)
3. SyncQueue (للعمليات أثناء انقطاع الإنترنت)
```

### دورة المزامنة
```
تعديل بيانات ←→ يُحفظ في SQLite فوراً
                ←→ يُضاف إلى SyncQueue
                ←→ يُرسل إلى السيرفر (فوري إذا متصل)
                ←→ يُعاد المحاولة كل 30 ثانية
                ←→ يُحذف من Queue عند النجاح
```

---

## 6. الأدوار والصلاحيات

| الدور | الصلاحيات |
|-------|-----------|
| `SUPER_ADMIN` | كل شيء + حذف المستخدمين + إنشاء/حذف الأكواد |
| `ADMIN` | لوحة إدارة كاملة عدا الحذف وبعض الأكواد |
| `COACH` | وصول محدود للإدارة |
| `TRAINEE` | كل الميزات الأساسية |
| `VIEWER` | قراءة فقط |

---

## 7. الخدمات الخارجية

| الخدمة | الغرض |
|--------|-------|
| Google Apps Script | Backend API |
| Google Sheets | قاعدة البيانات |
| Google Drive | روابط فيديوهات التمارين |
| FlutterSecureStorage | حفظ التوكن والمفتاح السري |
| SQLite (sqflite) | Cache محلي مؤقت |

---

## 8. إعداد السيرفر (Web App URL)

1. افتح التطبيق لأول مرة
2. اضغط على "إعدادات السيرفر"
3. أدخل رابط الـ Web App URL من Google Apps Script
4. أدخل المفتاح السري (إذا كان محدداً في السيرفر)
5. اضغط "حفظ الإعدادات"

**ملاحظة:** يُخزَّن الرابط والمفتاح في FlutterSecureStorage (مشفّر).
