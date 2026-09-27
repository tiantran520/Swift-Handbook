# Session & Device Management trong iOS Finance

Session & Device Management là nền tảng bảo mật cho app Finance. Mục tiêu là đảm bảo đúng người, đúng thiết bị, đúng phiên đăng nhập và dọn sạch dữ liệu khi phiên không còn hợp lệ.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Lưu token | Keychain Services |
| Ràng buộc thiết bị | Device fingerprint, `identifierForVendor`, key pair |
| Bảo vệ private key | Secure Enclave, Keychain access control |
| Refresh token | Network interceptor / Authenticator layer |
| Auto-lock | App lifecycle, inactivity timer |
| Logout/revoke session | Session manager, app state reset |

## Vì sao chọn các công nghệ này?

### Keychain Services

Token và credential không nên lưu trong `UserDefaults` vì `UserDefaults` không dành cho dữ liệu bí mật. Keychain được iOS thiết kế để lưu thông tin nhạy cảm như password, token, certificate hoặc private key.

Ưu điểm:

- Được hệ thống bảo vệ.
- Có thể cấu hình thời điểm truy cập bằng `kSecAttrAccessible`.
- Có thể giới hạn dữ liệu chỉ tồn tại trên thiết bị hiện tại bằng `ThisDeviceOnly`.
- Phù hợp để lưu access token, refresh token hoặc device binding key.

Nên chọn khi:

- Cần lưu token sau khi app bị kill.
- Cần xóa token khi logout.
- Cần bảo vệ credential khỏi storage thông thường.

### Secure Enclave

Secure Enclave phù hợp khi app cần tạo private key mà không muốn key rời khỏi phần cứng bảo mật. Trong device binding, app có thể sinh key pair trên thiết bị, gửi public key lên backend và dùng private key để ký challenge.

Ưu điểm:

- Private key khó bị extract.
- Có thể kết hợp biometric/passcode.
- Tăng độ tin cậy cho thiết bị đã đăng ký.

Nên chọn khi:

- App banking yêu cầu device binding mạnh.
- Cần ký challenge để chứng minh thiết bị hợp lệ.
- Cần bảo vệ key quan trọng hơn token thông thường.

### Network Interceptor / Authenticator

Refresh token nên được xử lý tập trung ở network layer thay vì mỗi màn hình tự xử lý.

Ưu điểm:

- Tránh lặp logic refresh token.
- Kiểm soát race condition khi nhiều API cùng nhận `401`.
- Dễ dọn session khi refresh thất bại.
- Dễ retry request ban đầu sau khi refresh thành công.

Nên chọn khi:

- App có nhiều API cần authentication.
- Access token sống ngắn.
- Có silent refresh token.

## Cách lựa chọn triển khai

### Mức cơ bản

Phù hợp với app finance nhỏ, chưa yêu cầu device binding mạnh:

- Lưu access token và refresh token trong Keychain.
- Dùng refresh token flow tập trung.
- Auto-lock sau 3–5 phút không tương tác.
- Logout khi refresh token hết hạn.

### Mức nâng cao

Phù hợp với banking, ví điện tử, chứng khoán:

- Device binding bằng key pair.
- Private key lưu trong Secure Enclave hoặc Keychain access control.
- Backend quản lý danh sách thiết bị tin cậy.
- Khi login thiết bị mới, yêu cầu OTP/eKYC hoặc hủy thiết bị cũ.
- Có session revoke từ backend.

## Gợi ý kiến trúc

Các thành phần nên có:

- `TokenStore`: đọc/ghi/xóa token trong Keychain.
- `SessionManager`: quản lý trạng thái login, locked, expired.
- `AuthInterceptor`: gắn access token vào request.
- `TokenRefresher`: refresh token tập trung.
- `DeviceBindingService`: đăng ký và verify thiết bị.
- `InactivityMonitor`: theo dõi thời gian không tương tác.

Ví dụ trạng thái session:

```swift
enum SessionState {
    case unauthenticated
    case authenticated
    case locked
    case refreshing
    case expired
    case revoked
}
```

## Kinh nghiệm triển khai

- Refresh token phải được serialize, chỉ một refresh chạy tại một thời điểm.
- Request đang chờ nên được retry sau khi refresh thành công.
- Khi refresh thất bại, hủy toàn bộ request phụ thuộc session.
- Không log token, kể cả ở debug build.
- Khi logout, xóa Keychain item, memory cache, local cache và reset navigation stack.
- Device binding không nên chỉ dựa vào `identifierForVendor`.

## Khó khăn thường gặp

- Nhiều request cùng refresh token gây race condition.
- App vào background trong lúc refresh token.
- Backend revoke session nhưng client vẫn còn token trong memory.
- User đổi máy hoặc cài lại app làm mất binding key.
- Logic auto-lock xung đột với deeplink/push notification.

## Checklist

- Token lưu trong Keychain.
- Refresh token xử lý tập trung.
- Có auto-lock khi inactivity.
- Có xử lý session revoke từ backend.
- Có clear data khi logout/session expired.
- Device binding có cơ chế recover khi đổi máy.
