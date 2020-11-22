// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MMNumberKeyboard",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "MMNumberKeyboard", targets: ["MMNumberKeyboard"]),
    ],
    targets: [
        .target(name: "MMNumberKeyboard", path: ".", exclude: ["Demo", "LICENSE", "MMNumberKeyboard.podspec", "UniversalScreenshot.png", "Info.plist", "README.md"], sources: ["Classes"], resources: [.process("Images")], cSettings: [.headerSearchPath("Classes")])
    ]
)
