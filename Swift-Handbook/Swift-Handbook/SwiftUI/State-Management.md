# State Management trong SwiftUI

SwiftUI là framework được Apple giới thiệu tại WWDC 2019 để xây dựng giao diện theo phong cách declarative. Thay vì thay đổi trực tiếp từng view như UIKit, SwiftUI mô tả UI dựa trên state hiện tại của ứng dụng.

Ý tưởng quan trọng nhất là:

> UI là kết quả của state. Khi state thay đổi, SwiftUI tự cập nhật lại view tương ứng.

Trong UIKit, khi dữ liệu thay đổi ta thường phải tự gọi các hàm như:

- `tableView.reloadData()`
- `label.text = value`
- `view.isHidden = true`

Với SwiftUI, ta thay đổi dữ liệu, còn framework sẽ quyết định phần giao diện nào cần render lại. Điều này đặc biệt phù hợp với các mô hình như MVVM, nơi view hiển thị dữ liệu từ view model.

## State là gì?

State là dữ liệu quyết định giao diện đang hiển thị như thế nào.

Ví dụ:

- Text đang hiển thị trên `Text`.
- Danh sách item dùng để render `List`.
- Biến `isLoading` để hiển thị loading.
- Biến `isPresented` để mở hoặc đóng một sheet.
- Dữ liệu trong view model được bind lên view.

Khi những giá trị này thay đổi, SwiftUI sẽ tính toán lại `body` và cập nhật UI.

## Vì sao cần property wrapper?

View trong SwiftUI thường là `struct`. Vì `struct` là value type, bản thân view không nên tự thay đổi dữ liệu lưu trực tiếp bên trong nó theo cách thông thường.

Ví dụ sau sẽ dễ gặp lỗi vì `self` trong view là immutable:

```swift
struct ContentView: View {
    var detailText = "Hello"

    var body: some View {
        VStack {
            Text(detailText)

            Button("Change") {
                detailText = "Updated"
            }
        }
    }
}
```

SwiftUI cung cấp các property wrapper như `@State`, `@ObservedObject`, `@EnvironmentObject`, `@Binding` để quản lý dữ liệu đúng cách.

## @State

`@State` dùng cho state đơn giản, thuộc sở hữu riêng của một view.

```swift
struct ContentView: View {
    @State private var detailText = "Hello"

    var body: some View {
        VStack {
            Text(detailText)

            Button("Change") {
                detailText = "Updated"
            }
        }
    }
}
```

Khi `detailText` thay đổi, SwiftUI tự cập nhật `Text` tương ứng. Ta không cần gọi hàm cập nhật UI thủ công.

Nên dùng `@State` khi:

- Dữ liệu đơn giản như `String`, `Bool`, `Int`, enum.
- Dữ liệu chỉ thuộc về một view.
- Không cần truy cập hoặc thay đổi trực tiếp từ bên ngoài view.

Thông thường, property dùng `@State` nên khai báo `private` để thể hiện rằng state này là nội bộ của view.

```swift
@State private var isLoading = false
@State private var selectedTab = 0
@State private var searchText = ""
```

## @ObservedObject

`@ObservedObject` dùng khi view cần theo dõi một object bên ngoài, thường là view model.

Object này phải conform `ObservableObject`. Những property cần làm UI cập nhật khi thay đổi thường được đánh dấu bằng `@Published`.

```swift
final class MainViewModel: ObservableObject {
    @Published var title: String = "Initial title"
    @Published var isLoading: Bool = false

    func fetchData() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.title = "Loaded data"
            self.isLoading = false
        }
    }
}
```

View sử dụng view model:

```swift
struct ContentView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            }

            Text(viewModel.title)

            Button("Fetch") {
                viewModel.fetchData()
            }
        }
    }
}
```

Khi `title` hoặc `isLoading` thay đổi, object sẽ thông báo cho view và SwiftUI render lại phần UI liên quan.

Nên dùng `@ObservedObject` khi:

- State nằm trong một reference type như class.
- View model được tạo hoặc sở hữu từ bên ngoài view.
- Một object có thể được truyền qua nhiều view.
- Cần tổ chức logic phức tạp hơn thay vì để trực tiếp trong view.

Lưu ý: các thay đổi làm cập nhật UI nên xảy ra trên main thread.

## @EnvironmentObject

`@EnvironmentObject` dùng cho object được chia sẻ rộng trong nhiều view. Thay vì truyền object qua từng tầng view, ta inject object vào environment, sau đó view con nào cần thì lấy ra dùng.

Ví dụ app state dùng chung:

```swift
final class AppSession: ObservableObject {
    @Published var username: String = ""
    @Published var isLoggedIn: Bool = false
}
```

Inject vào root view:

```swift
@main
struct MyApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
```

Sử dụng trong view con:

```swift
struct ProfileView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        Text(session.username)
    }
}
```

Nên dùng `@EnvironmentObject` khi:

- Object cần dùng ở nhiều nơi trong app.
- Không muốn truyền dependency qua quá nhiều tầng view.
- Dữ liệu mang tính toàn cục như session, auth state, app settings, theme.

Lưu ý: nếu view khai báo `@EnvironmentObject` nhưng chưa được inject object tương ứng, app có thể crash khi chạy.

## @Binding

`@Binding` dùng khi một view con cần đọc và thay đổi state được sở hữu bởi view cha.

Ví dụ view cha có state quyết định hiển thị form thêm user:

```swift
struct ContentView: View {
    @State private var showingAddUser = false

    var body: some View {
        Button("Add User") {
            showingAddUser = true
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView(isPresented: $showingAddUser)
        }
    }
}
```

View con nhận binding:

```swift
struct AddUserView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Add User")

            Button("Done") {
                isPresented = false
            }
        }
    }
}
```

`$showingAddUser` là binding đến state thật. Khi `AddUserView` set `isPresented = false`, giá trị `showingAddUser` ở `ContentView` cũng đổi theo, và sheet được đóng.

Nên dùng `@Binding` khi:

- View con cần thay đổi state của view cha.
- Không muốn view con tự sở hữu state đó.
- Cần tạo reusable component nhận dữ liệu từ bên ngoài.

## So sánh nhanh

| Property wrapper | Dùng khi nào? | Ai sở hữu dữ liệu? |
|------------------|---------------|--------------------|
| `@State` | State đơn giản, nội bộ một view | View hiện tại |
| `@ObservedObject` | View theo dõi object/view model từ bên ngoài | Bên ngoài view |
| `@EnvironmentObject` | Object dùng chung nhiều nơi | Environment/root app |
| `@Binding` | View con đọc và sửa state của view cha | View cha hoặc nguồn bên ngoài |

## Tóm tắt

- SwiftUI xây dựng UI theo hướng state-driven: state thay đổi thì UI tự cập nhật.
- `@State` phù hợp với dữ liệu đơn giản và chỉ thuộc về một view.
- `@ObservedObject` phù hợp với view model hoặc object phức tạp conform `ObservableObject`.
- `@EnvironmentObject` phù hợp với dữ liệu dùng chung trong nhiều view.
- `@Binding` dùng để view con thao tác trên state do view cha sở hữu.

Hiểu đúng các property wrapper này giúp code SwiftUI rõ ràng hơn, dễ tách view, dễ áp dụng MVVM và hạn chế việc cập nhật UI thủ công.
