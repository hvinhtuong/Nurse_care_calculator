# Nurse Care Calculator VN 🩺

Ứng dụng di động mã nguồn mở hoạt động hoàn toàn offline, hỗ trợ nhân viên điều dưỡng và cán bộ y tế thực hiện các đánh giá lâm sàng, tính toán liều lượng và chỉ số chăm sóc nhanh chóng, chuẩn xác[cite: 1].

---

## 📌 Tính năng chính

Ứng dụng cung cấp 10 công cụ lâm sàng thiết yếu[cite: 1]:

* **Thang điểm & Đánh giá lâm sàng:**
  * **NRS (Numeric Rating Scale):** Đánh giá mức độ đau theo thang điểm số[cite: 1].
  * **GCS (Glasgow Coma Scale):** Đánh giá mức độ tri giác, hôn mê[cite: 1].
  * **NEWS2:** Thang cảnh báo sớm mức độ suy giảm lâm sàng[cite: 1].
  * **Braden Scale:** Đánh giá nguy cơ loét tì đè[cite: 1].
  * **Morse Fall Scale:** Đánh giá nguy cơ té ngã ở người bệnh[cite: 1].

* **Tính toán dịch truyền & Dược lâm sàng:**
  * **Tốc độ truyền dịch:** Tính tốc độ giọt/phút và ml/giờ dựa theo hệ số giọt[cite: 1].
  * **Bilan dịch:** Cân bằng lượng dịch vào - ra trong ngày[cite: 1].
  * **Lượng nước tiểu (ml/kg/giờ):** Theo dõi chức năng bài tiết nước tiểu theo cân nặng và thời gian[cite: 1].
  * **Tốc độ bơm tiêm điện:** Hỗ trợ tính toán liều thuốc và tốc độ truyền chính xác[cite: 1].
  * **Chỉ số BMI:** Đánh giá tình trạng thể trạng, dinh dưỡng[cite: 1].

* **Lưu trữ & Lịch sử:**
  * Lưu trữ kết quả tính toán vào cơ sở dữ liệu SQLite ngay trên thiết bị[cite: 1].
  * Xem lại và xóa lịch sử tính toán dễ dàng[cite: 1].
  * Hoạt động 100% không cần kết nối Internet (Offline-first)[cite: 1].

---

## 🛠️ Công nghệ sử dụng

* **Framework:** Flutter (Material 3)[cite: 1]
* **Ngôn ngữ:** Dart
* **Cơ sở dữ liệu:** SQLite (`sqflite`)[cite: 1]
* **Nền tảng hỗ trợ:** Android / iOS[cite: 1]

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
