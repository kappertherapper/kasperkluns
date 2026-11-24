@testable import kasperserver
import Vapor
import VaporTesting
import Testing

@Suite("App Tests")
struct kasperserverTests {

    // MARK: Health routes, no database required

    @Test("Root route responds with It works")
    func rootRoute() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "", afterResponse: { res in
                #expect(res.status == .ok)
                #expect(res.body.string == "It works!")
            })
        }
    }

    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }

    // MARK: Create validation, rejected before the database is touched

    @Test("Create product without a body returns bad request")
    func createProductWithoutBody() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.POST, "products", afterResponse: { res in
                #expect(res.status == .badRequest)
            })
        }
    }

    @Test("Create product with an unknown brand returns bad request")
    func createProductWithUnknownBrand() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(
                .POST, "products",
                beforeRequest: { req in
                    req.headers.replaceOrAdd(name: .contentType, value: "application/json")
                    req.body = ByteBuffer(string: """
                    {"name": "Bad brand", "sku": 424242, "brand": "NotABrand", "size": "42", "purchasePrice": 50.0, "purchaseDate": "2026-01-15T10:00:00Z", "description": null}
                    """)
                },
                afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
            )
        }
    }

    @Test("Create product with SKU lower than 1 returns bad request")
    func createProductWithZeroSKU() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(
                .POST, "products",
                beforeRequest: { req in
                    try req.content.encode(Self.makeProductRequest(sku: 0))
                },
                afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
            )
        }
    }

    @Test("Create product with purchase price lower than 1 returns bad request")
    func createProductWithZeroPrice() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(
                .POST, "products",
                beforeRequest: { req in
                    var payload = Self.makeProductRequest(sku: Self.uniqueSKU())
                    payload.purchasePrice = 0
                    try req.content.encode(payload)
                },
                afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
            )
        }
    }

    // MARK: Product CRUD, requires a running PostgreSQL database

    @Test("Full product lifecycle: create, read, update, mark as sold, delete")
    func productLifecycle() async throws {
        try await withApp(configure: configure) { app in
            let created = LockIsolated<ProductResponseContent?>(nil)
            let sku = Self.uniqueSKU()

            try await app.testing().test(
                .POST, "products",
                beforeRequest: { req in
                    try req.content.encode(Self.makeProductRequest(sku: sku))
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let product = try res.content.decode(ProductResponseContent.self)
                    #expect(product.name == "Test Runner")
                    #expect(product.brand == Brand.Nike.rawValue)
                    #expect(product.size == Size.size42.rawValue)
                    #expect(product.sold == false)
                    #expect(product.salePrice == nil)
                    created.setValue(product)
                }
            )

            let product = try #require(created.value)
            let id = product.id

            try await app.testing().test(.GET, "products", "\(id)", afterResponse: { res in
                #expect(res.status == .ok)
                let fetched = try res.content.decode(ProductResponseContent.self)
                #expect(fetched.id == id)
                #expect(fetched.name == "Test Runner")
                #expect(fetched.sku == sku)
            })

            try await app.testing().test(.GET, "products", afterResponse: { res in
                #expect(res.status == .ok)
                let products = try res.content.decode([ProductResponseContent].self)
                #expect(products.contains { $0.id == id })
            })

            try await app.testing().test(
                .PUT, "products", "\(id)",
                beforeRequest: { req in
                    try req.content.encode(ProductRequestContent(
                        name: "Test Runner Updated",
                        sku: sku,
                        description: "Updated by the test suite",
                        brand: .Salomon,
                        size: .size43,
                        purchasePrice: 89.5,
                        purchaseDate: Date(timeIntervalSince1970: 1_735_689_600)
                    ))
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let updated = try res.content.decode(ProductResponseContent.self)
                    #expect(updated.name == "Test Runner Updated")
                    #expect(updated.brand == Brand.Salomon.rawValue)
                    #expect(updated.size == Size.size43.rawValue)
                    #expect(updated.purchasePrice == 89.5)
                }
            )

            // The sold route decodes dates as seconds since 1970,
            // so the body is sent as raw JSON instead of encoding a Date.
            try await app.testing().test(
                .PATCH, "products", "\(id)",
                beforeRequest: { req in
                    req.headers.replaceOrAdd(name: .contentType, value: "application/json")
                    req.body = ByteBuffer(string: #"{"sold": true, "salePrice": 120.0, "saleDate": 1737014400}"#)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let sold = try res.content.decode(ProductResponseContent.self)
                    #expect(sold.sold == true)
                    #expect(sold.salePrice == 120.0)
                }
            )

            try await app.testing().test(.DELETE, "products", "\(id)", afterResponse: { res in
                #expect(res.status == .noContent)
            })

            try await app.testing().test(.GET, "products", "\(id)", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    @Test("Product endpoints with an unknown id return not found")
    func unknownProductReturnsNotFound() async throws {
        try await withApp(configure: configure) { app in
            let id = UUID()

            try await app.testing().test(.GET, "products", "\(id)", afterResponse: { res in
                #expect(res.status == .notFound)
            })

            try await app.testing().test(
                .PUT, "products", "\(id)",
                beforeRequest: { req in
                    try req.content.encode(Self.makeProductRequest(sku: Self.uniqueSKU()))
                },
                afterResponse: { res in
                    #expect(res.status == .notFound)
                }
            )

            try await app.testing().test(.DELETE, "products", "\(id)", afterResponse: { res in
                #expect(res.status == .notFound)
            })
        }
    }

    // MARK: Sneakers, the sneakers group shares the products table

    @Test("Sneakers can be created and listed")
    func sneakerCreateAndList() async throws {
        try await withApp(configure: configure) { app in
            let created = LockIsolated<UUID?>(nil)

            try await app.testing().test(
                .POST, "sneakers",
                beforeRequest: { req in
                    try req.content.encode(Self.makeProductRequest(sku: Self.uniqueSKU()))
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let sneaker = try res.content.decode(ProductResponseContent.self)
                    created.setValue(sneaker.id)
                }
            )

            let id = try #require(created.value)

            try await app.testing().test(.GET, "sneakers", afterResponse: { res in
                #expect(res.status == .ok)
                let sneakers = try res.content.decode([ProductResponseContent].self)
                #expect(sneakers.contains { $0.id == id })
            })
        }
    }

    // MARK: Helpers

    private static func makeProductRequest(sku: Int) -> ProductRequestContent {
        ProductRequestContent(
            name: "Test Runner",
            sku: sku,
            description: "Created by and for test",
            brand: .NewBalance,
            size: .size45,
            purchasePrice: 69.5,
            purchaseDate: Date(timeIntervalSince1970: 1_735_689_600)
        )
    }

    private static func uniqueSKU() -> Int {
        // Random per run so the unique sku constraint never collides between test runs.
        Int.random(in: 100_000_000...999_999_999)
    }
}
