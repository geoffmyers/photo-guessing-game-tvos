import Foundation
import AVFoundation

class SoundService {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?

    init() {
        setupAudioEngine()
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    // MARK: - Sound Effects

    func playClick() {
        playTone(frequency: 800, duration: 0.08, type: .sine)
    }

    func playCorrect() {
        // Ascending arpeggio: C5 -> E5 -> G5
        let notes: [(frequency: Double, delay: Double)] = [
            (523.25, 0.0),   // C5
            (659.25, 0.12),  // E5
            (783.99, 0.24)   // G5
        ]

        for note in notes {
            DispatchQueue.main.asyncAfter(deadline: .now() + note.delay) { [weak self] in
                self?.playTone(frequency: note.frequency, duration: 0.15, type: .sine)
            }
        }
    }

    func playIncorrect() {
        // Descending tone
        playTone(frequency: 400, duration: 0.2, type: .sawtooth, fadeOut: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.playTone(frequency: 300, duration: 0.2, type: .sawtooth, fadeOut: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.playTone(frequency: 200, duration: 0.25, type: .sawtooth, fadeOut: true)
        }
    }

    func playVictoryFanfare() {
        // Victory chord progression
        let chords: [(frequencies: [Double], delay: Double)] = [
            ([523.25, 659.25, 783.99], 0.0),     // C major
            ([659.25, 783.99, 987.77], 0.25),    // E minor
            ([783.99, 987.77, 1174.66], 0.5),    // G major
            ([1046.50, 1318.51, 1567.98], 0.75)  // C major (octave up)
        ]

        for chord in chords {
            DispatchQueue.main.asyncAfter(deadline: .now() + chord.delay) { [weak self] in
                for freq in chord.frequencies {
                    self?.playTone(frequency: freq, duration: 0.3, type: .triangle)
                }
            }
        }
    }

    // MARK: - Tone Generation

    private enum WaveType {
        case sine
        case triangle
        case sawtooth
        case square
    }

    private func playTone(frequency: Double, duration: Double, type: WaveType, fadeOut: Bool = true) {
        let sampleRate: Double = 44100
        let frameCount = Int(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else {
            return
        }

        buffer.frameLength = AVAudioFrameCount(frameCount)

        guard let channelData = buffer.floatChannelData?[0] else { return }

        for frame in 0..<frameCount {
            let time = Double(frame) / sampleRate
            var sample: Float = 0

            switch type {
            case .sine:
                sample = Float(sin(2.0 * .pi * frequency * time))
            case .triangle:
                let period = 1.0 / frequency
                let phase = time.truncatingRemainder(dividingBy: period) / period
                sample = Float(4.0 * abs(phase - 0.5) - 1.0)
            case .sawtooth:
                let period = 1.0 / frequency
                let phase = time.truncatingRemainder(dividingBy: period) / period
                sample = Float(2.0 * phase - 1.0)
            case .square:
                sample = Float(sin(2.0 * .pi * frequency * time) > 0 ? 1.0 : -1.0)
            }

            // Apply envelope
            let envelope: Float
            if fadeOut {
                envelope = Float(1.0 - (Double(frame) / Double(frameCount)))
            } else {
                let attackTime = 0.01 * sampleRate
                let releaseTime = 0.05 * sampleRate
                let releaseStart = Double(frameCount) - releaseTime

                if Double(frame) < attackTime {
                    envelope = Float(Double(frame) / attackTime)
                } else if Double(frame) > releaseStart {
                    envelope = Float((Double(frameCount) - Double(frame)) / releaseTime)
                } else {
                    envelope = 1.0
                }
            }

            channelData[frame] = sample * envelope * 0.3 // Volume
        }

        playerNode?.scheduleBuffer(buffer, completionHandler: nil)
        playerNode?.play()
    }
}
