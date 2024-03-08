// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Injectle",
    products: [
        .library(
            name: "Injectle",
            targets: ["Injectle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simonsuska/mockaffee.git", exact: "1.0.0")
    ],
    targets: [
        .target(
            name: "Injectle"),
        .testTarget(
            name: "InjectleTests",
            dependencies: ["Injectle", .product(name: "Mockaffee", package: "mockaffee")]),
    ]
)
