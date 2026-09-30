public import Domain_Name_System
public import IP_Address

extension TLS {

    public struct Configuration: Sendable {

        public let query: DNS.Query

        public let hostname: String

        public let peer: TLS.PeerPolicy

        public init(query: DNS.Query, hostname: String, peer: TLS.PeerPolicy) {
            self.query = query
            self.hostname = hostname
            self.peer = peer
        }

        public func resolve<Resolver: DNS.Resolver.`Protocol`>(
            using resolver: Resolver
        ) async throws(Resolver.Failure) -> [IP.Address] {
            try await resolver.resolve(query)
        }
    }
}
