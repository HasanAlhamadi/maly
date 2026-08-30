// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ديوني';

  @override
  String get persons => 'الأشخاص';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get editPerson => 'تعديل شخص';

  @override
  String get personName => 'الاسم';

  @override
  String get personPhone => 'رقم الهاتف';

  @override
  String get personNotes => 'ملاحظات';

  @override
  String get save => 'حفظ';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get undo => 'تراجع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get amount => 'المبلغ';

  @override
  String get description => 'الوصف';

  @override
  String get date => 'التاريخ';

  @override
  String get transactionType => 'نوع المعاملة';

  @override
  String get credit => 'لي';

  @override
  String get debit => 'عليّ';

  @override
  String get creditDesc => 'يستحق لي';

  @override
  String get debitDesc => 'أنا مدين له';

  @override
  String get totalOwedToYou => 'مستحق لك';

  @override
  String get totalYouOwe => 'مستحق عليك';

  @override
  String get netBalance => 'الرصيد الصافي';

  @override
  String get owesYou => 'يستحق لك';

  @override
  String get youOwe => 'أنت مدين بـ';

  @override
  String get settled => 'مُسوّى';

  @override
  String get allSettled => 'لا توجد ديون';

  @override
  String get noPersons => 'لا يوجد أشخاص';

  @override
  String get noPersonsSubtitle => 'أضف شخصاً لبدء تتبع الديون';

  @override
  String get noTransactions => 'لا توجد معاملات';

  @override
  String get noTransactionsSubtitle => 'أضف معاملتك الأولى';

  @override
  String get deletePersonTitle => 'حذف الشخص؟';

  @override
  String get deletePersonMessage => 'سيتم حذف جميع معاملاته أيضاً.';

  @override
  String get currency => 'ريال';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get searchPeople => 'ابحث عن شخص';

  @override
  String get noSearchResults => 'لا توجد نتائج مطابقة';

  @override
  String get balance => 'الرصيد';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get nameTooLong => 'الاسم طويل جداً';

  @override
  String get amountRequired => 'المبلغ مطلوب';

  @override
  String get invalidAmount => 'أدخل مبلغاً صحيحاً';

  @override
  String get personAdded => 'تمت إضافة الشخص';

  @override
  String get personUpdated => 'تم تحديث الشخص';

  @override
  String get personDeleted => 'تم حذف الشخص';

  @override
  String get transactionAdded => 'تمت إضافة المعاملة';

  @override
  String get transactionDeleted => 'تم حذف المعاملة';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get youAreOwed => 'لك';

  @override
  String get youOweOthers => 'عليك';

  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get exportData => 'تصدير نسخة احتياطية';

  @override
  String get exportDataSubtitle => 'احفظ جميع بياناتك في ملف';

  @override
  String get importData => 'استعادة نسخة احتياطية';

  @override
  String get importDataSubtitle => 'استبدل بياناتك من ملف';

  @override
  String get exportSuccess => 'تم حفظ النسخة الاحتياطية';

  @override
  String get importSuccess => 'تمت استعادة النسخة الاحتياطية';

  @override
  String get importWarningTitle => 'استعادة النسخة الاحتياطية؟';

  @override
  String get importWarningMessage =>
      'سيؤدي هذا إلى استبدال جميع الأشخاص والمعاملات الحالية. لا يمكن التراجع.';

  @override
  String get invalidBackupFile => 'هذا الملف ليس نسخة احتياطية صالحة';

  @override
  String get settleUp => 'تسوية الحساب';

  @override
  String get settleUpTitle => 'تسوية الحساب؟';

  @override
  String get settleUpMessage => 'سيتم تسجيل عملية واحدة تجعل الرصيد صفراً.';

  @override
  String get settledPayment => 'تسوية الحساب';

  @override
  String get balanceSettled => 'تمت تسوية الرصيد';

  @override
  String get editTransaction => 'تعديل المعاملة';

  @override
  String get transactionUpdated => 'تم تحديث المعاملة';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get noDueDate => 'بدون تاريخ استحقاق';

  @override
  String get clear => 'مسح';

  @override
  String get due => 'يستحق';

  @override
  String get overdue => 'متأخر';

  @override
  String get paymentDue => 'دفعة مستحقة';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get monthlyActivity => 'النشاط الشهري';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get topDebtors => 'الأكثر استحقاقاً لك';

  @override
  String get noStatsYet => 'لا يوجد ما يُعرض بعد';

  @override
  String get noStatsYetSubtitle => 'أضف بعض المعاملات لعرض نشاطك';

  @override
  String get importFromContacts => 'اختر من جهات الاتصال';

  @override
  String get contactsPermissionDenied => 'لم يتم منح إذن الوصول لجهات الاتصال';
}
