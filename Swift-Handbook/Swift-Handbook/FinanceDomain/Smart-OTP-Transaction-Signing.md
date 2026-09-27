# Smart OTP & Transaction Signing trong iOS Finance

Smart OTP là cơ chế xác thực giao dịch ngay trong app. Với app Finance, OTP tốt không chỉ là một mã ngẫu nhiên, mà cần gắn với nội dung giao dịch để chống sửa đổi dữ liệu ở tầng mạng.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Sinh OTP theo thời gian | TOTP/HOTP, CryptoKit hoặc thư viện crypto đã kiểm chứng |
| Ký giao dịch | HMAC, asymmetric signing, challenge-response |
| Bảo vệ secret | Keychain, Secure Enclave |
| Xác thực local | LocalAuthentication |
| Đồng bộ thời gian | Server time, time drift handling |

## Vì sao chọn các công nghệ này?

### TOTP/HOTP

TOTP sinh mã theo thời gian, không phụ thuộc SMS. HOTP sinh mã theo counter. Với Smart OTP, TOTP phổ biến hơn vì mã tự hết hạn sau một khoảng thời gian ngắn.

Ưu điểm:

- Không phụ thuộc nhà mạng.
- Giảm rủi ro SIM swap.
- Hoạt động nhanh trong app.
- Có thể hoạt động ngay cả khi SMS chậm.

Nên chọn khi:

- Cần xác thực giao dịch thường xuyên.
- Muốn giảm phụ thuộc SMS OTP.
- App có luồng kích hoạt Smart OTP an toàn.

### Transaction Signing

Transaction signing đưa dữ liệu giao dịch vào thuật toán ký.

```text
Signature = Algorithm(SecretKey, Timestamp, ReceiverAccount, Amount, Challenge)
```

Ưu điểm:

- Chống MITM sửa số tài khoản/số tiền.
- Gắn mã xác thực với đúng giao dịch.
- Backend có thể verify nội dung giao dịch đã được user xác nhận.

Nên chọn khi:

- Giao dịch có giá trị tiền.
- Có nguy cơ dữ liệu bị sửa giữa client và server.
- Cần non-repudiation ở mức nghiệp vụ.

### LocalAuthentication

`LocalAuthentication` dùng Face ID/Touch ID để mở khóa Smart OTP hoặc xác nhận nhanh giao dịch hạn mức nhỏ.

Ưu điểm:

- UX nhanh.
- Không cần nhập PIN nhiều lần.
- Tận dụng bảo mật sinh trắc của thiết bị.

Nên chọn khi:

- Cần xác thực local trước khi ký.
- Cần mở khóa PIN/secret.
- Cần re-authentication cho thao tác nhạy cảm.

## Cách lựa chọn triển khai

### Dùng server-side challenge

Backend tạo challenge cho từng giao dịch. Client ký challenge kèm dữ liệu giao dịch.

Nên chọn cho banking/fintech nghiêm ngặt.

Ưu điểm:

- Chống replay tốt.
- Backend kiểm soát giao dịch.
- Dễ revoke hoặc expire challenge.

### Dùng TOTP offline

Client sinh OTP dựa trên secret và thời gian.

Nên chọn khi:

- Cần OTP không phụ thuộc mạng.
- Business chấp nhận rủi ro lệch giờ.
- Có cơ chế kích hoạt và lưu secret an toàn.

### Dùng asymmetric signing

Client giữ private key, backend giữ public key.

Nên chọn khi:

- Cần device binding mạnh.
- Muốn private key không rời thiết bị.
- Có thể dùng Secure Enclave.

## Gợi ý flow ký giao dịch

1. User nhập thông tin chuyển tiền.
2. App gọi API validate và nhận transaction challenge.
3. App hiển thị màn confirm với dữ liệu đã chuẩn hóa từ backend.
4. User xác thực Face ID/PIN.
5. App ký dữ liệu giao dịch.
6. App gửi signature/OTP lên backend.
7. Backend verify và xử lý giao dịch.

## Kinh nghiệm triển khai

- Không ký bằng dữ liệu raw user input nếu backend đã trả dữ liệu chuẩn hóa.
- Màn confirm phải hiển thị đúng dữ liệu được ký.
- Không log secret, OTP, signature raw.
- Có xử lý lệch giờ thiết bị nếu dùng TOTP.
- Secret nên lưu Keychain với `ThisDeviceOnly`.
- Nếu dùng Secure Enclave, chuẩn bị flow khôi phục khi user đổi máy.

## Khó khăn thường gặp

- Lệch giờ làm OTP sai.
- Backend và client serialize dữ liệu ký khác nhau.
- User kill app giữa luồng ký.
- Secret bị mất khi cài lại app.
- Debug khó vì không thể log dữ liệu nhạy cảm.

## Checklist

- Dữ liệu hiển thị = dữ liệu được ký.
- Có challenge/nonce chống replay.
- Secret/private key lưu an toàn.
- Có xử lý biometric fail/cancel.
- Có trạng thái timeout/pending rõ ràng sau khi submit.
