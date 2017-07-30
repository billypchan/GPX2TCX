// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "GPX2TCX",
    dependencies: [
        .Package(url: "https://github.com/tadija/AEXML.git", majorVersion: 4),
        .Package(url: "https://github.com/kylef/PathKit", majorVersion:0),
    ]
)
