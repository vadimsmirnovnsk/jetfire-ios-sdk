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
            name: "JetfireUIColorHexSwift",
            dependencies: [],
            path: "Thirdparty/UIColor-Hex-Swift/HEXColor"
        ),
        .target(
            name: "JetfireKeychainAccess",
            path: "Thirdparty/KeychainAccess/Lib/KeychainAccess"
        ),
        .target(
            name: "JetfireSDWebImage",
            path: "Thirdparty/SDWebImage/SDWebImage",
            sources: ["Core", "Private"],
            cSettings: [
                .headerSearchPath("Core"),
                .headerSearchPath("Private")
            ]
        ),
        .target(
            name: "JetfireOrderedCollections",
            path: "Thirdparty/swift-collections/Sources/OrderedCollections",
            exclude: ["CMakeLists.txt"],
            swiftSettings: nil
        ),
        .target(
            name: "JetfireAlamofire",
            path: "Thirdparty/Alamofire/Source",
            exclude: ["Info.plist"],
            linkerSettings: [
                .linkedFramework("CFNetwork", .when(platforms: [
                    .iOS, .macOS, .tvOS, .watchOS
                ]))
            ]),
        .target(
            name: "JetfireProtobuf",
            path: "Thirdparty/swift-protobuf/Sources/SwiftProtobuf"
        ),
        .target(
            name: "JetfireSQLiteObjc",
            path: "Thirdparty/SQLite.swift/Sources/SQLiteObjc",
            exclude: [
                "fts3_tokenizer.h"
            ]
        ),
        .target(
            name: "JetfireSQLite",
            dependencies: ["JetfireSQLiteObjc"],
            path: "Thirdparty/SQLite.swift/Sources/SQLite",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "JetfireSnapKit",
            path: "Thirdparty/SnapKit/Sources"
        ),
        .target(
            name: "JetfireVNEssential",
            path: "Thirdparty/VNBase/VNBase/Essential"
        ),
        .target(
            name: "JetfireVNHandlers",
            path: "Thirdparty/VNBase/VNBase/Handlers"
        ),
        .target(
            name: "JetfireVNBase",
            dependencies: [
                "JetfireVNEssential",
                "JetfireSnapKit",
                "JetfireVNHandlers"
            ],
            path: "Thirdparty/VNBase/VNBase/Classes"
        ),
        .target(
            name: "Jetfire",
            dependencies: [
                "JetfireUIColorHexSwift",
                "JetfireKeychainAccess",
                "JetfireSDWebImage",
                "JetfireOrderedCollections",
                "JetfireAlamofire",
                "JetfireProtobuf",
                "JetfireSQLite",
                "JetfireVNBase"
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
