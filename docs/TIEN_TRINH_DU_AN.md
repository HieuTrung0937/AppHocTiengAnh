# TIEN TRINH DU AN: APP HOC TIENG ANH (STUDYSPACE)

## 1. TOM TAT DU AN
- Ngon ngu: Flutter (Dart)
- Kien truc: Feature-first, Local-first, Offline-first
- Thuat toan: AI Spaced Repetition (Priority = w1*Time + w2*ErrorRate + w3*Difficulty)
- Trang thai hien tai: Da hoan thanh khung giao dien chinh va cau truc core.

## 2. DA HOAN THANH (COMPLETED)

### Cau truc va Cau hinh
- [x] Khoi tao du an Flutter va thiet lap cau truc thu muc Modular.
- [x] Thiet lap Theme (AppTheme, AppColors, AppTypography) theo Figma.
- [x] Cau hinh AndroidManifest.xml (Quyen Camera, Audio, Storage).
- [x] Sua loi Kotlin DSL trong build.gradle.kts (dat minSdk = 24 cho ML Kit).
- [x] Tao AudioFocusService de xu ly xung dot am thanh voi app khac.

### Core Logic
- [x] Xay dung VocabModel tich hop thuat toan AI Priority.
- [x] Them getter dynamicStatus de tu dong phan loai trang thai hoc ("Hay quen", "Tu moi", "Da thuoc").
- [x] Tao LocalDatabase gia lap du lieu mau de test UI.

### Giao dien (UI)
- [x] HomeScreen: Dashboard day du (Greeting, Calendar, Progress, Statistics, Plan).
- [x] ScannerScreen: Giao dien Camera voi viewport va nut chup (Da test thanh cong tren thiet bi).
- [x] VocabularyScreen: Thay doi bo loc tu "Lop 10/11/12" sang trang thai dong (Dynamic status).

## 3. DANG THUC HIEN (IN PROGRESS)
- [ ] Tich hop Google ML Kit Text Recognition vao ScannerScreen de trich xuat van ban tu anh.

## 4. CAN THUC HIEN (TO DO)

### Tinh nang chinh
- [ ] WordSelectionScreen: Hien thi ket qua OCR, cho phep nguoi dung chon tu de luu.
- [ ] ReviewScreen: Giao dien Flashcard lat 2 mat + 4 nut danh gia (Quen, Kho, Tot, De).
- [ ] QuizScreen: Giao dien kiem tra trac nghiem + dien tu + luyen nghe.
- [ ] AddVocabModal: Form nhap tu vung thu cong.

### Du lieu va Tich hop
- [ ] Thay the LocalDatabase gia lap bang SQLite (su dung sqflite) de luu tru that.
- [ ] Tich hop Flutter TTS (Text-to-Speech) de phat am tu vung (kem AudioFocus).
- [ ] Tich hop fl_chart de ve bieu do tien do o man hinh Home/Statistics.
- [ ] Import bo du lieu tu vung SGK (dang JSON hoac CSV) vao SQLite.

## 5. VAN DE DA XU LY VA LUU Y (KNOWN ISSUES & FIXES)
- [x] Loi MissingPluginException khi them thu vien camera: Da xu ly bang flutter clean va build lai.
- [x] Loi build.gradle.kts (Kotlin DSL syntax error): Da chuyen sang cu phap gan (=) thay vi Groovy.
- [x] Loi INSTALL_FAILED_USER_RESTRICTED tren dien thoai Xiaomi: Da bat "Cai dat qua USB" va "Go loi USB (Cai dat bao mat)".
- [x] Xung dot Audio Focus (app de phuong tien): Da tao AudioFocusService va cau hinh transient focus.
