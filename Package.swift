// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "EmpathyApp",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.1.0")
    ],
    targets: [
        .target(
            name: "EmpathyApp",
            dependencies: [
                .product(name: "JWTDecode", package: "JWTDecode.swift")
            ]
        )
    ]
) 