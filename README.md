# Swift Handbook

> Kho tổng hợp kiến thức Swift và iOS dành cho việc học, ôn phỏng vấn, ghi chú kỹ thuật và lưu lại các ví dụ code có thể chạy bằng Playground/Xcode.

Repository này được tổ chức theo hướng giống một handbook cá nhân: mỗi chủ đề có phần lý thuyết ngắn gọn, bảng so sánh, câu hỏi phỏng vấn thường gặp và ví dụ thực hành đi kèm.

---

## Mục tiêu

- Tổng hợp kiến thức Swift/iOS theo từng nhóm chủ đề rõ ràng.
- Ghi chú lại những điểm dễ nhầm khi học hoặc khi đi phỏng vấn.
- Lưu ví dụ code nhỏ bằng Playground để có thể chạy và kiểm chứng nhanh.
- Làm nền tảng để mở rộng thêm các phần như UIKit, SwiftUI, Architecture, Networking, Concurrency, Database và Testing.

---

## Cấu trúc hiện tại

```text
Swift-Handbook/
├── README.md
└── Swift-Handbook/
    └── Swift-Handbook/
        ├── CoreSwift/
        │   ├── CoreSwift.md
        │   └── Swift Basic/
        │       ├── AssociatedType.playground/
        │       ├── Closure & Capture List.playground/
        │       ├── Extension.playground/
        │       ├── Memory.playground/
        │       ├── Protocol Composition.playground/
        │       ├── ProtocolOrientedProgramming.playground/
        │       └── StructVsClass.playground/
        ├── iOSWorld/
        │   ├── fundamentals/
        │   ├── data-storage/
        │   ├── design-patterns-architecture/
        │   ├── multiple-threads/
        │   ├── rxswift/
        │   ├── ui-+-autolayout/
        │   ├── blogs-+-practices/
        │   └── practices/
        └── Resource/
            ├── AppDelegate.swift
            ├── SceneDelegate.swift
            └── ViewController.swift
```

---

## Nội dung kiến thức

### 1. Core Swift

Tài liệu chính: [CoreSwift.md](Swift-Handbook/Swift-Handbook/CoreSwift/CoreSwift.md)

Các chủ đề đang có:

| Chủ đề | Nội dung chính | Ví dụ |
|--------|----------------|-------|
| Struct vs Class | Value type, reference type, kế thừa, ARC, thread-safety | [StructVsClass.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/StructVsClass.playground/Contents.swift) |
| Memory | Heap, Stack, ARC, retain cycle | [Memory.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/Memory.playground/Contents.swift) |
| Protocol-Oriented Programming | Protocol, default implementation, composition over inheritance | [ProtocolOrientedProgramming.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/ProtocolOrientedProgramming.playground/Contents.swift) |
| Extension | Method, computed property, initializer, protocol conformance | [Extension.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/Extension.playground/Contents.swift) |
| Associated Type | Placeholder type trong protocol, type safety, generic behavior | [AssociatedType.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/AssociatedType.playground/Contents.swift) |
| Protocol Composition | Kết hợp nhiều protocol bằng toán tử `&` | [Protocol Composition.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/Protocol%20Composition.playground/Contents.swift) |
| Closure & Capture List | Closure, escaping, non-escaping, `weak`, `unowned` | [Closure & Capture List.playground](Swift-Handbook/Swift-Handbook/CoreSwift/Swift%20Basic/Closure%20%26%20Capture%20List.playground/Contents.swift) |
| App Life Cycle | App states, AppDelegate, SceneDelegate, background/suspended | [CoreSwift.md](Swift-Handbook/Swift-Handbook/CoreSwift/CoreSwift.md) |

### 2. iOSWorld

Bộ tài liệu Markdown được copy từ `ios-world-main`: [iOSWorld/README.md](Swift-Handbook/Swift-Handbook/iOSWorld/README.md)

Các nhóm nội dung chính:

| Nhóm | Link |
|------|------|
| Fundamentals | [fundamentals](Swift-Handbook/Swift-Handbook/iOSWorld/fundamentals/README.md) |
| Data Storage | [data-storage](Swift-Handbook/Swift-Handbook/iOSWorld/data-storage/README.md) |
| Design Patterns & Architecture | [design-patterns-architecture](Swift-Handbook/Swift-Handbook/iOSWorld/design-patterns-architecture/README.md) |
| Multiple Threads | [multiple-threads](Swift-Handbook/Swift-Handbook/iOSWorld/multiple-threads/README.md) |
| RxSwift | [rxswift](Swift-Handbook/Swift-Handbook/iOSWorld/rxswift/README.md) |
| UI & Auto Layout | [ui-+-autolayout](Swift-Handbook/Swift-Handbook/iOSWorld/ui-+-autolayout/README.md) |
| Blogs & Practices | [blogs-+-practices](Swift-Handbook/Swift-Handbook/iOSWorld/blogs-+-practices/README.md) |
| Practices | [practices](Swift-Handbook/Swift-Handbook/iOSWorld/practices/portrait-effect-on-custom-camera.md) |

---

## Hướng mở rộng giống `ios-world-main`

Nếu muốn tổng hợp thêm kiến thức từ `ios-world-main`, nên chia thành các nhóm Markdown như sau để repo dễ đọc và dễ bảo trì:

```text
Swift-Handbook/Swift-Handbook/
├── CoreSwift/
│   └── CoreSwift.md
├── UIKit/
│   ├── UIKit.md
│   ├── ViewController-LifeCycle.md
│   ├── AutoLayout.md
│   └── TableView-CollectionView.md
├── SwiftUI/
│   ├── SwiftUI.md
│   ├── State-Binding.md
│   ├── Navigation.md
│   └── Animation.md
├── Architecture/
│   ├── Architecture.md
│   ├── MVC-MVVM-MVI.md
│   ├── Coordinator.md
│   └── Clean-Architecture.md
├── Networking/
│   ├── Networking.md
│   ├── URLSession.md
│   ├── Codable.md
│   └── Error-Handling.md
├── Concurrency/
│   ├── Concurrency.md
│   ├── Async-Await.md
│   ├── Task-Actor-MainActor.md
│   └── GCD-OperationQueue.md
├── Database/
│   ├── Database.md
│   ├── UserDefaults-Keychain.md
│   ├── CoreData.md
│   └── SwiftData.md
└── Testing/
    ├── Testing.md
    ├── Unit-Test.md
    └── UI-Test.md
```

Mỗi file nên giữ cùng một format:

```markdown
# Tên chủ đề

> Tóm tắt ngắn: chủ đề này dùng để làm gì, gặp ở đâu trong dự án iOS.

## 1. Khái niệm

## 2. Khi nào dùng?

## 3. Code mẫu

## 4. Lỗi thường gặp

## 5. Câu hỏi phỏng vấn

## 6. Tổng kết
```

---

## Cách học trong repo này

1. Đọc phần tổng quan trong file `.md`.
2. Mở Playground tương ứng để chạy thử code.
3. Tự sửa ví dụ để kiểm chứng lại kiến thức.
4. Ghi thêm câu hỏi phỏng vấn hoặc case thực tế gặp trong dự án.

---

## Quy ước ghi chú

- Dùng tiếng Việt cho phần giải thích chính.
- Giữ thuật ngữ tiếng Anh quan trọng như `Value Type`, `Reference Type`, `ARC`, `Actor`, `MainActor`, `Retain Cycle`.
- Ưu tiên bảng so sánh cho các chủ đề dễ nhầm.
- Code mẫu nên ngắn, chạy được, tập trung vào đúng ý cần học.
- Mỗi chủ đề lớn nên có phần câu hỏi phỏng vấn ở cuối.

---

## Tech Stack

- Swift
- UIKit
- SwiftUI
- Xcode
- Playground
- Git

---

## Tác giả

**Trần Chí Thiện (Tian Tran)**  
*iOS Developer*
