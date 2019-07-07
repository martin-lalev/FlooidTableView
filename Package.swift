// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FlooidTableView",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "FlooidTableView",
            targets: ["FlooidTableView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlooidTableView",
            path: "FlooidTableView"),
    ]
)
