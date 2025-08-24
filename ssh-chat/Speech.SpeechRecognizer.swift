import Foundation
import AVFoundation
import Speech
import Accelerate

@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var isListening: Bool = false
    @Published var level: Double = 0 // 0...1
    @Published var lastError: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale.current)
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func startDictation(onPartial: @escaping (String) -> Void, onFinal: @escaping (String) -> Void) {
        requestPermissions { [weak self] granted in
            guard let self = self, granted else {
                self?.lastError = "Speech or microphone permission not granted"
                return
            }
            self.begin(onPartial: onPartial, onFinal: onFinal)
        }
    }

    func stopDictation() {
        isListening = false
        request?.endAudio()
        task?.cancel()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        request = nil
        task = nil
        audioEngine = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func begin(onPartial: @escaping (String) -> Void, onFinal: @escaping (String) -> Void) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let engine = AVAudioEngine()
            let req = SFSpeechAudioBufferRecognitionRequest()
            req.shouldReportPartialResults = true

            guard let recognizer, recognizer.isAvailable else {
                self.lastError = "Speech recognizer not available"
                return
            }

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)

            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, when in
                req.append(buffer)
                self?.updateLevel(from: buffer)
            }

            engine.prepare()
            try engine.start()

            self.audioEngine = engine
            self.request = req

            isListening = true

            self.task = recognizer.recognitionTask(with: req) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    if result.isFinal {
                        onFinal(text)
                        self.stopDictation()
                    } else {
                        onPartial(text)
                    }
                }
                if let error = error {
                    self.lastError = error.localizedDescription
                    self.stopDictation()
                }
            }
        } catch {
            self.lastError = error.localizedDescription
            self.stopDictation()
        }
    }

    private func updateLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        var meanSquare: Float = 0
        vDSP_measqv(channelData, 1, &meanSquare, vDSP_Length(frameLength))
        let rms = sqrt(meanSquare)
        let level = min(max((Double(rms) * 10), 0), 1)
        DispatchQueue.main.async { self.level = level }
    }

    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            let speechOK = (status == .authorized)
            AVAudioSession.sharedInstance().requestRecordPermission { micOK in
                DispatchQueue.main.async { completion(speechOK && micOK) }
            }
        }
    }
}

