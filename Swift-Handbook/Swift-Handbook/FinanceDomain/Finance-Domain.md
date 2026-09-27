# Finance Domain cho iOS Developer

> Tổng hợp các nghiệp vụ quan trọng mà iOS developer nên nắm khi xây dựng ứng dụng Banking, Finance, Wallet, Investment hoặc các sản phẩm có giao dịch tiền tệ.

Làm app Finance không chỉ là hiển thị số dư và gọi API chuyển tiền. Một iOS developer cần hiểu cách quản lý phiên đăng nhập, ràng buộc thiết bị, xác thực eKYC, ký duyệt giao dịch, xử lý trạng thái thanh toán, bảo vệ dữ liệu thẻ, chống lộ thông tin trên UI và tính toán tiền tệ chính xác.

Các nghiệp vụ dưới đây thường xuất hiện trong app ngân hàng, ví điện tử, chứng khoán, bảo hiểm, fintech hoặc hệ thống thanh toán.

## Các chuyên đề chi tiết

| Nghiệp vụ | File |
|----------|------|
| Quản lý Phiên & Ràng buộc Thiết bị | [Session-Device-Management.md](Session-Device-Management.md) |
| Định danh Khách hàng & NFC | [eKYC-NFC.md](eKYC-NFC.md) |
| Smart OTP & Transaction Signing | [Smart-OTP-Transaction-Signing.md](Smart-OTP-Transaction-Signing.md) |
| Chuyển tiền & Xử lý Thanh toán | [Transfer-Payment-Processing.md](Transfer-Payment-Processing.md) |
| Card Services & PCI-DSS | [Card-Services-PCI.md](Card-Services-PCI.md) |
| Bảo vệ Giao diện & Dữ liệu Khách hàng | [UI-Data-Protection.md](UI-Data-Protection.md) |
| Tính toán Tài chính & Lưu trữ Ngoại tuyến | [Money-Calculation-Offline-Storage.md](Money-Calculation-Offline-Storage.md) |

## 1. Quản lý Phiên & Ràng buộc Thiết bị

Session & Device Management là lớp bảo vệ đầu tiên sau khi người dùng đăng nhập. Mục tiêu là đảm bảo một phiên đăng nhập hợp lệ, đúng thiết bị, không bị dùng lại sau khi hết hạn hoặc bị đăng nhập từ thiết bị khác.

### Single Device Login

Nhiều app banking yêu cầu mỗi tài khoản chỉ hoạt động trên một thiết bị chính danh tại một thời điểm. Khi người dùng đăng nhập trên thiết bị mới, app cần kích hoạt luồng xác thực lại hoặc hủy phiên thiết bị cũ.

Những thông tin thường được dùng:

- `identifierForVendor`
- Device model, OS version, app version
- Push notification token
- Key pair sinh trên thiết bị
- Keychain item
- Secure Enclave nếu cần bảo vệ private key

`identifierForVendor` không nên được xem là định danh tuyệt đối vì nó có thể thay đổi khi user xóa toàn bộ app cùng vendor rồi cài lại. Trong hệ thống nghiêm ngặt, device binding nên kết hợp nhiều yếu tố và luôn có backend quản lý trạng thái thiết bị.

### Auto-Lock & Session Timeout

App tài chính thường tự khóa sau một khoảng thời gian không tương tác, ví dụ 3–5 phút.

Các sự kiện nên reset inactivity timer:

- Touch trên màn hình
- Navigate sang màn khác
- Gõ bàn phím
- Scroll danh sách
- App trở lại foreground

Các sự kiện nên khóa app:

- Không tương tác quá thời gian quy định
- App vào background quá lâu
- Token hết hạn
- Backend báo session không hợp lệ
- Phát hiện đăng nhập trên thiết bị khác

### Concurrent Session & Token Rotation

Token thường gồm access token và refresh token. Access token sống ngắn, refresh token sống dài hơn và dùng để silent refresh.

Khi API trả `401 Unauthorized`, app không nên lập tức logout nếu có thể refresh token. Luồng thường là:

1. Request API bị `401`.
2. Network layer tạm giữ các request đang chờ.
3. Gọi refresh token API một lần duy nhất.
4. Nếu refresh thành công, retry request cũ.
5. Nếu refresh thất bại, xóa session và về màn login.

Nếu backend trả lỗi trùng phiên, thiết bị bị thu hồi hoặc token bị revoke, app phải:

- Dừng các request đang chạy.
- Xóa access token, refresh token khỏi Keychain.
- Xóa cache nhạy cảm trong memory.
- Reset app state.
- Điều hướng về login hoặc màn thông báo phiên hết hiệu lực.

### Áp dụng vào iOS app

- Tạo một `SessionManager` trung tâm để quản lý token, trạng thái login và timeout.
- Lưu token trong Keychain, không lưu trong `UserDefaults`.
- Network layer nên xử lý refresh token tập trung để tránh mỗi API tự refresh riêng.
- App lifecycle cần lắng nghe foreground/background để khóa app đúng lúc.
- Dùng notification hoặc dependency injection để các module biết khi session bị revoke.

### Kinh nghiệm triển khai

- Luôn xử lý race condition khi nhiều request cùng nhận `401`.
- Nên có một queue refresh token duy nhất.
- Tách trạng thái `loggedOut`, `locked`, `authenticated`, `refreshing`, `expired`.
- Khi logout, dọn cả memory cache, local cache và các màn đang chứa dữ liệu nhạy cảm.
- Với single device, thông báo lỗi phải rõ: "Tài khoản đã được đăng nhập trên thiết bị khác" thay vì báo lỗi chung chung.

### Khó khăn thường gặp

- Refresh token bị gọi nhiều lần song song.
- App bị kẹt ở màn loading khi refresh fail.
- Token đã xóa nhưng request cũ vẫn retry bằng token cũ.
- `identifierForVendor` thay đổi gây sai lệch device binding.
- User đổi máy, mất máy, cài lại app cần luồng khôi phục hợp lý.

## 2. Định danh Khách hàng & Thu thập Sinh trắc

eKYC là quy trình định danh khách hàng điện tử. Trong app tài chính, đây thường là bước bắt buộc để mở tài khoản, nâng hạn mức hoặc thực hiện giao dịch giá trị cao.

### OCR giấy tờ tùy thân

OCR dùng để bóc tách thông tin từ CCCD, CMND, hộ chiếu hoặc giấy tờ tương đương.

Trước khi gửi ảnh lên server, app nên kiểm tra:

- Ảnh có đủ sáng không.
- Ảnh có bị lóa không.
- Ảnh có bị mờ không.
- Giấy tờ có nằm trong khung không.
- Có mất góc giấy tờ không.
- Người dùng có chụp đúng mặt trước/mặt sau không.

Việc kiểm tra sớm trên client giúp giảm tỷ lệ fail và giảm chi phí xử lý backend/vendor.

### Liveness Detection

Liveness detection giúp xác minh người thật đang thực hiện định danh, chống giả mạo bằng ảnh in, ảnh trên màn hình hoặc video phát lại.

Một số dạng liveness:

- Passive liveness: user chỉ cần nhìn vào camera, hệ thống tự phân tích.
- Active liveness: yêu cầu quay đầu, chớp mắt, đọc số, làm theo hướng dẫn.
- Video liveness: quay một đoạn video ngắn để phân tích.

### Đọc chip CCCD bằng NFC

Một số luồng định danh cần đọc dữ liệu từ chip CCCD hoặc giấy tờ chuẩn ICAO 9303 qua `CoreNFC`.

iOS developer cần nắm:

- Thiết bị phải hỗ trợ NFC.
- Cần entitlement và cấu hình phù hợp.
- User phải đưa thẻ đúng vị trí NFC.
- NFC session có timeout.
- Cần hướng dẫn UI rõ ràng vì trải nghiệm đọc chip dễ fail.

### Tuân thủ hạn mức giao dịch

Trong banking, một số giao dịch vượt ngưỡng giá trị có thể yêu cầu xác thực nâng cao, ví dụ đối chiếu khuôn mặt với dữ liệu căn cước gắn chip hoặc xác thực bổ sung từ backend/vendor.

Client không nên tự quyết định giao dịch có đạt chuẩn hay không. App chỉ nên:

- Hiển thị yêu cầu xác thực.
- Mở luồng eKYC/NFC/liveness.
- Gửi kết quả hoặc session id về backend.
- Chờ backend trả quyết định cuối cùng.

### Áp dụng vào iOS app

- Tạo flow eKYC theo từng step rõ ràng: intro, scan document, verify face, NFC, result.
- Mỗi step nên có state riêng: idle, processing, success, failed, retry.
- Upload ảnh/video qua HTTPS.
- Không lưu ảnh giấy tờ lâu hơn nhu cầu xử lý.
- Không log OCR result hoặc thông tin định danh.
- Luôn lấy trạng thái cuối từ backend, đặc biệt khi dùng vendor như HyperKYC.

### Kinh nghiệm triển khai

- UX hướng dẫn chụp giấy tờ quan trọng không kém SDK.
- Cần xử lý app background trong lúc eKYC đang chạy.
- Nên có resume flow nếu app bị kill hoặc mạng lỗi.
- Với NFC, hãy hiển thị hướng dẫn theo từng model máy nếu có thể.
- Với vendor KYC, callback client chỉ nên xem là trạng thái tạm thời.

### Khó khăn thường gặp

- Camera permission bị từ chối.
- Ảnh giấy tờ bị lóa, mờ, mất góc.
- NFC đọc thất bại nhiều lần làm user bỏ cuộc.
- SDK vendor trả trạng thái khác với backend webhook.
- Luồng review thủ công khiến trạng thái pending kéo dài.

## 3. Ký duyệt Giao dịch & Smart OTP

Smart OTP là cơ chế xác thực giao dịch ngay trong app, thường thay thế hoặc bổ sung SMS OTP. Với app banking, OTP không chỉ là mã ngẫu nhiên mà cần gắn với nội dung giao dịch.

### Soft OTP / Smart OTP

Soft OTP thường dựa trên TOTP hoặc cơ chế tương tự, sinh mã theo thời gian và secret key đã đăng ký trước đó.

Ưu điểm:

- Không phụ thuộc SMS.
- Hạn chế rủi ro SIM swap.
- Có thể hoạt động khi mạng viễn thông không ổn định.
- Trải nghiệm nhanh hơn nếu tích hợp trong app.

Secret key của Smart OTP phải được bảo vệ cẩn thận, nên lưu trong Keychain/Secure Enclave nếu thiết kế cho phép.

### Transaction Signing

Với giao dịch tài chính, mã xác thực nên gắn với chính nội dung giao dịch:

```text
OTP = Algorithm(SecretKey, Timestamp, ReceiverAccount, Amount)
```

Ý nghĩa là nếu hacker thay đổi số tài khoản nhận hoặc số tiền ở tầng mạng, mã ký giao dịch sẽ không còn hợp lệ.

Các dữ liệu nên đưa vào transaction signing:

- Số tài khoản nhận
- Ngân hàng nhận
- Số tiền
- Loại tiền
- Nội dung chuyển khoản
- Transaction id hoặc challenge từ backend
- Timestamp/nonce

### Ủy quyền sinh trắc học cục bộ

Face ID / Touch ID có thể dùng để:

- Mở khóa Smart OTP.
- Xác nhận giao dịch hạn mức nhỏ.
- Mở khóa PIN OTP.
- Xác thực lại sau session timeout.

Tuy nhiên biometric trên thiết bị chỉ xác nhận người đang cầm máy vượt qua xác thực local. Với giao dịch quan trọng, backend vẫn cần verify transaction signing hoặc OTP.

### Áp dụng vào iOS app

- Hiển thị màn confirm giao dịch với thông tin rõ ràng trước khi ký.
- Không cho ký giao dịch nếu dữ liệu hiển thị khác dữ liệu dùng để ký.
- Lấy challenge/nonce từ backend trước khi sinh mã.
- Dùng `LocalAuthentication` để mở khóa bước ký nếu business yêu cầu.
- Sau khi ký, gửi signature/OTP cùng transaction id lên backend.

### Kinh nghiệm triển khai

- Luôn format số tiền và người nhận rõ ràng ở màn confirm.
- Không dùng dữ liệu user nhập thô để ký nếu backend đã trả dữ liệu chuẩn hóa.
- Đồng bộ thời gian là vấn đề quan trọng với TOTP.
- Cần xử lý lệch giờ thiết bị.
- Nếu app support offline OTP, phải có cơ chế đăng ký/kích hoạt an toàn.

### Khó khăn thường gặp

- User đổi giờ hệ thống làm TOTP sai.
- Secret bị migrate không mong muốn qua backup.
- Giao dịch bị timeout nhưng user đã thấy OTP thành công.
- Backend và client format dữ liệu ký khác nhau dẫn tới verify fail.
- Khó debug vì không được log secret hoặc OTP.

## 4. Nghiệp vụ Chuyển tiền & Xử lý Thanh toán

Chuyển tiền là nghiệp vụ lõi của app banking/wallet. iOS developer cần hiểu luồng giao dịch, trạng thái xử lý và cách tránh tạo giao dịch trùng.

### Chuyển tiền nhanh 24/7 và chuyển thường

Chuyển nhanh 24/7 thường đi qua cổng chuyển mạch nội địa như NAPAS. Đặc điểm:

- Có thể kiểm tra tên người nhận tức thì.
- Dùng số tài khoản hoặc số thẻ.
- Thường xử lý nhanh gần real-time.

Chuyển thường/liên ngân hàng truyền thống có thể yêu cầu:

- Chọn ngân hàng nhận.
- Chọn tỉnh/thành phố.
- Chọn chi nhánh.
- Thời gian xử lý lâu hơn.

App cần phân biệt rõ hai luồng vì form nhập, validation, phí và trạng thái xử lý có thể khác nhau.

### VietQR và EMVCo

VietQR thường chứa payload theo dạng TLV: Tag-Length-Value.

Khi scan QR, app cần bóc tách:

- Mã ngân hàng
- Số tài khoản
- Tên người nhận nếu có
- Số tiền nếu QR dynamic
- Nội dung chuyển khoản
- Mã định danh merchant hoặc service

Client có thể parse QR để autofill form, nhưng backend vẫn nên validate lại trước khi tạo giao dịch.

### State Machine của giao dịch

Giao dịch tài chính không chỉ có thành công hoặc thất bại. Trạng thái `pending/timeout` rất quan trọng.

Các trạng thái tối thiểu:

- `created`: đã tạo lệnh.
- `processing`: đang xử lý.
- `success`: thành công.
- `failed`: thất bại.
- `pending`: chưa có kết quả cuối.
- `timeout`: client không nhận được kết quả kịp thời.
- `reversed/refunded`: đã hoàn hoặc đảo giao dịch.

Khi timeout, không nên hiển thị "Giao dịch thất bại" nếu backend chưa xác nhận fail. Cách an toàn hơn là hiển thị "Đang xử lý" kèm mã tra soát.

### Idempotency Key

Khi user nhấn xác nhận, app nên gửi `idempotency_key` duy nhất. Nếu mạng chập chờn khiến request bị gửi lại, backend dùng key này để tránh tạo hai giao dịch.

Ví dụ:

```swift
let idempotencyKey = UUID().uuidString
```

Key này nên gắn với một lần submit giao dịch, không tạo lại khi retry cùng một request.

### Áp dụng vào iOS app

- Tạo màn confirm trước khi submit.
- Disable nút xác nhận sau khi user nhấn.
- Gửi idempotency key với request tạo giao dịch.
- Với timeout, điều hướng đến màn result pending.
- Cho phép user tra cứu lại giao dịch bằng transaction id.
- Polling hoặc push notification để cập nhật trạng thái cuối.

### Kinh nghiệm triển khai

- Không tin vào trạng thái client nếu chưa có xác nhận backend.
- Cần thiết kế màn pending thật tốt vì giao dịch tiền không thể mập mờ.
- Log kỹ request id/transaction id/idempotency key, nhưng không log dữ liệu nhạy cảm.
- Retry phải có kiểm soát, không retry mù quáng với lệnh chuyển tiền.
- Màn lịch sử giao dịch nên sync lại sau khi tạo giao dịch.

### Khó khăn thường gặp

- User nhấn back hoặc kill app giữa lúc xử lý.
- API timeout nhưng giao dịch thật đã thành công.
- Push trạng thái đến chậm hoặc mất.
- Backend trả trạng thái trung gian chưa rõ ràng.
- QR từ nhiều ngân hàng/merchant có payload khác nhau.

## 5. Quản lý Thẻ & Thông tin Nhạy cảm

Card Services liên quan tới thông tin rất nhạy cảm như PAN, CVV, hạn mức, trạng thái thẻ và Apple Pay. Đây là vùng cần tuân thủ chặt chẽ về bảo mật và PCI-DSS.

### Masking dữ liệu thẻ

Không nên hiển thị toàn bộ số thẻ nếu không cần thiết.

Ví dụ masking PAN:

```text
1234 56** **** 7890
```

CVV/CVC nên ẩn hoàn toàn. Nếu user muốn xem, cần xác thực lại bằng biometric/PIN và chỉ hiển thị trong thời gian ngắn.

### Vòng đời thẻ

Các nghiệp vụ thường gặp:

- Kích hoạt thẻ mới.
- Khóa/mở khóa thẻ tức thì.
- Đổi PIN thẻ.
- Đổi hạn mức thanh toán online.
- Đổi hạn mức thanh toán quốc tế.
- Tạo thẻ ảo.
- Hủy thẻ.
- Báo mất thẻ.

Với freeze/unfreeze card, app cần cập nhật UI gần real-time vì user kỳ vọng thao tác có hiệu lực ngay.

### Apple Pay

Tích hợp Apple Pay trong banking app thường dùng `PassKit`. Với In-App Provisioning, user có thể thêm thẻ vào Apple Wallet trực tiếp trong app mà không cần nhập tay thông tin thẻ.

iOS developer cần chú ý:

- Kiểm tra thiết bị có hỗ trợ Apple Pay không.
- Kiểm tra thẻ đã được add vào Wallet chưa.
- Phối hợp backend/card processor để lấy dữ liệu provisioning.
- Xử lý callback thành công/thất bại rõ ràng.

### Áp dụng vào iOS app

- Tất cả dữ liệu thẻ phải được mask mặc định.
- Màn xem thông tin thẻ cần xác thực lại.
- Không lưu PAN/CVV plain text ở local.
- Không chụp/log response chứa thông tin thẻ.
- Với card action, hiển thị confirmation trước khi submit.
- Sau khi freeze/unfreeze, refresh trạng thái từ backend.

### Kinh nghiệm triển khai

- UI card đẹp không đủ, phải ưu tiên bảo mật hiển thị.
- Tách component masked card để dùng nhất quán toàn app.
- Dùng timer để tự ẩn lại thông tin thẻ sau vài giây.
- Với Apple Pay, cần test nhiều trạng thái: thiết bị không hỗ trợ, thẻ đã add, add fail, user cancel.
- Làm việc sớm với backend/card vendor vì provisioning thường phức tạp.

### Khó khăn thường gặp

- Quy định PCI-DSS giới hạn việc lưu và hiển thị dữ liệu thẻ.
- Sandbox Apple Pay/provisioning khó setup.
- Trạng thái thẻ ở backend cập nhật chậm.
- User thao tác freeze/unfreeze liên tục.
- UI bị screenshot/app switcher làm lộ thông tin thẻ.

## 6. Bảo vệ Giao diện & Dữ liệu Khách hàng

Ngoài bảo vệ network và storage, app tài chính cần bảo vệ dữ liệu ngay trên giao diện. Rất nhiều thông tin có thể lộ qua app switcher, screenshot, screen recording hoặc bàn phím.

### Anti-Screen Capture trong App Switcher

Khi app vào background, iOS có thể lưu snapshot để hiển thị trong app switcher. Nếu màn hình đang có số dư, số thẻ hoặc thông tin cá nhân, snapshot này có thể làm lộ dữ liệu.

Cách thường dùng:

- Thêm blur view khi app resign active.
- Thay root overlay bằng màn che.
- Gỡ blur khi app active lại và user đã unlock.

Các notification thường dùng:

- `UIApplication.willResignActiveNotification`
- `UIApplication.didEnterBackgroundNotification`
- `UIApplication.didBecomeActiveNotification`

### Chặn ghi hình/chia sẻ màn hình

iOS có `UIScreen.main.isCaptured` để biết màn hình đang bị record, mirror hoặc AirPlay.

App có thể:

- Che dữ liệu nhạy cảm khi `isCaptured == true`.
- Hiển thị warning.
- Ẩn số dư/số thẻ.
- Khóa một số màn nhạy cảm.

Một số kỹ thuật dùng `UITextField` secure để chống capture có thể được áp dụng cho view nhạy cảm, nhưng cần cân nhắc rủi ro App Store, maintainability và hành vi thay đổi theo iOS.

### Keyboard an toàn

Với mã PIN, mật khẩu, OTP, một số app dùng custom in-app keyboard để:

- Giới hạn input.
- Random vị trí số.
- Chống quan sát vị trí chạm.
- Tránh dữ liệu đi qua bàn phím bên thứ ba.

Tuy nhiên custom keyboard cần làm tốt accessibility, UX, layout trên nhiều kích thước màn hình và tránh gây khó nhập cho user.

### Áp dụng vào iOS app

- Mọi màn chứa số dư, số thẻ, giấy tờ, thông tin cá nhân nên có privacy overlay.
- Khi detect screen recording, che vùng nhạy cảm thay vì crash app.
- Field nhập PIN/OTP nên tắt copy/paste nếu business yêu cầu.
- Với custom keypad, random layout phải rõ ràng và có animation vừa đủ.
- Snapshot testing nên kiểm tra trạng thái mask/blur.

### Kinh nghiệm triển khai

- Đừng chỉ blur khi app vào background; cần xử lý cả app switcher và foreground lại.
- Privacy overlay nên nằm ở level cao, ví dụ window/root coordinator.
- Dữ liệu nhạy cảm nên có component riêng như `SensitiveText`.
- Cho user tùy chọn ẩn số dư mặc định là một UX tốt.
- Custom keyboard phải test kỹ VoiceOver và Dynamic Type.

### Khó khăn thường gặp

- Screen recording detection không chặn được mọi hình thức chụp từ thiết bị ngoài.
- Secure text field hack có thể lỗi qua các bản iOS.
- Blur overlay làm rối navigation nếu đặt sai tầng view.
- Custom keyboard dễ bị chê khó dùng.
- Cân bằng giữa bảo mật và trải nghiệm người dùng.

## 7. Tính toán Tài chính & Lưu trữ Ngoại tuyến

Tính toán tiền tệ cần chính xác. Một sai số nhỏ trong app bình thường có thể không nghiêm trọng, nhưng trong app tài chính có thể tạo lỗi nghiệp vụ lớn.

### Không dùng Float/Double cho tiền

`Float` và `Double` là số dấu phẩy động nhị phân, có thể gây sai số biểu diễn.

Không nên:

```swift
let total = 0.1 + 0.2
```

Nên dùng:

```swift
let amount = Decimal(100_000)
```

Hoặc:

```swift
let amount = NSDecimalNumber(value: 100_000)
```

Với hệ thống lớn, backend thường trả amount dưới dạng:

- String: `"100000.50"`
- Integer minor unit: `10000050` với currency exponent
- Decimal-compatible value

Client nên giữ format chính xác và tránh convert qua `Double`.

### Quy tắc làm tròn

Lãi suất, phí giao dịch, dư nợ tín dụng hoặc chia tiền đều cần quy tắc làm tròn rõ ràng.

Một số rounding mode:

- `.plain`
- `.down`
- `.up`
- `.bankers`

Banker's rounding (`.bankers`) thường được dùng trong kế toán vì giảm bias khi làm tròn nhiều lần.

Ví dụ:

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

### Không cache dữ liệu nhạy cảm

Không nên lưu các dữ liệu sau vào `UserDefaults`:

- Số dư
- Lịch sử giao dịch chi tiết
- Số thẻ
- Token
- Thông tin giấy tờ
- Dữ liệu OCR/eKYC
- Thông tin định danh cá nhân

Nếu bắt buộc lưu offline, cần:

- Mã hóa dữ liệu.
- Hạn chế thời gian lưu.
- Xóa khi logout.
- Tách dữ liệu theo user.
- Không backup dữ liệu nhạy cảm nếu không cần.
- Dùng Keychain cho credential/token.

Với Keychain item quan trọng:

```swift
kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
```

### Áp dụng vào iOS app

- Tạo type riêng cho tiền, ví dụ `Money`.
- Tách amount và currency.
- Format tiền bằng `NumberFormatter`.
- Không parse tiền qua `Double`.
- Không cache response nhạy cảm trong URLCache.
- Clear cache khi logout hoặc session expired.

Ví dụ model đơn giản:

```swift
struct Money: Equatable {
    let amount: Decimal
    let currency: String
}
```

### Kinh nghiệm triển khai

- Quy định format amount với backend ngay từ đầu.
- Mọi màn hiển thị tiền nên dùng chung formatter.
- Unit test các case rounding.
- Test currency không có phần thập phân như VND/JPY và currency có phần thập phân như USD.
- Offline cache phải có owner user id để tránh lộ dữ liệu sau khi đổi tài khoản.

### Khó khăn thường gặp

- Backend trả amount lúc là number, lúc là string.
- Designer muốn format khác business rule.
- Rounding ở client khác backend gây lệch vài đồng.
- Cache làm user thấy số dư cũ sau khi logout/login tài khoản khác.
- Timezone ảnh hưởng tới lịch sử giao dịch và báo cáo theo ngày.

## Checklist cho iOS Developer trong Finance Domain

- Session timeout hoạt động đúng khi app foreground/background.
- Token được lưu trong Keychain và refresh tập trung.
- Single device login có flow rõ ràng khi bị revoke.
- eKYC có retry/resume flow.
- NFC có hướng dẫn người dùng rõ ràng.
- Smart OTP hoặc transaction signing dùng đúng dữ liệu giao dịch.
- Request tạo giao dịch có idempotency key.
- Timeout giao dịch hiển thị pending, không tự kết luận thất bại.
- Dữ liệu thẻ luôn mask mặc định.
- Màn nhạy cảm được blur khi vào app switcher.
- Detect screen recording cho màn chứa dữ liệu quan trọng.
- Không dùng `Double` cho tiền.
- Không cache dữ liệu nhạy cảm trong `UserDefaults`.
- Logout phải dọn token, cache và state nhạy cảm.

## Tóm tắt

Một iOS developer làm Finance cần hiểu cả kỹ thuật lẫn nghiệp vụ. Những phần như session, device binding, eKYC, Smart OTP, chuyển tiền, quản lý thẻ, bảo vệ UI và tính toán tiền tệ đều ảnh hưởng trực tiếp đến bảo mật, trải nghiệm và độ tin cậy của sản phẩm.

Điểm quan trọng nhất là không xử lý app tài chính như một app CRUD thông thường. Mọi thao tác liên quan đến tiền, danh tính và dữ liệu nhạy cảm đều cần có trạng thái rõ ràng, xác thực chặt chẽ, retry an toàn và cơ chế bảo vệ dữ liệu từ UI đến storage.
