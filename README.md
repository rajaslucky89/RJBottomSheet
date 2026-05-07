# RJBottomSheet

A lightweight and customizable bottom sheet component for iOS, supporting full, half, quart, and dynamic height modes.

Easily present any `UIViewController` in a stylish bottom sheet with support for header title, swipe indicator, and swipe-to-dismiss controls.

---

## ✨ Features

- ✅ Supports `.full`, `.half`, `.quart`, and `.dynamic` heights
- ✅ Optional swipe indicator
- ✅ Optional swipe-to-dismiss
- ✅ Custom header title support

---

## 📦 Installation

### ✅ Option 1: Add via Xcode GUI (Recommended)

1. Open your Xcode project.
2. Go to `File > Add Packages...`
3. Enter the repository URL:

https://github.com/rajaslucky89/RJBottomSheet.git

1. Select the latest version and click **Add Package**.

> ℹ️ Make sure your `Package.swift` has the same name as the folder (`RJBottomSheet`) to avoid import issues.
> 

---

### 💻 Option 2: Add via Swift Package Manager (Manual)

In your `Package.swift`, add:

```swift
dependencies: [
    .package(url: "https://github.com/rajaslucky89/RJBottomSheet.git", from: "1.0.0")
]
```

And add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["RJBottomSheet"]
)
```

## 🚀 Usage

```swift
let tncViewController = TNCViewController()

let bottomSheet = RJBottomSheet(for: tncViewController, height: .full)
    .isShowSwipeIndicatorView(false)
    .isSwipeToDismissEnable(false)

bottomSheet.setHeaderTitle("Title")

present(bottomSheet, animated: true)
```

![rjbottomsheet_demo](https://github.com/user-attachments/assets/9e9ed021-c463-44eb-a128-ac9d116f1e56)



https://github.com/user-attachments/assets/f9b5fe00-1d22-4cd1-a8f2-b8d11b14db47



## 🧩 Supported Heights

- .full
- .half
- .quart
- .dynamic

## 📄 License

MIT License. © 2025
