# eKYC & NFC trong iOS Finance

eKYC là quy trình định danh khách hàng điện tử. Với app Finance, eKYC thường dùng cho mở tài khoản, nâng hạn mức, xác thực giao dịch lớn hoặc đáp ứng yêu cầu pháp lý.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Chụp giấy tờ | AVFoundation, camera SDK của vendor |
| OCR giấy tờ | Vision, vendor OCR, backend OCR |
| Liveness detection | Vendor SDK, camera/video capture |
| Face matching | Vendor SDK hoặc backend AI |
| Đọc chip CCCD/hộ chiếu | CoreNFC |
| Quản lý workflow | Backend KYC session, state machine |

## Vì sao chọn các công nghệ này?

### AVFoundation

AVFoundation cho phép kiểm soát camera sâu hơn `UIImagePickerController`, phù hợp khi cần căn khung, kiểm tra blur/glare, chụp tự động hoặc overlay hướng dẫn.

Ưu điểm:

- Kiểm soát camera session tốt.
- Tùy biến UI chụp giấy tờ.
- Có thể xử lý frame realtime.
- Phù hợp với flow OCR/liveness tự xây.

Nên chọn khi:

- App cần UX chụp giấy tờ riêng.
- Cần kiểm tra chất lượng ảnh trước khi upload.
- Vendor không cung cấp camera UI phù hợp.

### Vision / Vendor OCR

Vision có thể hỗ trợ nhận diện text, nhưng với giấy tờ tùy thân, vendor OCR hoặc backend OCR thường ổn định hơn vì đã tối ưu cho template giấy tờ, chống glare, blur và fraud.

Ưu điểm vendor/backend:

- Accuracy cao hơn với CCCD/hộ chiếu.
- Có fraud detection.
- Có dashboard/review.
- Dễ cập nhật model mà không cần release app.

Nên chọn vendor/backend khi:

- Sản phẩm cần độ chính xác cao.
- Có yêu cầu audit hoặc review.
- Giấy tờ có nhiều format.

### CoreNFC

CoreNFC dùng để đọc dữ liệu từ chip NFC, ví dụ CCCD hoặc passport theo chuẩn ICAO 9303 nếu luồng nghiệp vụ yêu cầu.

Ưu điểm:

- Đọc dữ liệu trực tiếp từ chip.
- Tăng độ tin cậy so với chỉ OCR ảnh.
- Hỗ trợ xác thực giấy tờ ở mức cao hơn.

Nên chọn khi:

- Business yêu cầu đọc chip.
- Cần xác thực nâng cao cho hạn mức cao.
- Thiết bị target hỗ trợ NFC.

## Cách lựa chọn triển khai

### Dùng SDK vendor

Phù hợp nhất với banking/fintech cần ra sản phẩm nhanh và đáp ứng compliance.

Ưu điểm:

- Có sẵn OCR, liveness, face matching.
- Có dashboard và webhook.
- Ít phải tự xử lý fraud edge case.

Nhược điểm:

- Phụ thuộc vendor.
- SDK có thể nặng.
- UX đôi khi khó tùy biến.
- Chi phí theo lượt xác thực.

### Tự xây một phần

Phù hợp khi chỉ cần scan giấy tờ đơn giản hoặc muốn kiểm soát UX.

Ưu điểm:

- Tùy biến cao.
- Không phụ thuộc hoàn toàn vendor.
- Tối ưu được flow nội bộ.

Nhược điểm:

- Khó đạt accuracy/fraud detection tốt.
- Cần nhiều effort backend/AI.
- Khó audit/compliance hơn.

## Gợi ý workflow

1. App gọi backend tạo KYC session.
2. Backend trả session id hoặc vendor token.
3. App mở flow scan giấy tờ.
4. App thực hiện liveness/selfie.
5. Nếu cần, app đọc NFC bằng CoreNFC.
6. App gửi kết quả/session id về backend.
7. Backend nhận webhook từ vendor.
8. App query trạng thái cuối từ backend.

Trạng thái nên có:

```swift
enum KYCStatus {
    case notStarted
    case inProgress
    case pendingReview
    case verified
    case rejected
    case needRetry
}
```

## Kinh nghiệm triển khai

- Client callback từ SDK chỉ nên xem là tạm thời; trạng thái cuối nên lấy từ backend.
- Luôn có retry flow cho ảnh mờ, glare, mất góc.
- Không lưu ảnh giấy tờ lâu hơn nhu cầu xử lý.
- Không log thông tin OCR.
- NFC cần UI hướng dẫn rất rõ vì user thường không biết vị trí chip/anten.
- Cần xử lý app background/foreground khi SDK đang chạy.

## Khó khăn thường gặp

- Camera permission bị từ chối.
- Thiết bị không hỗ trợ NFC.
- NFC timeout hoặc đọc fail do user đặt thẻ sai vị trí.
- Vendor SDK tăng size app.
- Webhook backend về chậm, app phải hiển thị pending.
- Liveness fail do ánh sáng, kính, khẩu trang hoặc camera kém.

## Checklist

- Có intro hướng dẫn trước khi eKYC.
- Có kiểm tra chất lượng ảnh.
- Có retry/resume flow.
- Trạng thái cuối lấy từ backend.
- Không log/lưu lâu dữ liệu định danh.
- NFC có fallback nếu thiết bị không hỗ trợ.
