# UIKit vs SwiftUI

UIKit và SwiftUI đều là framework để xây dựng giao diện trên iOS, nhưng chúng đi theo hai tư duy khác nhau.

- UIKit là framework truyền thống, imperative, ổn định, rất mạnh khi cần kiểm soát chi tiết UI.
- SwiftUI là framework declarative, hiện đại, giúp viết UI ngắn gọn hơn và phản ứng tự nhiên theo state.

Trong thực tế, không nhất thiết phải chọn một trong hai tuyệt đối. Rất nhiều app hiện đại dùng cả UIKit và SwiftUI trong cùng một codebase.

## Tư duy khác nhau

### UIKit: Imperative UI

Với UIKit, ta thường tạo view, giữ reference tới view, rồi thay đổi trực tiếp thuộc tính của view khi dữ liệu thay đổi.

```swift
titleLabel.text = "Hello"
loadingView.isHidden = false
tableView.reloadData()
```

UIKit trả lời câu hỏi:

> Muốn UI đổi thì phải gọi lệnh gì?

Bạn chủ động điều khiển lifecycle, layout, animation, navigation và cập nhật giao diện.

### SwiftUI: Declarative UI

Với SwiftUI, ta mô tả UI tương ứng với state hiện tại. Khi state đổi, SwiftUI tự tính toán và render lại phần cần thiết.

```swift
struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            }

            Text("Hello")
        }
    }
}
```

SwiftUI trả lời câu hỏi:

> Với state hiện tại, UI nên trông như thế nào?

## So sánh nhanh

| Tiêu chí | UIKit | SwiftUI |
|---------|-------|---------|
| Cách viết UI | Imperative | Declarative |
| Năm ra mắt | Rất lâu đời | WWDC 2019 |
| Độ ổn định | Rất cao | Tốt, nhưng một số API mới thay đổi theo iOS |
| Hỗ trợ iOS cũ | Tốt hơn | Thường cần iOS 13+, nhiều API mới cần iOS cao hơn |
| Layout | Auto Layout, frame, constraint | Stack, modifier, layout system |
| State binding | Tự quản lý nhiều hơn | Tích hợp sẵn qua `@State`, `@Binding`, `ObservableObject` |
| Custom UI phức tạp | Kiểm soát rất chi tiết | Nhanh hơn cho UI phổ biến, đôi khi khó với case quá custom |
| Preview | Không native mạnh bằng | Có SwiftUI Preview |
| Learning curve | Dễ nếu đã quen UIKit, nhiều API lớn | Dễ bắt đầu, nhưng khó khi state/lifecycle phức tạp |
| Ecosystem | Rất nhiều thư viện, code legacy | Đang phát triển mạnh |

## Khi nào nên dùng UIKit?

UIKit phù hợp khi:

- App cần hỗ trợ iOS version cũ.
- Project hiện tại đã viết bằng UIKit và rất lớn.
- UI cần kiểm soát chi tiết lifecycle, animation, gesture hoặc performance.
- Màn hình dùng nhiều component UIKit đã ổn định như `UICollectionView`, `UITableView`, `UITextView`, `WKWebView`, camera, map, custom transition.
- Team đã quen UIKit và deadline ngắn.
- Bạn cần dùng thư viện bên thứ ba chỉ hỗ trợ UIKit.
- Màn hình có flow phức tạp với navigation, coordinator, custom container view controller.

Ví dụ nên cân nhắc UIKit:

- App production lâu năm đang maintain.
- Màn hình camera hoặc video editor.
- Rich text editor.
- Màn hình có collection view layout cực kỳ custom.
- Component cần tối ưu performance ở mức chi tiết.

## Khi nào nên dùng SwiftUI?

SwiftUI phù hợp khi:

- App mới, target iOS tương đối mới.
- UI phụ thuộc nhiều vào state và cần binding dữ liệu rõ ràng.
- Cần phát triển nhanh các màn hình form, setting, profile, onboarding, dashboard.
- Muốn tận dụng SwiftUI Preview để iterate UI nhanh.
- App hướng tới nhiều nền tảng Apple như iOS, iPadOS, macOS, watchOS.
- Team muốn code UI ngắn gọn, dễ đọc và dễ compose thành component nhỏ.
- Project áp dụng MVVM hoặc state-driven UI.

Ví dụ nên cân nhắc SwiftUI:

- Màn hình settings.
- Form nhập liệu.
- Profile screen.
- Onboarding.
- Dashboard đơn giản.
- Widget, watchOS app.
- Prototype hoặc MVP cần làm nhanh.

## Cách chọn trong project thực tế

Nếu bắt đầu app mới:

- Dùng SwiftUI cho phần lớn màn hình nếu target iOS đủ mới.
- Dùng UIKit cho những component mà SwiftUI chưa đủ mạnh hoặc chưa ổn định.

Nếu đang maintain app UIKit:

- Không cần rewrite toàn bộ sang SwiftUI.
- Có thể thêm màn hình mới bằng SwiftUI.
- Có thể dùng SwiftUI cho component nhỏ bên trong màn UIKit.
- Migrate dần những phần ít rủi ro trước.

Nếu app SwiftUI gặp component UIKit mạnh hơn:

- Wrap UIKit bằng `UIViewRepresentable` hoặc `UIViewControllerRepresentable`.
- Giữ logic SwiftUI ở bên ngoài, chỉ để UIKit component xử lý phần hiển thị hoặc interaction đặc thù.

## Tích hợp UIKit vào SwiftUI với UIViewRepresentable

`UIViewRepresentable` cho phép dùng một `UIView` của UIKit bên trong SwiftUI.

Protocol này thường cần hai hàm chính:

- `makeUIView(context:)`: tạo UIKit view.
- `updateUIView(_:context:)`: cập nhật UIKit view khi state SwiftUI thay đổi.

Ví dụ wrap `UILabel`:

```swift
import SwiftUI
import UIKit

struct UIKitLabel: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }
}
```

Dùng trong SwiftUI:

```swift
struct ContentView: View {
    @State private var title = "Hello from UIKit"

    var body: some View {
        VStack {
            UIKitLabel(text: title)

            Button("Update") {
                title = "Updated text"
            }
        }
        .padding()
    }
}
```

Khi `title` thay đổi, SwiftUI gọi `updateUIView`, và `UILabel` được cập nhật.

## Coordinator trong UIViewRepresentable

Khi UIKit view cần delegate, target-action hoặc callback về SwiftUI, ta thường dùng `Coordinator`.

Ví dụ wrap `UITextField`:

```swift
import SwiftUI
import UIKit

struct UIKitTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        private var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        @objc func textDidChange(_ sender: UITextField) {
            text.wrappedValue = sender.text ?? ""
        }
    }
}
```

Dùng trong SwiftUI:

```swift
struct FormView: View {
    @State private var username = ""

    var body: some View {
        VStack {
            UIKitTextField(text: $username, placeholder: "Username")
            Text(username)
        }
        .padding()
    }
}
```

`Coordinator` đóng vai trò cầu nối từ UIKit event về SwiftUI state.

## Tích hợp UIViewController vào SwiftUI

Nếu cần dùng một `UIViewController`, ta dùng `UIViewControllerRepresentable`.

Ví dụ wrap `UIImagePickerController`:

```swift
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.selectedImage = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
```

## Tích hợp SwiftUI vào UIKit

Để dùng SwiftUI view trong UIKit, ta dùng `UIHostingController`.

Ví dụ có một SwiftUI view:

```swift
import SwiftUI

struct ProfileHeaderView: View {
    let name: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))

            Text(name)
                .font(.headline)
        }
        .padding()
    }
}
```

Push SwiftUI screen từ UIKit:

```swift
import UIKit
import SwiftUI

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    func showSwiftUIScreen() {
        let swiftUIView = ProfileHeaderView(name: "Taylor")
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}
```

Embed SwiftUI view vào một UIKit view controller:

```swift
import UIKit
import SwiftUI

final class ContainerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = ProfileHeaderView(name: "Taylor")
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
```

## Truyền dữ liệu giữa UIKit và SwiftUI

Khi UIKit tạo SwiftUI view, dữ liệu có thể truyền qua initializer:

```swift
let view = ProfileHeaderView(name: user.name)
let hostingController = UIHostingController(rootView: view)
```

Nếu SwiftUI cần callback ngược về UIKit, truyền closure:

```swift
struct ConfirmView: View {
    let onConfirm: () -> Void

    var body: some View {
        Button("Confirm") {
            onConfirm()
        }
    }
}
```

UIKit sử dụng:

```swift
let view = ConfirmView {
    print("User confirmed")
}

let hostingController = UIHostingController(rootView: view)
```

## Best Practices khi dùng chung UIKit và SwiftUI

- Không rewrite toàn bộ app chỉ vì muốn dùng SwiftUI.
- Dùng SwiftUI cho màn mới hoặc component ít rủi ro trước.
- Wrap UIKit khi SwiftUI thiếu API hoặc component UIKit đã quá ổn định.
- Tách logic ra view model/service để UIKit và SwiftUI đều dùng được.
- Tránh để UIKit view tự quản lý state trùng với SwiftUI state.
- Khi dùng `UIViewRepresentable`, cập nhật view trong `updateUIView`, không tạo lại view thủ công.
- Dùng `Coordinator` cho delegate/callback từ UIKit về SwiftUI.
- Với app lớn, nên có ranh giới rõ ràng: màn nào UIKit, màn nào SwiftUI, bridge ở đâu.

## Tóm tắt

- UIKit mạnh, ổn định, kiểm soát chi tiết và phù hợp với codebase lâu năm.
- SwiftUI gọn, hiện đại, phù hợp UI theo state và phát triển nhanh.
- UIKit vào SwiftUI: dùng `UIViewRepresentable` hoặc `UIViewControllerRepresentable`.
- SwiftUI vào UIKit: dùng `UIHostingController`.
- Cách tiếp cận thực tế nhất là kết hợp cả hai theo nhu cầu, không cực đoan chọn một bên cho mọi trường hợp.
