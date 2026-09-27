# Data Security trong iOS

Data security trong iOS tập trung vào việc bảo vệ dữ liệu nhạy cảm của người dùng và ứng dụng, đặc biệt là token, mật khẩu, thông tin định danh, dữ liệu eKYC và luồng xác thực.

Trong app thực tế, bảo mật không chỉ là một API riêng lẻ. Nó thường là sự kết hợp giữa:

- Lưu trữ an toàn bằng Keychain.
- Xác thực người dùng bằng Face ID / Touch ID.
- Quản lý token bằng JWT, expiration và refresh token.
- Xác thực danh tính bằng eKYC hoặc HyperKYC.
- Bảo vệ network layer bằng HTTPS và Certificate Pinning.
- Giảm rủi ro lộ dữ liệu qua log, cache, screenshot, clipboard hoặc storage không an toàn.

## 1. Keychain Services

Keychain Services là nơi phù hợp để lưu dữ liệu nhạy cảm trong iOS, ví dụ:

- Access token.
- Refresh token.
- Password hoặc secret ngắn hạn.
- Private key hoặc credential cần bảo vệ.
- Biometric-protected item.

Không nên lưu token hoặc password trong:

- `UserDefaults`
- File plain text
- SQLite không mã hóa
- Log
- Cache

Ví dụ lưu chuỗi vào Keychain:

```swift
import Foundation
import Security

enum KeychainService {
    static func save(_ value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func read(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    static func delete(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
```

Khi lưu token, nên cân nhắc thêm `kSecAttrAccessible` để kiểm soát thời điểm item có thể được truy cập.

Ví dụ:

```swift
kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
```

Một số lựa chọn thường gặp:

- `kSecAttrAccessibleWhenUnlocked`: chỉ đọc được khi thiết bị đang unlock.
- `kSecAttrAccessibleAfterFirstUnlock`: đọc được sau lần unlock đầu tiên sau khi boot.
- `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`: yêu cầu thiết bị có passcode, item không migrate sang thiết bị khác.
- Hậu tố `ThisDeviceOnly`: không backup/restore sang thiết bị khác.

Với token quan trọng, nên ưu tiên nhóm `ThisDeviceOnly` nếu business không cần migrate credential qua backup.

## 2. Biometric: Face ID / Touch ID

Face ID và Touch ID trong iOS được xử lý qua Local Authentication framework, chủ yếu là `LAContext`.

Biometric thường dùng cho:

- Mở khóa app nhanh.
- Xác nhận giao dịch.
- Truy cập dữ liệu nhạy cảm.
- Re-authentication sau timeout.

Ví dụ xác thực biometric:

```swift
import LocalAuthentication

final class BiometricAuthenticator {
    func authenticate(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false, error)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
```

Nếu muốn fallback sang passcode, dùng:

```swift
.deviceOwnerAuthentication
```

Thay vì:

```swift
.deviceOwnerAuthenticationWithBiometrics
```

Các điểm cần lưu ý:

- Biometric không thay thế hoàn toàn authentication từ server.
- Không lưu trực tiếp dữ liệu biometric của người dùng.
- Biometric chỉ xác nhận đúng chủ thiết bị tại thời điểm đó.
- Với giao dịch nhạy cảm, nên kết hợp biometric với server-side validation.
- Cần cấu hình `NSFaceIDUsageDescription` trong `Info.plist`.

## 3. eKYC

eKYC là quy trình định danh khách hàng điện tử. Trong app tài chính, ngân hàng, ví điện tử hoặc chứng khoán, eKYC thường dùng để xác minh danh tính người dùng trước khi mở tài khoản hoặc sử dụng tính năng nhạy cảm.

Một luồng eKYC phổ biến:

1. Người dùng nhập thông tin cơ bản.
2. Chụp giấy tờ tùy thân như CCCD/CMND/passport.
3. OCR đọc thông tin trên giấy tờ.
4. Chụp selfie hoặc quay video liveness.
5. So khớp khuôn mặt trên giấy tờ với selfie.
6. Kiểm tra tính hợp lệ của giấy tờ.
7. Gửi kết quả về backend để review tự động hoặc thủ công.
8. Backend trả trạng thái: success, pending, rejected hoặc retry.

Các trạng thái thường gặp:

- `notStarted`: chưa bắt đầu.
- `inProgress`: đang thực hiện.
- `pendingReview`: chờ review.
- `verified`: xác thực thành công.
- `rejected`: bị từ chối.
- `needRetry`: cần thực hiện lại một bước.

Khi tích hợp eKYC trong iOS, cần chú ý:

- Xin quyền camera rõ ràng.
- Hướng dẫn người dùng chụp ảnh đủ sáng, không lóa, không mất góc.
- Không lưu ảnh giấy tờ hoặc selfie lâu hơn nhu cầu business.
- Không log thông tin định danh.
- Upload qua HTTPS.
- Có retry flow thân thiện.
- Có cách resume khi app bị kill hoặc network lỗi.
- Đồng bộ trạng thái với backend, không chỉ tin vào state local.

## 4. HyperKYC

HyperKYC thường được hiểu là một giải pháp eKYC do bên thứ ba cung cấp, đóng gói các bước OCR, face match, liveness detection và fraud detection thành SDK hoặc web flow.

Quy trình tích hợp HyperKYC thường gồm:

1. App gọi backend để tạo KYC session.
2. Backend trả về `transactionId`, `workflowId`, `accessToken` hoặc thông tin tương đương.
3. App mở HyperKYC SDK hoặc web flow.
4. Người dùng thực hiện chụp giấy tờ, selfie, liveness.
5. SDK trả callback trạng thái ban đầu về app.
6. Backend nhận webhook/kết quả chính thức từ HyperKYC.
7. App query backend để lấy trạng thái cuối cùng.

Điểm quan trọng:

- App không nên tự quyết định user đã pass KYC chỉ dựa trên callback client.
- Kết quả cuối cùng nên lấy từ backend vì backend có thể verify webhook/signature.
- Token/session của KYC flow nên có expiration ngắn.
- Cần xử lý đầy đủ các trạng thái cancel, timeout, retry, network failed.
- Không hardcode API key hoặc secret của vendor trong app.

Ví dụ enum trạng thái KYC ở client:

```swift
enum KYCStatus {
    case notStarted
    case inProgress
    case pendingReview
    case verified
    case rejected(reason: String?)
    case needRetry
}
```

## 5. JWT

JWT là viết tắt của JSON Web Token. JWT thường được dùng để truyền thông tin xác thực giữa client và server.

Một JWT có 3 phần:

```text
header.payload.signature
```

Ví dụ:

```text
xxxxx.yyyyy.zzzzz
```

### Header

Header mô tả loại token và thuật toán ký.

```json
{
  "alg": "RS256",
  "typ": "JWT"
}
```

### Payload

Payload chứa các claim.

```json
{
  "sub": "user_id",
  "exp": 1710000000,
  "iat": 1709990000
}
```

Một số claim thường gặp:

- `sub`: subject, thường là user id.
- `exp`: expiration time.
- `iat`: issued at.
- `nbf`: not before.
- `iss`: issuer.
- `aud`: audience.

### Signature

Signature dùng để server kiểm tra token có bị sửa hay không.

Client iOS thường không tự verify signature nếu không có public key và logic phù hợp. Việc verify quan trọng nhất vẫn nên nằm ở backend/API gateway.

## 6. Expiration và Refresh Token

Access token nên có thời gian sống ngắn. Refresh token dùng để lấy access token mới khi access token hết hạn.

Luồng phổ biến:

1. User login thành công.
2. Server trả `accessToken` và `refreshToken`.
3. App lưu token trong Keychain.
4. App gọi API bằng access token.
5. Nếu API trả `401 Unauthorized` do token hết hạn, app gọi refresh token API.
6. Server trả access token mới.
7. App retry request ban đầu.
8. Nếu refresh token cũng hết hạn hoặc bị revoke, app logout user.

Các lưu ý quan trọng:

- Không lưu token trong `UserDefaults`.
- Không log token.
- Không gửi refresh token cho API không cần thiết.
- Nên refresh token bằng một luồng tập trung trong network layer.
- Tránh nhiều request cùng refresh token một lúc.
- Khi logout, xóa token khỏi Keychain.
- Nếu refresh thất bại, clear session và điều hướng về login.

Ví dụ mô hình token:

```swift
struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}
```

## 7. Certificate Pinning

Certificate Pinning là kỹ thuật giúp app chỉ tin tưởng certificate hoặc public key cụ thể của server. Mục tiêu là giảm rủi ro man-in-the-middle, kể cả khi thiết bị bị cài CA lạ hoặc network bị can thiệp.

Nếu không pinning, app thường tin vào hệ thống trust store của iOS. Với pinning, app kiểm tra thêm certificate/public key của server có khớp với bản đã pin trong app hay không.

Có hai hướng phổ biến:

- Certificate pinning: pin toàn bộ certificate.
- Public key pinning: pin public key, linh hoạt hơn khi certificate renew nhưng key giữ nguyên.

Ví dụ ý tưởng với `URLSessionDelegate`:

```swift
import Foundation
import Security

final class PinningURLSessionDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificateData: Data

    init?(certificateName: String) {
        guard let url = Bundle.main.url(forResource: certificateName, withExtension: "cer"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }

        self.pinnedCertificateData = data
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data

        if serverCertificateData == pinnedCertificateData {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

Sử dụng:

```swift
if let delegate = PinningURLSessionDelegate(certificateName: "api-example-com") {
    let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    // Use session for secure API requests
}
```

Lưu ý khi dùng pinning:

- Cần có kế hoạch rotate certificate/key trước khi hết hạn.
- Nếu pin sai hoặc certificate đổi đột ngột, app có thể mất kết nối API.
- Nên pin ở network layer dùng cho API quan trọng.
- Không nên bỏ qua default trust evaluation.
- Nên có monitoring để phát hiện pinning failure.
- Cẩn thận với môi trường dev/staging/prod vì certificate có thể khác nhau.

## 8. Checklist bảo mật cho iOS app

- Lưu token/password trong Keychain.
- Xóa token khi logout.
- Không log dữ liệu nhạy cảm.
- Không hardcode secret trong app.
- Dùng HTTPS cho toàn bộ API.
- Cân nhắc Certificate Pinning cho API quan trọng.
- Dùng biometric cho thao tác nhạy cảm hoặc mở khóa nhanh.
- Có session timeout với app tài chính.
- Mask dữ liệu nhạy cảm như số thẻ, số tài khoản, giấy tờ.
- Không cache response nhạy cảm nếu không cần.
- Không lưu ảnh eKYC lâu hơn nhu cầu xử lý.
- Luôn xác thực trạng thái eKYC/KYC cuối cùng từ backend.
- Có cơ chế refresh token an toàn và tập trung.
- Review quyền camera, photo library, location nếu có dùng.

## Tóm tắt

- Keychain là nơi phù hợp để lưu token, password và credential nhạy cảm.
- Biometric qua `LAContext` giúp xác thực nhanh nhưng không thay thế hoàn toàn server authentication.
- eKYC/HyperKYC cần xử lý theo workflow, trạng thái cuối cùng nên được xác nhận từ backend.
- JWT gồm header, payload và signature; cần quan tâm `exp`, refresh token và logout flow.
- Certificate Pinning giúp giảm rủi ro man-in-the-middle nhưng cần kế hoạch vận hành cẩn thận.
