# Transfer & Payment Processing trong iOS Finance

Chuyển tiền và thanh toán là nghiệp vụ lõi của app Finance. iOS developer cần hiểu luồng tạo giao dịch, parse QR, idempotency, retry an toàn và state machine giao dịch.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Scan QR | AVFoundation, VisionKit nếu phù hợp |
| Parse VietQR/EMVCo | TLV parser |
| Tạo giao dịch an toàn | Idempotency key |
| Theo dõi trạng thái | State machine, polling, push notification |
| Retry request | Network layer có kiểm soát |
| Lưu draft | Secure local storage nếu cần |

## Vì sao chọn các công nghệ này?

### AVFoundation cho QR

AVFoundation hỗ trợ scan QR realtime và tùy biến camera UI.

Ưu điểm:

- Control camera tốt.
- Tùy biến overlay scan.
- Scan realtime.
- Không phụ thuộc thư viện ngoài.

Nên chọn khi:

- App cần scan VietQR.
- Cần UX camera tùy biến.
- Cần parse QR ngay trong app.

### TLV Parser cho VietQR/EMVCo

VietQR/EMVCo dùng cấu trúc Tag-Length-Value. Tự parse đúng chuẩn giúp app autofill số tài khoản, ngân hàng, số tiền và nội dung.

Ưu điểm:

- Chủ động xử lý QR static/dynamic.
- Có thể validate payload trước khi gửi backend.
- Giảm nhập tay cho user.

Nên chọn khi:

- App hỗ trợ chuyển tiền bằng QR.
- Cần đọc nhiều loại payload ngân hàng/merchant.

### Idempotency Key

Idempotency key giúp tránh tạo trùng giao dịch khi user nhấn nhiều lần hoặc mạng retry.

Ưu điểm:

- Chống trừ tiền hai lần.
- Cho phép retry an toàn.
- Backend có thể nhận diện cùng một intent giao dịch.

Nên chọn cho mọi API tạo lệnh chuyển tiền/thanh toán.

## Cách lựa chọn triển khai

### Chuyển nhanh 24/7

Nên dùng khi:

- Cần kiểm tra tên người nhận tức thì.
- Chuyển qua số tài khoản/số thẻ.
- Kỳ vọng kết quả nhanh.

Client cần:

- Validate ngân hàng/số tài khoản.
- Gọi API inquiry tên người nhận.
- Hiển thị phí, hạn mức, tên người nhận.
- Tạo transaction với idempotency key.

### Chuyển thường

Nên dùng khi:

- Luồng yêu cầu tỉnh/thành phố/chi nhánh.
- Không có inquiry realtime.
- Thời gian xử lý lâu hơn.

Client cần:

- Form nhập nhiều bước rõ ràng.
- Giải thích thời gian xử lý.
- Theo dõi trạng thái pending.

### VietQR

Nên dùng khi:

- Muốn giảm nhập liệu.
- Merchant hoặc người nhận cung cấp QR.
- Payload có thể chứa sẵn amount/content.

Client cần:

- Parse QR.
- Validate lại với backend.
- Cho user confirm trước khi chuyển.

## State machine giao dịch

Không nên chỉ dùng `success/failed`. Giao dịch tài chính cần trạng thái trung gian.

```swift
enum TransactionState {
    case created
    case processing
    case pending
    case success
    case failed
    case timeout
    case reversed
}
```

Khi client timeout, không được tự kết luận thất bại. Nên hiển thị pending và cho user tra soát bằng mã giao dịch.

## Kinh nghiệm triển khai

- Disable nút confirm sau khi submit.
- Idempotency key phải giữ nguyên khi retry cùng một giao dịch.
- Backend nên trả transaction id càng sớm càng tốt.
- Polling phải có giới hạn và backoff.
- Push notification có thể cập nhật trạng thái, nhưng không nên phụ thuộc hoàn toàn.
- Lịch sử giao dịch nên refresh sau khi submit.

## Khó khăn thường gặp

- API timeout nhưng giao dịch thật thành công.
- User kill app giữa lúc đang xử lý.
- QR payload không đồng nhất giữa ngân hàng/merchant.
- Retry sai cách tạo duplicate transaction.
- Trạng thái backend cập nhật chậm.

## Checklist

- Có màn confirm trước submit.
- Có idempotency key.
- Có pending/timeout state.
- Có transaction id để tra soát.
- QR được validate lại với backend.
- Không retry mù quáng lệnh chuyển tiền.
