// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jetfire-sdk",
	platforms: [
		.iOS(.v13),
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "jetfire-sdk",
            targets: ["jetfire-sdk"]),
    ],
	dependencies: [
		.package(url: "https://github.com/teanet/VNBase.git", .branch("master")),
		.package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire", from: "5.4.3"),
		.package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
		.package(url: "https://github.com/yeahdongcn/UIColor-Hex-Swift", from: "5.1.7"),
	],
    targets: [
        .target(
            name: "jetfire-sdk",
            dependencies: [
				.product(name: "VNHandlers", package: "VNBase"),
				.product(name: "VNEssential", package: "VNBase"),
				.product(name: "VNBase", package: "VNBase"),
				.product(name: "Alamofire", package: "Alamofire"),
				.product(name: "SDWebImage", package: "SDWebImage"),
//				.product(name: "UIColorHexSwift", package: "UIColorHexSwift"),
			]),
        .testTarget(
            name: "jetfire-sdkTests",
            dependencies: ["jetfire-sdk"]),
    ]
)
