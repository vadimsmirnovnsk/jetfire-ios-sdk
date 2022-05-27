// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jetfire",
	platforms: [
		.iOS(.v13),
	],
    products: [
        .library(name: "Jetfire", targets: ["Jetfire"])
    ],
	dependencies: [],
    targets: [
        .target(
            name: "UIColorHexSwift",
            dependencies: [],
            path: "Thirdparty/UIColor-Hex-Swift/HEXColor"
        ),
        .target(
            name: "KeychainAccess",
            path: "Thirdparty/KeychainAccess/Lib/KeychainAccess"
        ),
        .target(
            name: "SDWebImage",
            path: "Thirdparty/SDWebImage/SDWebImage",
            sources: ["Core", "Private"],
            cSettings: [
                .headerSearchPath("Core"),
                .headerSearchPath("Private")
            ]
        ),
        .target(
            name: "OrderedCollections",
            path: "Thirdparty/swift-collections/Sources/OrderedCollections",
            exclude: ["CMakeLists.txt"],
            swiftSettings: nil
        ),
        .target(
            name: "Alamofire",
            path: "Thirdparty/Alamofire/Source",
            exclude: ["Info.plist"],
            linkerSettings: [
                .linkedFramework("CFNetwork", .when(platforms: [
                    .iOS, .macOS, .tvOS, .watchOS
                ]))
            ]),
        .target(
            name: "SwiftProtobuf",
            path: "Thirdparty/swift-protobuf/Sources/SwiftProtobuf"
        ),
        .target(
            name: "SQLiteObjc",
            path: "Thirdparty/SQLite.swift/Sources/SQLiteObjc",
            exclude: [
                "fts3_tokenizer.h"
            ]
        ),
        .target(
            name: "SQLite",
            dependencies: ["SQLiteObjc"],
            path: "Thirdparty/SQLite.swift/Sources/SQLite",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "SnapKit",
            path: "Thirdparty/SnapKit/Sources"
        ),
        .target(
            name: "VNEssential",
            path: "Thirdparty/VNBase/VNBase/Essential"
        ),
        .target(
            name: "VNHandlers",
            path: "Thirdparty/VNBase/VNBase/Handlers"
        ),
        .target(
            name: "VNBase",
            dependencies: [
                "VNEssential",
                "SnapKit",
                "VNHandlers"
            ],
            path: "Thirdparty/VNBase/VNBase/Classes"
        ),
        .target(
            name: "Jetfire",
            dependencies: [
                "UIColorHexSwift",
                "KeychainAccess",
                "SDWebImage",
                "OrderedCollections",
                "Alamofire",
                "SwiftProtobuf",
                "SQLite",
                "VNBase"
			],
			exclude: ["Model/protocol.proto"]
		),
        .testTarget(
            name: "JetfireTests",
            dependencies: ["Jetfire"],
			resources: [
				.copy("JetfireService-Info.plist")
		]),
    ]
)
