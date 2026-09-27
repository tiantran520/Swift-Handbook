# Card Services & PCI-DSS trong iOS Finance

Card Services liên quan đến số thẻ, CVV, hạn mức, trạng thái thẻ, thẻ ảo, thẻ vật lý và Apple Pay. Đây là nhóm nghiệp vụ có rủi ro cao vì liên quan trực tiếp đến dữ liệu thẻ.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Mask số thẻ | UI component riêng, formatter |
| Xem thông tin thẻ | LocalAuthentication, backend tokenization |
| Lưu credential | Keychain, hạn chế lưu local |
| Apple Pay | PassKit |
| Trạng thái thẻ | Backend card service, polling/push |
| Bảo vệ UI | Privacy overlay, screen capture detection |

## Vì sao chọn các công nghệ này?

### PassKit

PassKit dùng để tích hợp Apple Pay và In-App Provisioning. User có thể thêm thẻ vào Apple Wallet trực tiếp từ app.

Ưu điểm:

- Trải nghiệm thêm thẻ tiện.
- Giảm nhập tay thông tin thẻ.
- Tận dụng bảo mật của Apple Wallet.
- Phù hợp với app ngân hàng/phát hành thẻ.

Nên chọn khi:

- App phát hành thẻ debit/credit/prepaid.
- Business muốn hỗ trợ Apple Pay.
- Backend/card processor hỗ trợ provisioning.

### LocalAuthentication

Face ID/Touch ID dùng để xác thực trước khi hiển thị PAN/CVV hoặc thực hiện card action nhạy cảm.

Ưu điểm:

- UX nhanh.
- Tăng lớp bảo vệ trước khi lộ thông tin thẻ.
- Phù hợp với thao tác xem CVV, đổi hạn mức, freeze/unfreeze.

### Tokenization

App không nên giữ dữ liệu thẻ thật nếu không cần. Backend hoặc card processor nên trả token/temporary credential theo phiên.

Ưu điểm:

- Giảm phạm vi PCI-DSS.
- Giảm rủi ro lộ PAN/CVV.
- Dễ revoke token.

## Cách lựa chọn triển khai

### Chỉ hiển thị masked card

Phù hợp với hầu hết màn hình danh sách thẻ.

Hiển thị:

```text
1234 56** **** 7890
```

Không cần xác thực lại nếu chỉ hiển thị masked data.

### Xem full card info

Chỉ dùng khi business yêu cầu user xem PAN/CVV.

Nên có:

- Biometric/PIN re-authentication.
- Timer tự ẩn sau vài giây.
- Không cho screenshot nếu policy yêu cầu.
- Không cache full PAN/CVV.

### Card action

Các action như freeze, unfreeze, đổi hạn mức, bật thanh toán quốc tế nên có:

- Màn confirm.
- Xác thực bổ sung nếu rủi ro cao.
- Refresh trạng thái từ backend sau khi submit.

## Kinh nghiệm triển khai

- Tạo component `MaskedCardNumberView` dùng chung.
- CVV luôn ẩn mặc định.
- Khi app vào background, che màn đang hiển thị thẻ.
- Không log response chứa PAN/CVV.
- Apple Pay provisioning cần test nhiều trạng thái: thiết bị không hỗ trợ, thẻ đã thêm, user cancel, provisioning fail.
- Card status nên lấy từ backend sau mỗi thao tác quan trọng.

## Khó khăn thường gặp

- PCI-DSS giới hạn việc lưu/hiển thị dữ liệu thẻ.
- Sandbox Apple Pay khó setup.
- Backend/card processor có nhiều trạng thái thẻ phức tạp.
- User thao tác freeze/unfreeze liên tục.
- UI đẹp nhưng dễ làm lộ dữ liệu nếu không có privacy overlay.

## Checklist

- PAN/CVV không lưu local plain text.
- Mask thẻ mặc định.
- Xem CVV cần xác thực lại.
- Có timer tự ẩn full card info.
- Apple Pay dùng PassKit.
- Freeze/unfreeze refresh lại trạng thái từ backend.
