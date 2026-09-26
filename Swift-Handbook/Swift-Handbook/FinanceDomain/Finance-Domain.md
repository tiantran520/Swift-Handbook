# Finance Domain

> Tổng hợp kiến thức nghiệp vụ thường gặp khi xây dựng app Finance, Banking, Budgeting, Wallet, Investment hoặc Expense Tracking.

---

## 1. Nhóm nghiệp vụ chính

| Nhóm | Nội dung cần nắm |
|------|------------------|
| Account | Tài khoản ngân hàng, ví điện tử, thẻ tín dụng, tài khoản đầu tư |
| Transaction | Giao dịch thu/chi, chuyển khoản, hoàn tiền, phí, lãi |
| Budget | Ngân sách theo tháng, theo danh mục, cảnh báo vượt hạn mức |
| Category | Phân loại chi tiêu, thu nhập, subscription, merchant |
| Balance | Số dư hiện tại, số dư khả dụng, pending balance |
| Report | Báo cáo thu chi, cash flow, net worth, trend theo thời gian |
| Security | PIN, biometric, masking dữ liệu nhạy cảm, session timeout |

---

## 2. Data Model cơ bản

### Account

- `id`
- `name`
- `type`: cash, bank, creditCard, eWallet, investment
- `currency`
- `currentBalance`
- `availableBalance`
- `createdAt`

### Transaction

- `id`
- `accountId`
- `amount`
- `currency`
- `type`: income, expense, transfer
- `status`: pending, completed, failed, refunded
- `categoryId`
- `merchantName`
- `note`
- `transactionDate`
- `createdAt`

### Budget

- `id`
- `categoryId`
- `period`: weekly, monthly, yearly
- `limitAmount`
- `spentAmount`
- `startDate`
- `endDate`

---

## 3. Luồng màn hình thường gặp

1. Dashboard tổng quan tài chính.
2. Danh sách tài khoản và số dư.
3. Lịch sử giao dịch.
4. Thêm/sửa giao dịch.
5. Quản lý danh mục thu chi.
6. Lập ngân sách.
7. Báo cáo theo tuần/tháng/năm.
8. Cài đặt bảo mật.

---

## 4. Quy tắc nghiệp vụ cần chú ý

- Luôn lưu `amount` bằng kiểu số chính xác, tránh dùng `Double` trực tiếp cho tiền nếu cần tính toán nghiêm ngặt.
- Mỗi giao dịch nên có `currency`, kể cả khi app chỉ hỗ trợ một loại tiền ở giai đoạn đầu.
- Transfer giữa hai tài khoản thường nên được biểu diễn bằng một cặp transaction liên kết với nhau.
- Giao dịch `pending` không nên được xử lý giống hoàn toàn với giao dịch `completed`.
- Báo cáo nên tách rõ income, expense, transfer để tránh tính sai cash flow.
- Dữ liệu nhạy cảm như số thẻ, token, session phải được lưu trong Keychain hoặc storage an toàn.

---

## 5. Câu hỏi phỏng vấn/thực tế

- Vì sao không nên dùng `Double` để tính tiền?
- Khác nhau giữa `currentBalance` và `availableBalance` là gì?
- App nên xử lý giao dịch pending như thế nào?
- Làm sao thiết kế model cho giao dịch chuyển tiền giữa hai tài khoản?
- Làm sao tính báo cáo chi tiêu theo tháng khi user đổi timezone?
- Những dữ liệu nào trong app Finance cần được bảo vệ đặc biệt?

---

## 6. Hướng mở rộng

- Currency conversion.
- Recurring transaction.
- Subscription tracking.
- Debt/loan tracking.
- Investment portfolio.
- Financial goal planning.
- Export CSV/PDF.
- Sync đa thiết bị.
