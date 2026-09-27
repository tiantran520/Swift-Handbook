# Auto Layout Priority

Link tham khảo: [AutoLayout Priority](https://thanhvu.dev/2019/09/16/autolayout-priority/)

Auto Layout không chỉ dựa vào các constraint để tính vị trí và kích thước của view. Khi có nhiều constraint cùng tác động lên một view, hoặc khi nội dung bên trong view thay đổi, hệ thống sẽ dùng priority để quyết định constraint nào quan trọng hơn.

![AutoLayout Priority](https://thanhvu.dev/wp-content/uploads/2019/09/Autolayout-priority.png)

## Constraint Priority

Constraint priority là độ ưu tiên của constraint. Nó giúp Auto Layout engine giải quyết các xung đột khi layout giao diện.

Ví dụ: chúng ta có một giao diện gồm tab để chuyển đổi giữa `Content1` và `Content2`. Hai phần content này có chiều cao khác nhau. Bên dưới content có hai button `OK` và `Cancel`. Nhiệm vụ là khi đổi tab, view cha `Contents` phải tự co giãn vừa khít theo content đang được hiển thị.

![Constraint Priority Example](https://i2.wp.com/thanhvu.dev/wp-content/uploads/2019/09/Screen-Shot-2019-09-15-at-3.36.33-PM.png)

Cả `Content1` và `Content2` đều có bottom constraint với view cha. Bên trong mỗi content lại có label tự xác định chiều cao theo nội dung. Khi đó ta có thể dùng priority để quyết định `Content1` hay `Content2` sẽ là view quyết định chiều cao của `Contents`.

Khi người dùng chuyển tab, ta thay đổi priority bằng code:

```objc
@interface ViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content1BottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content2BottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *content1View;
@property (weak, nonatomic) IBOutlet UIView *content2View;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tap1DidTap:nil];
}

- (IBAction)tap1DidTap:(id)sender {
    self.content1BottomConstraint.priority = 999;
    self.content2BottomConstraint.priority = 222;
    self.content1View.hidden = NO;
    self.content2View.hidden = YES;
}

- (IBAction)tap2DidTap:(id)sender {
    self.content2BottomConstraint.priority = 999;
    self.content1BottomConstraint.priority = 222;
    self.content2View.hidden = NO;
    self.content1View.hidden = YES;
}

@end
```

Kết quả là khi đổi tab, view cha sẽ lấy chiều cao theo content đang được active.

![Constraint Priority Result](https://i0.wp.com/thanhvu.dev/wp-content/uploads/2019/09/autolayout-priority-1.gif)

Lưu ý: chỉ nên thay đổi priority khi constraint chưa bị yêu cầu là bắt buộc tuyệt đối. Nếu muốn thay đổi priority trong runtime như ví dụ trên, priority ban đầu trong storyboard/xib nên khác `1000`. Constraint có priority `1000` là required constraint, vì vậy việc đổi nó sang priority thấp hơn dễ gây warning hoặc lỗi layout.

Example: [DemoAutolayoutPriority](https://github.com/ThanhDev2703/DemoAutolayoutPriority)

## Intrinsic Content Size

Intrinsic content size là kích thước tự nhiên của một view. Kích thước này được xác định bởi chính view đó hoặc bởi nội dung/subview bên trong nó.

Ví dụ:

- `UILabel` có intrinsic content size dựa trên text, font và số dòng.
- `UIButton` có intrinsic content size dựa trên title, image, font và padding.
- `UITextView` có thể có kích thước tự nhiên dựa trên nội dung text.

Nhờ intrinsic content size, nhiều view không cần khai báo width hoặc height cố định mà vẫn có thể được Auto Layout tính toán đúng.

## Content Hugging Priority

Content hugging priority là độ ưu tiên quyết định việc view không bị giãn lớn hơn intrinsic content size. Có thể hiểu ngắn gọn: hugging priority càng cao thì view càng cố giữ kích thước tự nhiên, càng không muốn bị kéo giãn.

![Content Hugging Priority](https://i0.wp.com/thanhvu.dev/wp-content/uploads/2019/09/17vMoQMGU334fB4MyqeSR_w.png)

Ví dụ: trong một custom cell có chiều cao động, `Title` và `SubTitle` được layout cạnh nhau hoặc theo một quan hệ khiến Auto Layout phải quyết định label nào giữ đúng kích thước tự nhiên, label nào được giãn ra. Khi đó ta tăng content hugging priority của `Title` cao hơn `SubTitle` để `Title` ưu tiên giữ kích thước theo nội dung.

Mặc định, content hugging priority thường là `250`. Riêng `UILabel` thường có giá trị mặc định là `251` cho cả chiều ngang và chiều dọc.

## Content Compression Resistance Priority

Content compression resistance priority là độ ưu tiên quyết định việc view không bị co nhỏ hơn intrinsic content size. Có thể hiểu ngắn gọn: compression resistance càng cao thì view càng chống lại việc bị nén.

Ví dụ: màn hình có một button để chuyển sang màn search và một button hiển thị tên tỉnh thành. Nếu cả hai button đều có text dài, Auto Layout phải quyết định button nào được giữ đủ nội dung và button nào bị co lại.

![Content Compression Resistance Priority](https://i2.wp.com/thanhvu.dev/wp-content/uploads/2019/09/Screen-Shot-2019-09-15-at-4.38.01-PM.png)

Trong trường hợp muốn button chuyển sang màn search hiển thị đầy đủ hơn, ta set content compression resistance priority của button đó cao hơn. Khi thiếu không gian, button hiển thị city sẽ bị co lại trước.

![Compression Result](https://i2.wp.com/thanhvu.dev/wp-content/uploads/2019/09/Screen-Shot-2019-09-15-at-5.03.30-PM.png)

Mặc định, content compression resistance priority thường là `750` cho cả chiều ngang và chiều dọc.

## Tóm tắt

- Constraint priority: quyết định constraint nào quan trọng hơn khi có xung đột.
- Intrinsic content size: kích thước tự nhiên của view dựa trên nội dung.
- Content hugging priority: quyết định view nào ít bị giãn ra hơn.
- Content compression resistance priority: quyết định view nào ít bị co lại hơn.

Khi layout bị ambiguous hoặc broken constraint, đừng chỉ thêm width/height cố định. Rất nhiều trường hợp có thể giải quyết sạch hơn bằng cách điều chỉnh hugging, compression resistance hoặc priority của constraint.
