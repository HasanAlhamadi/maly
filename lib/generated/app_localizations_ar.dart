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
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get amount => 'المبلغ';

  @override
  String get description => 'الوصف';

  @override
  String get date => 'التاريخ';

  @override
  String get transactionType => 'نوع المعاملة';

  @override
  String get credit => 'لـي (دائن)';

  @override
  String get debit => 'علىـي (مدين)';

  @override
  String get creditDesc => 'ليستحق لي';

  @override
  String get debitDesc => 'أستحق علي';

  @override
  String get totalOwedToYou => 'إجمالي مستحق لك';

  @override
  String get totalYouOwe => 'إجمالي مستحق عليك';

  @override
  String get netBalance => 'الرصيد الصافي';

  @override
  String get owesYou => 'يستحق لك';

  @override
  String get youOwe => 'أنت تستحق على';

  @override
  String get settled => 'تسوية';

  @override
  String get noPersons => 'لا يوجد أشخاص';

  @override
  String get noPersonsSubtitle => 'اضغط + لإضافة شخص';

  @override
  String get noTransactions => 'لا توجد معاملات';

  @override
  String get noTransactionsSubtitle => 'أضف معاملتك الأولى';

  @override
  String get deletePersonTitle => 'حذف الشخص؟';

  @override
  String get deletePersonMessage => 'سيتم حذف جميع المعاملات أيضاً.';

  @override
  String get deleteTransactionTitle => 'حذف المعاملة؟';

  @override
  String get currency => 'ريال';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get transactions => 'المعاملات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

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
  String get search => 'بحث';

  @override
  String get balance => 'الرصيد';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get newPerson => 'شخص جديد';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get invalidAmount => 'أدخل مبلغاً صحيحاً';
}
