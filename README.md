# KumQuotes – Ứng dụng Đa Nền Tảng & Thực hành DevOps

>KumQuotes là một dự án cá nhân được xây dựng với mục tiêu thực hành các kỹ năng DevOps. 

---

## Giới thiệu

KumQuotes là một ứng dụng đa nền tảng viết bằng Flutter, tập trung vào trải nghiệm đơn giản và nhẹ nhàng cho người dùng khi đọc và lưu trữ các câu trích dẫn.

Các tính năng chính:

* Khám phá các câu trích dẫn mỗi ngày
* Lưu lại những câu trích dẫn yêu thích

Ứng dụng hiện hỗ trợ:

* Bản Web
* File APK cài đặt cho Android

## Giao diện

### Web
![alt text](/img/image.png)

### Android App
![alt text](/img/image-1.png)
---

## Kiến trúc hạ tầng

Dự án được xây dựng như một môi trường thực hành DevOps với các công cụ phổ biến:

* Quản lý mã nguồn và CI/CD: GitHub và GitHub Actions
* Đóng gói ứng dụng: Docker và Docker Hub
* Triển khai:
    * Firebase Hosting (cho Web tĩnh)
    * Máy ảo Ubuntu 24.04 (chạy Docker container)
    * APK file cho Android
* Monitoring: Zabbix Server và Zabbix Agent
* Alerting: Discord Webhook

---

## Git Workflow

Dự án chia thành 3 nhánh chính:

* `develop`
  Dùng để phát triển tính năng. Mỗi lần push chỉ chạy build để kiểm tra lỗi.

* `staging`
  Môi trường test. Code sẽ được build thành Docker image và push lên Docker Hub.

* `main`
  Môi trường production. Kích hoạt toàn bộ pipeline CI/CD.

---

## CI/CD Pipeline

Pipeline được định nghĩa trong:

[.github/workflows/main.yml](.github/workflows/main.yml)

### 1. Build

* Cài đặt môi trường Flutter
* Build:

    * Web
    * APK

### 2. Dockerize

* Đóng gói bản Web thành Docker image
* Push image lên Docker Hub

### 3. Deploy và Release

* Deploy Web lên Firebase Hosting
* Tạo GitHub Release kèm file APK

### 4. Notify

* Gửi thông báo qua Discord Webhook

---

## Giám sát hệ thống (Monitoring)

Máy ảo Ubuntu chạy Zabbix Agent để gửi dữ liệu về Zabbix Server.

### Giám sát tài nguyên

* CPU
* RAM
* Disk usage

### Giám sát dịch vụ

* Sử dụng phương pháp black-box monitoring
* Zabbix Server gửi http request tới:

> http://192.168.40.99:8888

để kiểm tra ứng dụng có đang hoạt động hay không.

### Cảnh báo

Khi có sự cố như:

* Ứng dụng ngừng hoạt động

Hệ thống sẽ gửi cảnh báo về Discord.

---

## Ghi chú

Đây là project học tập nên ưu tiên trải nghiệm và thử nghiệm hơn là tối ưu production. Mục tiêu chính là hiểu rõ cách các thành phần hoạt động cùng nhau trong một hệ thống thực tế.
