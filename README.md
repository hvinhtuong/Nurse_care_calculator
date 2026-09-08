# Nurse Care Calculator VN 🩺

Ứng dụng di động mã nguồn mở hoạt động hoàn toàn offline, hỗ trợ nhân viên điều dưỡng và cán bộ y tế thực hiện các đánh giá lâm sàng, tính toán liều lượng và chỉ số chăm sóc nhanh chóng, chuẩn xác.

---

## 📌 Tính năng chính

Ứng dụng cung cấp 10 công cụ lâm sàng thiết yếu:

* **Thang điểm & Đánh giá lâm sàng:**
  * **NRS (Numeric Rating Scale):** Đánh giá mức độ đau theo thang điểm số.
  * **GCS (Glasgow Coma Scale):** Đánh giá mức độ tri giác, hôn mê.
  * **NEWS2:** Thang cảnh báo sớm mức độ suy giảm lâm sàng.
  * **Braden Scale:** Đánh giá nguy cơ loét tì đè.
  * **Morse Fall Scale:** Đánh giá nguy cơ té ngã ở người bệnh.

* **Tính toán dịch truyền & Dược lâm sàng:**
  * **Tốc độ truyền dịch:** Tính tốc độ giọt/phút và ml/giờ dựa theo hệ số giọt.
  * **Bilan dịch:** Cân bằng lượng dịch vào - ra trong ngày.
  * **Lượng nước tiểu (ml/kg/giờ):** Theo dõi chức năng bài tiết nước tiểu theo cân nặng và thời gian.
  * **Tốc độ bơm tiêm điện:** Hỗ trợ tính toán liều thuốc và tốc độ truyền chính xác.
  * **Chỉ số BMI:** Đánh giá tình trạng thể trạng, dinh dưỡng.

* **Lưu trữ & Lịch sử:**
  * Lưu trữ kết quả tính toán vào cơ sở dữ liệu SQLite ngay trên thiết bị.
  * Xem lại và xóa lịch sử tính toán dễ dàng.
  * Hoạt động 100% không cần kết nối Internet (Offline-first).

---

## 🛠️ Công nghệ sử dụng

* **Framework:** Flutter (Material 3)
* **Ngôn ngữ:** Dart
* **Cơ sở dữ liệu:** SQLite (`sqflite`)
* **Nền tảng hỗ trợ:** Android / iOS

---

## 📂 Cấu trúc thư mục

```text
lib/
├── database/            # Quản lý SQLite database helper
├── models/              # Data models (Lịch sử, Tool item)
├── screens/             # Màn hình chính (Home, History)
├── tools/               # Màn hình giao diện và logic của 10 công cụ tính toán
├── widgets/             # Các widget tái sử dụng (Clinical info sheet, UI components)
└── main.dart            # Điểm khởi chạy ứng dụng
