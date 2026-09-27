# SwiftUI App Life Cycle

SwiftUI App Life Cycle là cách quản lý vòng đời ứng dụng được Apple giới thiệu từ Xcode 12, Swift 5.3 và SwiftUI 2.0. Thay vì khởi động ứng dụng qua `AppDelegate` như UIKit truyền thống, SwiftUI dùng một type conform protocol `App` làm điểm bắt đầu của chương trình.

## Môi trường hỗ trợ ban đầu

- Xcode 12+
- Swift 5.3+
- SwiftUI 2.0+
- macOS 10.15+
- iOS 14+

Với các project iOS hiện đại, SwiftUI App Life Cycle là lựa chọn tự nhiên khi ứng dụng được xây dựng chủ yếu bằng SwiftUI. Nếu app vẫn phụ thuộc nhiều vào UIKit, `AppDelegate` hoặc `SceneDelegate`, bạn vẫn có thể chọn UIKit App Delegate Life Cycle hoặc tích hợp AppDelegate vào SwiftUI App khi cần.

## UIKit App Delegate và SwiftUI App

Trước SwiftUI App Life Cycle, một ứng dụng iOS thường bắt đầu từ `AppDelegate`. Từ iOS 13, Apple tách thêm `SceneDelegate` để hỗ trợ multi-window và quản lý nhiều scene độc lập.

Với SwiftUI, Apple cung cấp một mô hình gọn hơn:

- `AppDelegate`: cách truyền thống, thường dùng với UIKit.
- `AppDelegate + SceneDelegate`: dùng từ iOS 13 để quản lý nhiều scene/window.
- `SwiftUI App`: cách mới, dùng `@main`, protocol `App`, `Scene` và `View`.

Khi tạo project mới bằng Xcode và chọn interface là SwiftUI, phần Life Cycle thường có hai lựa chọn:

- UIKit App Delegate
- SwiftUI App

Nếu chọn SwiftUI App, project ban đầu thường chỉ cần quan tâm hai file chính:

- `ContentView.swift`: view đầu tiên được hiển thị.
- `<TênApp>App.swift`: điểm vào của ứng dụng, tương tự vai trò khởi động app của `AppDelegate`.

## Cấu trúc SwiftUI App

Một file SwiftUI App cơ bản thường có dạng:

```swift
import SwiftUI

@main
struct TheNewAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Đoạn code trên có ba thành phần quan trọng: `@main`, protocol `App` và `Scene`.

## @main

`@main` được dùng để đánh dấu điểm bắt đầu khi chương trình chạy.

Một số điểm cần nhớ:

- Có từ Swift 5.3.
- Đánh dấu struct/class là entry point của chương trình.
- Một target chỉ nên có một `@main`.
- Nếu khai báo nhiều `@main`, project sẽ báo lỗi.
- Khi dùng `@main`, bạn không cần tự viết `main.swift` như cách truyền thống.

Trong SwiftUI App Life Cycle, struct conform `App` và được gắn `@main` chính là nơi app bắt đầu.

## App Protocol

`App` là protocol đại diện cho toàn bộ ứng dụng SwiftUI. Khi conform protocol này, bạn cần cung cấp `body` trả về một `Scene`.

```swift
@main
struct TheNewAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

`body` trong `App` không trả về `View` trực tiếp như trong `ContentView`, mà trả về `Scene`. Bên trong `Scene`, bạn khai báo view hierarchy đầu tiên của ứng dụng.

## Scene và WindowGroup

`Scene` mô tả một phần giao diện độc lập mà hệ thống có thể quản lý. Trên iOS, scene thường tương ứng với một window hoặc một instance giao diện của app. Trên iPadOS/macOS, mô hình này hỗ trợ tốt hơn cho multi-window.

`WindowGroup` là scene phổ biến nhất trong app SwiftUI:

```swift
var body: some Scene {
    WindowGroup {
        ContentView()
    }
}
```

Một số loại scene/thành phần liên quan thường gặp:

- `WindowGroup`
- `DocumentGroup`
- `Settings`
- `WKNotificationScene`
- `Commands`
- `CommandMenu`

Với iOS app thông thường, bạn sẽ gặp `WindowGroup` nhiều nhất.

## Theo dõi trạng thái app với ScenePhase

Trong UIKit, ta thường theo dõi trạng thái app bằng các callback trong `AppDelegate` hoặc `SceneDelegate`. Với SwiftUI, Apple cung cấp `scenePhase` trong environment.

```swift
@Environment(\.scenePhase) private var scenePhase
```

`ScenePhase` có ba trạng thái chính:

- `active`: app đang active và người dùng có thể tương tác.
- `inactive`: app tạm thời không nhận tương tác, ví dụ khi có cuộc gọi hoặc đang chuyển trạng thái.
- `background`: app đã vào background.

Ví dụ theo dõi trạng thái app:

```swift
import SwiftUI

@main
struct TheNewAppApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("App State: Active")
            case .inactive:
                print("App State: Inactive")
            case .background:
                print("App State: Background")
            @unknown default:
                print("App State: Unknown")
            }
        }
    }
}
```

`scenePhase` phù hợp cho các tác vụ như:

- Tạm dừng hoặc tiếp tục animation.
- Lưu dữ liệu khi app vào background.
- Refresh dữ liệu khi app active lại.
- Dừng các task không cần thiết khi app không còn active.

## Khởi tạo app với init

Trong UIKit, `application(_:didFinishLaunchingWithOptions:)` thường là nơi cấu hình ban đầu cho app. Với SwiftUI App Life Cycle, bạn có thể dùng `init()` trong struct `App`.

```swift
@main
struct TheNewAppApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Cấu hình ban đầu:
        // - setup service
        // - config SDK
        // - chuẩn bị dữ liệu
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { phase in
            print("Scene phase:", phase)
        }
    }
}
```

`init()` nên được dùng cho các cấu hình cần chạy sớm. Tuy nhiên, tránh đặt logic quá nặng trực tiếp trong `init`, vì nó có thể làm chậm quá trình khởi động app.

## Xử lý Deeplink với onOpenURL

Deeplink là cách mở app bằng một URL từ bên ngoài. Trong UIKit, ta thường xử lý bằng `application(_:open:options:)`. Với SwiftUI, có thể dùng modifier `onOpenURL`.

Ví dụ `ContentView` nhận tên từ deeplink:

```swift
import SwiftUI

struct ContentView: View {
    let name: String

    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()

            Text(name.isEmpty ? "---" : name)
                .font(.title)
                .foregroundColor(.blue)
                .padding()
        }
    }
}
```

Tạo extension để đọc query parameter từ URL:

```swift
import Foundation

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: absoluteString) else {
            return nil
        }

        return url.queryItems?
            .first(where: { $0.name == queryParameterName })?
            .value
    }
}
```

Xử lý URL trong file App:

```swift
import SwiftUI

@main
struct TheNewAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var name: String = ""

    var body: some Scene {
        WindowGroup {
            ContentView(name: name)
                .onOpenURL { url in
                    name = url.valueOf("name") ?? ""

                    print(url.absoluteURL)
                    print(name)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("App State: Active")
            case .inactive:
                print("App State: Inactive")
            case .background:
                print("App State: Background")
            @unknown default:
                print("App State: Unknown")
            }
        }
    }
}
```

Ví dụ URL mở app:

```text
fxapp://fxapp.com?name=FxStudio
```

Để deeplink hoạt động, bạn vẫn cần cấu hình URL scheme trong target settings của project.

## Khi nào vẫn cần AppDelegate?

Dù SwiftUI App Life Cycle đã gọn hơn, một số trường hợp vẫn cần logic kiểu AppDelegate:

- Tích hợp SDK cũ yêu cầu AppDelegate callback.
- Xử lý push notification theo API truyền thống.
- Cần nhận một số event chỉ có trong `UIApplicationDelegate`.
- App đang migrate dần từ UIKit sang SwiftUI.

SwiftUI vẫn cho phép kết nối AppDelegate bằng property wrapper `@UIApplicationDelegateAdaptor`:

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        true
    }
}

@main
struct TheNewAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(name: "")
        }
    }
}
```

## Tóm tắt

- SwiftUI App Life Cycle dùng `@main` và protocol `App` làm entry point.
- `body` của `App` trả về `Scene`, thường là `WindowGroup`.
- `scenePhase` giúp theo dõi trạng thái `active`, `inactive`, `background`.
- `init()` trong `App` có thể thay thế một phần vai trò khởi tạo của `didFinishLaunchingWithOptions`.
- `onOpenURL` dùng để xử lý deeplink trong SwiftUI.
- Khi cần tích hợp API cũ, có thể dùng `@UIApplicationDelegateAdaptor` để kết nối AppDelegate vào SwiftUI App.

Tham khảo demo: [swiftui-notes](https://github.com/fx-studio/swiftui-notes)
