# 🍏 Swift & SwiftUI Handbook

Một không gian lưu trữ và tổng hợp kiến thức chuyên sâu về hệ sinh thái iOS. Repository này không chỉ chứa các đoạn code (snippets) mà còn tập trung vào cách tổ chức dự án, tư duy thiết kế kiến trúc và xây dựng các UI component theo phong cách tối giản (minimalist).

## 🚀 Cấu trúc Repository

### 1. 🏗 Architectures & Design Patterns
Nơi thử nghiệm và chuẩn hoá các mẫu kiến trúc phần mềm, đảm bảo tính mở rộng và dễ bảo trì:
- **MVVM & MVI:** Các ví dụ triển khai luồng dữ liệu một chiều (Unidirectional Data Flow) và quản lý state.
- **Coordinator Pattern:** Tách biệt hoàn toàn logic điều hướng (navigation) ra khỏi View trong SwiftUI.
- **Clean Architecture:** Cấu trúc chia lớp (Domain, Data, Presentation) áp dụng cho các dự án quy mô lớn.

### 2. 🎨 SwiftUI Components
Bộ sưu tập các thành phần giao diện được tinh chỉnh UI/UX:
- **Custom Views & Modifiers:** Các component tái sử dụng cao, thiết kế theo ngôn ngữ hiện đại, thân thiện.
- **Animations:** Xử lý các hiệu ứng chuyển động mượt mà và tự nhiên.
- **Complex Layouts:** Kỹ thuật xây dựng các màn hình có độ phức tạp cao (ví dụ: giao diện lên kế hoạch lịch trình, timeline).

### 3. ⚡️ Core Swift & Concurrency
- **Modern Concurrency:** Xử lý đa luồng với `async/await`, `Task`, `Actor` và `MainActor`.
- **Memory Management:** Quản lý bộ nhớ (ARC), xử lý Retain Cycles bằng `weak`/`unowned`.
- **Generics & Protocols:** Kỹ thuật viết code linh hoạt (Protocol-Oriented Programming).

### 4. 🗄 Network & Data
- Xây dựng Network Layer gọn nhẹ với `URLSession` kết hợp `async/await`.
- Xử lý luồng dữ liệu tĩnh, cache và quản lý Local Storage (SwiftData/CoreData).

## 🛠 Tech Stack & Workspace
- **Ngôn ngữ:** Swift
- **UI Framework:** SwiftUI
- **Công cụ:** Xcode, SourceTree, GitHub CLI, SwiftLint

## 💡 Ứng dụng thực tế
Các pattern và component trong repository này được đúc kết từ quá trình phát triển các sản phẩm thực tế, tiêu biểu như ứng dụng lên kế hoạch du lịch **EZPlan**, nhằm đảm bảo code không chỉ đúng lý thuyết mà còn chạy tốt trên production.

---
## 👨‍💻 Tác giả

**Trần Chí Thiện (Tian Tran)**  
*iOS Developer*
