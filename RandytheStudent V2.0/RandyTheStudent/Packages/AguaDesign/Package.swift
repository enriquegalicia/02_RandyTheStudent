// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AguaDesign",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AguaDesign", targets: ["AguaDesign"])
    ],
    targets: [
        .target(name: "AguaDesign")
    ]
)
