import TLS
import Testing

@Suite
struct `TLS.Session` {

    actor Recorder {
        var reads: [Int] = []
        var writes: [[UInt8]] = []
        var closes = 0

        func read(_ maximum: Int) { reads.append(maximum) }
        func write(_ bytes: [UInt8]) { writes.append(bytes) }
        func close() { closes += 1 }
    }

    static func session(_ recorder: Recorder, reply: [UInt8] = [1, 2, 3]) -> TLS.Session {
        TLS.Session(
            read: { maximum in
                await recorder.read(maximum)
                return Array(reply.prefix(maximum))
            },
            write: { bytes in await recorder.write(bytes) },
            close: { await recorder.close() }
        )
    }

    @Test
    func `read forwards the maximum and returns the engine's bytes`() async throws {
        let recorder = Recorder()
        let bytes = try await Self.session(recorder).read(maximum: 2)
        #expect(bytes == [1, 2])
        #expect(await recorder.reads == [2])
    }

    @Test
    func `write forwards the bytes unchanged`() async throws {
        let recorder = Recorder()
        try await Self.session(recorder).write([0x16, 0x03, 0x03])
        #expect(await recorder.writes == [[0x16, 0x03, 0x03]])
    }

    @Test
    func `close reaches the engine once per call`() async {
        let recorder = Recorder()
        let session = Self.session(recorder)
        await session.close()
        await session.close()
        #expect(await recorder.closes == 2)
    }

    @Test
    func `an engine failure is passed through as the same typed failure`() async {
        let session = TLS.Session(
            read: { _ throws(TLS.Failure) in throw .handshake },
            write: { _ throws(TLS.Failure) in throw .closed },
            close: {}
        )
        await #expect(throws: TLS.Failure.handshake) { _ = try await session.read(maximum: 1) }
        await #expect(throws: TLS.Failure.closed) { try await session.write([0]) }
    }

    @Test
    func `read and write in a cancelled task fail with cancelled without reaching the engine`() async {
        let recorder = Recorder()
        let session = Self.session(recorder)
        let outcome = await Task { () -> (TLS.Failure?, TLS.Failure?) in
            withUnsafeCurrentTask { $0?.cancel() }
            var readFailure: TLS.Failure?
            var writeFailure: TLS.Failure?
            do throws(TLS.Failure) { _ = try await session.read(maximum: 1) } catch { readFailure = error }
            do throws(TLS.Failure) { try await session.write([1]) } catch { writeFailure = error }
            return (readFailure, writeFailure)
        }.value
        #expect(outcome.0 == TLS.Failure.cancelled)
        #expect(outcome.1 == TLS.Failure.cancelled)
        #expect(await recorder.reads.isEmpty)
        #expect(await recorder.writes.isEmpty)
    }
}
