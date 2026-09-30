// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-tls",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "TLS", targets: ["TLS"]),
        .library(name: "TLS Apple Engine", targets: ["TLS Apple Engine"]),
        .library(name: "TLS OpenSSL Engine", targets: ["TLS OpenSSL Engine"]),
        .library(name: "TLS SChannel Engine", targets: ["TLS SChannel Engine"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-compositions/swift-domain-name-system.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-ip-address.git", branch: "main"),
        .package(
            url: "https://github.com/swift-compositions/swift-certificate-verification.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-io-kernel.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-sockets.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-span.git", branch: "main", traits: ["Byte", "Iterator"]),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main", traits: ["Coder", "Parser", "Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main", traits: ["Carrier", "Map"]),
        .package(url: "https://github.com/swift-atoms/swift-ratio.git", branch: "main", traits: ["Bit", "Ordinal", "Difference"]),
        .package(url: "https://github.com/swift-atoms/swift-finite.git", branch: "main", traits: ["Tagged"]),
        .package(url: "https://github.com/swift-atoms/swift-memory.git", branch: "main", traits: ["Lock", "Map", "Shared", "Cursor"]),
        .package(url: "https://github.com/swift-atoms/swift-storage.git", branch: "main", traits: ["Generational", "Memory"]),
    ],
    targets: [
        .target(
            name: "TLS",
            dependencies: [
                .product(name: "Domain Name System", package: "swift-domain-name-system"),
                .product(name: "IP Address", package: "swift-ip-address"),
                .product(name: "Certificates", package: "swift-certificate-verification"),
                .product(name: "IO Kernel", package: "swift-io-kernel"),
                .product(name: "Sockets", package: "swift-sockets"),
                .product(name: "Span", package: "swift-span"),
            ]
        ),
        .target(
            name: "TLS Engine Interface",
            dependencies: ["TLS", .product(name: "Sockets", package: "swift-sockets")]
        ),
        .target(name: "TLS Apple Engine", dependencies: ["TLS", "TLS Engine Interface"]),
        .target(name: "TLS OpenSSL Engine", dependencies: ["TLS", "TLS Engine Interface"]),
        .target(name: "TLS SChannel Engine", dependencies: ["TLS", "TLS Engine Interface"]),
        .testTarget(
            name: "TLS Contract Tests",
            dependencies: ["TLS", "TLS Apple Engine", "TLS OpenSSL Engine", "TLS SChannel Engine"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableExperimentalFeature("Lifetimes"),
                .enableUpcomingFeature("InferIsolatedConformances"),
        ]
}
