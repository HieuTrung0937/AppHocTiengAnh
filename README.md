# STUDYSPACE - ỨNG DỤNG HỌC TỪ VỰNG TIẾNG ANH CÁ NHÂN HÓA

## 1. TỔNG QUAN DỰ ÁN
Dự án StudySpace hướng đến việc giải quyết tình trạng người học gặp những từ vựng thông dụng nhưng thường xuyên không nhớ nghĩa hoặc cách sử dụng trong ngữ cảnh thực tế. Thay vì học theo lộ trình cứng nhắc, ứng dụng cho phép người dùng nhanh chóng ghi chú lại những từ vựng mình vừa gặp và quên. Hệ thống sau đó sẽ tự động tổng hợp, phân tích và sắp xếp thành một danh sách từ vựng cá nhân, giúp việc học trở nên chủ động và tập trung vào đúng những lỗ hổng kiến thức của từng người.

## 2. VẤN ĐỀ CẦN GIẢI QUYẾT
- Người học thường xuyên bắt gặp các từ vựng mới trong sách, báo, đề thi nhưng không có cách ghi chép nhanh và tiện lợi.
- Các phương pháp học từ vựng truyền thống thường mang tính đại trà, không phân biệt được từ nào người học đã nhớ và từ nào hay quên.
- Thiếu ngữ cảnh thực tế khiến người học khó nhớ lâu và không biết cách áp dụng từ vựng vào thực tiễn.

## 3. GIẢI PHÁP VÀ TÍNH NĂNG CỐT LÕI
Dự án cung cấp một hệ sinh thái học tập khép kín, ưu tiên hoạt động offline (Local-first) với các tính năng chính:

### 3.1. Ghi chú và Quét nhanh (OCR Quick-Add)
Cho phép người dùng chụp ảnh sách, tài liệu hoặc nhập thủ công để trích xuất và lưu từ vựng ngay lập tức chỉ với một thao tác chạm.

### 3.2. Hồ sơ từ vựng chi tiết
Mỗi từ vựng được lưu trữ kèm theo nghĩa, cách phát âm (Text-to-Speech), ví dụ minh họa và ngữ cảnh sử dụng cụ thể (đoạn văn gốc chứa từ vựng).

### 3.3. Hệ thống Ôn tập Thông minh (Spaced Repetition)
Sử dụng thuật toán AI tùy chỉnh để tính toán điểm ưu tiên ôn tập (Priority Score). Công thức tính toán dựa trên 3 yếu tố: thời gian kể từ lần ôn cuối, tỷ lệ trả lời sai và độ khó của từ.

### 3.4. Bảng điều khiển và Thống kê (Dashboard & Analytics)
Theo dõi tiến độ học tập, chuỗi ngày học liên tiếp (streak) và trực quan hóa danh sách các từ vựng hay quên nhất thông qua biểu đồ.

## 4. ĐIỂM NỔI BẬT: CÁ NHÂN HÓA BẰNG AI
Điểm khác biệt lớn nhất của dự án nằm ở cơ chế "Học thích ứng" (Adaptive Learning). Hệ thống không yêu cầu người dùng tự phân loại từ vựng theo lớp hay giáo trình một cách thủ công. Thay vào đó, thuật toán sẽ tự động đánh dấu và ưu tiên đẩy những từ người dùng quên nhiều lần lên đầu danh sách ôn tập. Qua đó, ứng dụng tự động cá nhân hóa lộ trình học, đảm bảo người dùng chỉ dành thời gian cho những từ vựng họ thực sự chưa nắm vững.

## 5. CÔNG NGHỆ SỬ DỤNG
- Framework: Flutter (Dart)
- Kiến trúc: Feature-first, Modular Architecture
- Cơ sở dữ liệu: SQLite (Local-first / Offline-first)
- AI & Machine Learning: Google ML Kit (OCR Offline), Thuật toán Spaced Repetition tùy chỉnh
- Tiện ích: Camera API, Flutter TTS (Text-to-Speech), FL Chart
