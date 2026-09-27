# UI & Customer Data Protection trong iOS Finance

Bảo vệ dữ liệu trong app Finance không chỉ nằm ở network và storage. Giao diện cũng có thể làm lộ số dư, số thẻ, thông tin cá nhân qua app switcher, screenshot, screen recording hoặc bàn phím.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Che app switcher | App lifecycle notification, privacy overlay |
| Detect screen recording | `UIScreen.main.isCaptured` |
| Detect capture changes | `UIScreen.capturedDidChangeNotification` |
| Bảo vệ field nhạy cảm | Secure text input, custom keypad |
| Xác thực local | LocalAuthentication |
| Mask dữ liệu | UI component riêng |

## Vì sao chọn các công nghệ này?

### Privacy Overlay

Khi app vào background, iOS tạo snapshot cho app switcher. Privacy overlay giúp che số dư, thẻ và thông tin cá nhân trước khi snapshot được lưu.

Ưu điểm:

- Dễ triển khai.
- Bảo vệ nhiều màn hình cùng lúc.
- Không phụ thuộc từng view controller.

Nên chọn khi:

- App có dữ liệu tài chính nhạy cảm.
- Cần che UI khi vào app switcher.
- Muốn áp dụng toàn app ở window/root level.

### `UIScreen.isCaptured`

`isCaptured` cho biết màn hình đang bị record, mirror hoặc AirPlay.

Ưu điểm:

- API chính thống.
- Có thể che dữ liệu nhạy cảm realtime.
- Phù hợp với màn thẻ, số dư, eKYC.

Nên chọn khi:

- App cần phản ứng khi user quay/chia sẻ màn hình.
- Cần ẩn vùng dữ liệu nhạy cảm.

### Custom In-App Keyboard

Custom keypad dùng cho PIN/OTP có thể random vị trí số để giảm rủi ro quan sát vị trí chạm.

Ưu điểm:

- Kiểm soát input.
- Tránh bàn phím bên thứ ba.
- Có thể scramble keypad.

Nên chọn khi:

- App yêu cầu nhập PIN/OTP bảo mật cao.
- Business chấp nhận trade-off UX.

## Cách lựa chọn triển khai

### Mức tối thiểu

- Blur app khi vào background.
- Mask số dư/số thẻ mặc định.
- Dùng secure input cho password/PIN.
- Tắt log dữ liệu nhạy cảm.

### Mức nâng cao

- Detect screen recording và che vùng nhạy cảm.
- Dùng custom keypad cho PIN/OTP.
- Tự động ẩn số dư theo setting user.
- Re-authentication khi mở màn nhạy cảm.

## Gợi ý triển khai privacy overlay

Các notification cần quan tâm:

- `UIApplication.willResignActiveNotification`
- `UIApplication.didEnterBackgroundNotification`
- `UIApplication.didBecomeActiveNotification`

Ý tưởng:

```swift
final class PrivacyOverlayManager {
    func showOverlay() {
        // Add blur/cover view to window
    }

    func hideOverlay() {
        // Remove blur/cover view after app is active and unlocked
    }
}
```

Overlay nên nằm ở tầng cao, ví dụ window hoặc root coordinator, để che được toàn bộ màn hình.

## Kinh nghiệm triển khai

- Đừng chỉ che ở từng màn hình riêng lẻ; nên có cơ chế toàn app.
- Component hiển thị dữ liệu nhạy cảm nên có mode masked/unmasked.
- Khi `isCaptured == true`, nên che dữ liệu thay vì crash app.
- Custom keypad phải test kỹ accessibility.
- Cần cân bằng bảo mật và trải nghiệm, vì bảo mật quá gắt có thể làm user khó dùng.

## Khó khăn thường gặp

- `isCaptured` không chặn được việc chụp bằng thiết bị ngoài.
- Secure text field hack có thể thay đổi hành vi theo iOS.
- Blur overlay đặt sai tầng làm hỏng navigation hoặc modal.
- Custom keypad khó dùng với VoiceOver.
- Screenshot policy khác nhau theo yêu cầu từng tổ chức.

## Checklist

- App switcher không lộ dữ liệu nhạy cảm.
- Screen recording che số dư/thẻ.
- PIN/OTP dùng input an toàn.
- Có component `SensitiveText`.
- Có setting ẩn/hiện số dư.
- Test foreground/background với modal, deeplink, push.
