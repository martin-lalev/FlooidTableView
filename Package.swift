// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FlooidTableView",
    platforms: [.iOS(.v13)],
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
            path: "FlooidTableView",
            exclude: ["Info.plist"]),
    ]
)
