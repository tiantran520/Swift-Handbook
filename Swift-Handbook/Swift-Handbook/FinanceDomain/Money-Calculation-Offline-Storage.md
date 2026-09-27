# Money Calculation & Offline Storage trong iOS Finance

Tính toán tiền tệ và lưu trữ offline là hai vùng dễ tạo bug nghiêm trọng trong app Finance. Sai số vài đồng, cache sai user hoặc lưu dữ liệu nhạy cảm sai chỗ đều có thể thành lỗi lớn.

## Công nghệ lõi

| Nhu cầu | Công nghệ/API nên dùng |
|--------|-------------------------|
| Tính tiền chính xác | `Decimal`, `NSDecimalNumber` |
| Format tiền | `NumberFormatter`, `FormatStyle` |
| Làm tròn | `NSDecimalNumberHandler` |
| Lưu token/secret | Keychain |
| Cache an toàn | Encrypted database/file nếu thật sự cần |
| Không cache nhạy cảm | Disable URLCache, clear cache on logout |

## Vì sao chọn các công nghệ này?

### Decimal / NSDecimalNumber

`Double` và `Float` là số dấu phẩy động nhị phân, không phù hợp cho tiền vì có sai số biểu diễn.

Không nên:

```swift
let total = 0.1 + 0.2
```

Nên dùng:

```swift
let amount = Decimal(string: "100000.50")
```

Ưu điểm:

- Phù hợp tính toán thập phân.
- Giảm sai số tiền tệ.
- Có thể làm tròn theo rule rõ ràng.

Nên chọn cho mọi nghiệp vụ amount, fee, interest, balance.

### NumberFormatter

Hiển thị tiền cần đúng locale, currency và số chữ số thập phân.

Ưu điểm:

- Format theo locale.
- Hỗ trợ currency symbol/code.
- Dùng chung toàn app để tránh lệch format.

Nên chọn khi:

- Hiển thị số dư, phí, lãi, hạn mức.
- App hỗ trợ nhiều currency.

### Keychain và encrypted storage

Token, secret và credential phải lưu Keychain. Dữ liệu nhạy cảm khác chỉ nên cache nếu có yêu cầu rõ ràng và phải mã hóa.

Ưu điểm Keychain:

- Bảo vệ bởi hệ thống.
- Có access control.
- Có `ThisDeviceOnly`.

## Cách lựa chọn triển khai

### Amount từ backend

Nên thống nhất với backend một trong các format:

- String decimal: `"100000.50"`
- Minor unit integer: `10000050`
- Decimal-compatible number

Tránh parse qua `Double`.

Ví dụ model:

```swift
struct Money: Equatable {
    let amount: Decimal
    let currency: String
}
```

### Rounding

Business phải định nghĩa rõ rounding mode.

Ví dụ dùng banker's rounding:

```swift
let value = NSDecimalNumber(string: "10.125")
let handler = NSDecimalNumberHandler(
    roundingMode: .bankers,
    scale: 2,
    raiseOnExactness: false,
    raiseOnOverflow: false,
    raiseOnUnderflow: false,
    raiseOnDivideByZero: true
)

let rounded = value.rounding(accordingToBehavior: handler)
```

### Offline storage

Không nên cache:

- Số dư nhạy cảm
- Lịch sử giao dịch chi tiết
- Token
- Thông tin giấy tờ
- PAN/CVV
- OCR/eKYC result

Nếu bắt buộc cache:

- Mã hóa.
- Gắn dữ liệu với user id.
- Xóa khi logout.
- Không backup nếu không cần.
- Có TTL.

## Kinh nghiệm triển khai

- Tạo `MoneyFormatter` dùng chung toàn app.
- Unit test rounding và currency exponent.
- VND/JPY thường không có phần thập phân; USD/EUR thường có 2 chữ số.
- Không để UI tự format amount mỗi nơi một kiểu.
- Clear URLCache khi logout nếu API có response nhạy cảm.
- Không dùng `UserDefaults` cho dữ liệu tài chính nhạy cảm.

## Khó khăn thường gặp

- Backend trả amount lúc string, lúc number.
- Rounding client khác backend.
- Timezone làm lệch ngày giao dịch.
- Cache của user A hiện sau khi login user B.
- Designer muốn format đẹp nhưng sai rule kế toán.

## Checklist

- Không dùng `Double` cho tiền.
- Amount luôn đi kèm currency.
- Có formatter dùng chung.
- Có unit test rounding.
- Token lưu Keychain.
- Cache nhạy cảm được mã hóa hoặc không cache.
- Logout clear cache/state theo user.
