import Foundation

enum ControlMode: String {
    case standalone = "Standalone"
    case managed = "Managed"
}

struct ChannelSnapshot {
    let id: Int
    let inputAEnabled: Bool
    let inputBEnabled: Bool
    let mix: Double
}

struct PresetSlot: Identifiable {
    let id: Int
    var name: String
    var snapshot: [ChannelSnapshot]?

    var hasData: Bool {
        snapshot != nil
    }
}

@MainActor
final class BoardState: ObservableObject {
    @Published var channels: [ChannelState]
    @Published var isConnected: Bool
    @Published var portName: String
    @Published var boardName: String
    @Published var mode: ControlMode
    @Published var presetSlots: [PresetSlot]

    init() {
        channels = (1...9).map { ChannelState(id: $0) }
        isConnected = false
        portName = "Not Connected"
        boardName = "DirtyMixer V1 (Mock)"
        mode = .standalone
        presetSlots = (1...12).map { PresetSlot(id: $0, name: "Slot \($0)", snapshot: nil) }
    }

    func toggleConnection() {
        isConnected.toggle()
        portName = isConnected ? "usbmodem-dirtymixer-v1" : "Not Connected"
    }

    func toggleMode() {
        mode = mode == .standalone ? .managed : .standalone
    }

    func savePreset(slot: Int) {
        guard let index = presetSlots.firstIndex(where: { $0.id == slot }) else { return }
        let snapshot = channels.map {
            ChannelSnapshot(id: $0.id, inputAEnabled: $0.inputAEnabled, inputBEnabled: $0.inputBEnabled, mix: $0.mix)
        }
        presetSlots[index].snapshot = snapshot
        presetSlots[index].name = "Preset \(slot)"
    }

    func recallPreset(slot: Int) {
        guard let index = presetSlots.firstIndex(where: { $0.id == slot }),
              let snapshot = presetSlots[index].snapshot
        else { return }

        for state in snapshot {
            guard let channel = channels.first(where: { $0.id == state.id }) else { continue }
            channel.inputAEnabled = state.inputAEnabled
            channel.inputBEnabled = state.inputBEnabled
            channel.mix = state.mix
        }
    }
}
