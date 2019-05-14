// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "server",
    products: [
        .library(name: "server", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // Mongo Db
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "MongoKitten"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
