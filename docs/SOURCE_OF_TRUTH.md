# مرجع وثائق Myfunt / Mivent

هذا الملف يحدد المصدر الرسمي للوثائق والمواصفات التي يجب الرجوع إليها عند تطوير تطبيق Flutter.

## المستودع المرجعي

[Myfunt Sources](https://github.com/KAYANSTOR/Myfunt-Sources)

يحتوي المستودع المرجعي على مواصفات المنتج، خرائط الشاشات والتدفقات، نموذج البيانات، عقود المزامنة وواجهات API، سياسات المصادقة والخطط، اختبارات القبول، وتسلسل نقل التطبيق إلى Flutter.

## قاعدة الاعتماد

- تُعد الوثائق الموجودة في مستودع **Myfunt Sources** المصدر الأساسي عند اتخاذ قرارات المنتج أو البيانات أو واجهات التطبيق.
- قبل تنفيذ تغيير كبير، يجب مراجعة الوثائق والعقود ذات الصلة في المستودع المرجعي.
- عند وجود تعارض بين سلوك التطبيق الحالي والوثائق المرجعية، يجب توثيق التعارض ومعالجته وفق أحدث عقد أو مواصفة معتمدة.
- أي تغيير في بنية البيانات أو تدفقات الاستخدام أو عقود المزامنة ينبغي أن يحدّث الوثائق المرجعية بالتزامن.

## أهم نقاط البدء

- [المصدر الأساسي](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/00_SOURCE_OF_TRUTH.md)
- [مواصفات المنتج](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/01_PRODUCT_SPEC.md)
- [خريطة الشاشات والتدفقات](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/02_SCREEN_MAP_AND_FLOWS.md)
- [نموذج البيانات](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/04_DOMAIN_DATA_MODEL.md)
- [عقد المزامنة وواجهة API](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/06_SYNC_API_CONTRACT.md)
- [اختبارات القبول](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/13_ACCEPTANCE_TESTS.md)
- [تسلسل نقل التطبيق إلى Flutter](https://github.com/KAYANSTOR/Myfunt-Sources/blob/main/docs/15_FLUTTER_PORTING_SEQUENCE.md)
