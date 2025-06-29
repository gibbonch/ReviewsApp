// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "ImageLoader",
    products: [
        .library(name: "ImageLoader", targets: ["ImageLoader"]),
    ],
    targets: [
        .target(name: "ImageLoader"),
    ]
)
