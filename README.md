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
        ├── Architectures/
        │   ├── CleanArchitecture/
        │   ├── Coordinator/
        │   ├── DesignPatterns/
        │   ├── MVC/
        │   ├── MVP/
        │   ├── MVI/
        │   ├── MVVM/
        │   └── VIPER/
        ├── CoreSwift/
        │   ├── Concurrency/
        │   ├── Generics/
        │   ├── MemoryManagement/
        │   ├── CoreSwift.md
        │   └── Swift Basic/
        ├── DataStorage/
        ├── FinanceDomain/
        ├── Interview/
        ├── Network/
        ├── Practices/
        ├── RxSwift/
        ├── Tests/
        ├── UIKit/
        ├── UIComponents/
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

Tài liệu bổ sung đã được chia từ `ios-world-main`:

| Chủ đề | Link |
|--------|------|
| Access Levels | [Access-Levels.md](Swift-Handbook/Swift-Handbook/CoreSwift/Access-Levels.md) |
| OOP | [OOP.md](Swift-Handbook/Swift-Handbook/CoreSwift/OOP.md) |
| Struct vs Class | [Struct-vs-Class.md](Swift-Handbook/Swift-Handbook/CoreSwift/Struct-vs-Class.md) |
| Escaping vs Non-escaping | [Closure-Escaping-vs-NonEscaping.md](Swift-Handbook/Swift-Handbook/CoreSwift/Closure-Escaping-vs-NonEscaping.md) |
| Memory Leaks | [Memory-Leaks.md](Swift-Handbook/Swift-Handbook/CoreSwift/MemoryManagement/Memory-Leaks.md) |
| GCD | [GCD.md](Swift-Handbook/Swift-Handbook/CoreSwift/Concurrency/GCD.md) |
| Async/Await | [Async-Await.md](Swift-Handbook/Swift-Handbook/CoreSwift/Concurrency/Async-Await.md) |
| Operation Queue | [Operation-Queue.md](Swift-Handbook/Swift-Handbook/CoreSwift/Concurrency/Operation-Queue.md) |
| Serial vs Concurrent Queue | [Serial-vs-Concurrent-Queue.md](Swift-Handbook/Swift-Handbook/CoreSwift/Concurrency/Serial-vs-Concurrent-Queue.md) |

### 2. UIKit & UI

| Chủ đề | Link |
|--------|------|
| App Life Cycle | [App-Life-Cycle.md](Swift-Handbook/Swift-Handbook/UIKit/App-Life-Cycle.md) |
| UIViewController Life Cycle | [UIViewController-LifeCycle.md](Swift-Handbook/Swift-Handbook/UIKit/ViewController/UIViewController-LifeCycle.md) |
| Auto Layout Priority | [AutoLayout-Priority.md](Swift-Handbook/Swift-Handbook/UIKit/AutoLayout/AutoLayout-Priority.md) |
| Frame vs Bounds | [Frame-vs-Bounds.md](Swift-Handbook/Swift-Handbook/UIKit/Layout/Frame-vs-Bounds.md) |
| Reuse UITableViewCell | [Reuse-UITableViewCell.md](Swift-Handbook/Swift-Handbook/UIKit/TableView/Reuse-UITableViewCell.md) |
| Ways to Pass Data | [Ways-to-Pass-Data.md](Swift-Handbook/Swift-Handbook/UIKit/Ways-to-Pass-Data.md) |
| Texture / AsyncDisplayKit | [Texture-AsyncDisplayKit.md](Swift-Handbook/Swift-Handbook/UIComponents/Texture-AsyncDisplayKit.md) |

### 3. Architectures & Design Patterns

| Chủ đề | Link |
|--------|------|
| Architecture Overview | [Architecture-Overview.md](Swift-Handbook/Swift-Handbook/Architectures/Architecture-Overview.md) |
| Architecture vs Design Pattern | [Architecture-vs-Design-Pattern.md](Swift-Handbook/Swift-Handbook/Architectures/Architecture-vs-Design-Pattern.md) |
| SOLID | [SOLID.md](Swift-Handbook/Swift-Handbook/Architectures/SOLID.md) |
| MVC | [MVC.md](Swift-Handbook/Swift-Handbook/Architectures/MVC/MVC.md) |
| MVP | [MVP.md](Swift-Handbook/Swift-Handbook/Architectures/MVP/MVP.md) |
| MVP-R | [MVP-R.md](Swift-Handbook/Swift-Handbook/Architectures/MVP/MVP-R.md) |
| MVVM | [MVVM.md](Swift-Handbook/Swift-Handbook/Architectures/MVVM/MVVM.md) |
| VIPER | [VIPER.md](Swift-Handbook/Swift-Handbook/Architectures/VIPER/VIPER.md) |
| Clean Swift VIP | [Clean-Swift-VIP.md](Swift-Handbook/Swift-Handbook/Architectures/CleanArchitecture/Clean-Swift-VIP.md) |
| Singleton | [Singleton.md](Swift-Handbook/Swift-Handbook/Architectures/DesignPatterns/Singleton/Singleton.md) |
| Builder | [Builder.md](Swift-Handbook/Swift-Handbook/Architectures/DesignPatterns/Builder/Builder.md) |
| Memento | [Memento.md](Swift-Handbook/Swift-Handbook/Architectures/DesignPatterns/Memento/Memento.md) |
| Observer | [Observer.md](Swift-Handbook/Swift-Handbook/Architectures/DesignPatterns/Observer/Observer.md) |
| Strategy | [Strategy.md](Swift-Handbook/Swift-Handbook/Architectures/DesignPatterns/Strategy/Strategy.md) |

### 4. Data, RxSwift, Practices

| Nhóm | Link |
|------|------|
| Data Security | [Data-Security.md](Swift-Handbook/Swift-Handbook/Data%20Security/Data-Security.md) |
| Data Storage | [Data-Storage.md](Swift-Handbook/Swift-Handbook/DataStorage/Data-Storage.md) |
| Core Data | [Core-Data.md](Swift-Handbook/Swift-Handbook/DataStorage/CoreData/Core-Data.md) |
| RxSwift | [RxSwift.md](Swift-Handbook/Swift-Handbook/RxSwift/RxSwift.md) |
| RxSwift Cheat Sheet | [Cheat-Sheet.md](Swift-Handbook/Swift-Handbook/RxSwift/Cheat-Sheet.md) |
| iOS Learning Roadmap | [iOS-Learning-Roadmap.md](Swift-Handbook/Swift-Handbook/Practices/iOS-Learning-Roadmap.md) |
| Style Convention | [Style-Convention.md](Swift-Handbook/Swift-Handbook/Practices/Style-Convention.md) |
| Portrait Effect Camera | [Portrait-Effect-on-Custom-Camera.md](Swift-Handbook/Swift-Handbook/Practices/Camera/Portrait-Effect-on-Custom-Camera.md) |

### 5. SwiftUI

| Chủ đề | Link |
|--------|------|
| SwiftUI App Life Cycle | [LifeCycle_SwiftUI.md](Swift-Handbook/Swift-Handbook/SwiftUI/LifeCycle_SwiftUI.md) |
| State Management | [State-Management.md](Swift-Handbook/Swift-Handbook/SwiftUI/State-Management.md) |
| UIKit vs SwiftUI | [UIKit-vs-SwiftUI.md](Swift-Handbook/Swift-Handbook/SwiftUI/UIKit-vs-SwiftUI.md) |

### 6. Finance Domain

| Chủ đề | Link |
|--------|------|
| Finance Domain Overview | [Finance-Domain.md](Swift-Handbook/Swift-Handbook/FinanceDomain/Finance-Domain.md) |
| Session & Device Management | [Session-Device-Management.md](Swift-Handbook/Swift-Handbook/FinanceDomain/Session-Device-Management.md) |
| eKYC & NFC | [eKYC-NFC.md](Swift-Handbook/Swift-Handbook/FinanceDomain/eKYC-NFC.md) |
| Smart OTP & Transaction Signing | [Smart-OTP-Transaction-Signing.md](Swift-Handbook/Swift-Handbook/FinanceDomain/Smart-OTP-Transaction-Signing.md) |
| Transfer & Payment Processing | [Transfer-Payment-Processing.md](Swift-Handbook/Swift-Handbook/FinanceDomain/Transfer-Payment-Processing.md) |
| Card Services & PCI-DSS | [Card-Services-PCI.md](Swift-Handbook/Swift-Handbook/FinanceDomain/Card-Services-PCI.md) |
| UI & Customer Data Protection | [UI-Data-Protection.md](Swift-Handbook/Swift-Handbook/FinanceDomain/UI-Data-Protection.md) |
| Money Calculation & Offline Storage | [Money-Calculation-Offline-Storage.md](Swift-Handbook/Swift-Handbook/FinanceDomain/Money-Calculation-Offline-Storage.md) |

---

## Hướng mở rộng tiếp theo

Khi thêm tài liệu mới, nên đưa thẳng vào folder chuyên đề tương ứng thay vì tạo một thư mục nguồn riêng:

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
├── Architectures/
│   ├── MVC/
│   ├── MVP/
│   ├── MVVM/
│   ├── MVI/
│   ├── VIPER/
│   ├── CleanArchitecture/
│   └── DesignPatterns/
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
├── FinanceDomain/
│   ├── Finance-Domain.md
│   ├── Transaction.md
│   ├── Budgeting.md
│   └── Portfolio.md
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
