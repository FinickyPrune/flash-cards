// Prints the recognition languages each text API supports on this OS.
import Foundation
import Vision
import VisionKit

let legacy = VNRecognizeTextRequest()
legacy.recognitionLevel = .accurate
print("VNRecognizeTextRequest:", (try? legacy.supportedRecognitionLanguages()) ?? [])

print("RecognizeTextRequest:", RecognizeTextRequest().supportedRecognitionLanguages.map(\.maximalIdentifier))
print("RecognizeDocumentsRequest:", RecognizeDocumentsRequest().supportedRecognitionLanguages.map(\.maximalIdentifier))

let sema = DispatchSemaphore(value: 0)
Task {
    await print("ImageAnalyzer:", ImageAnalyzer.supportedTextRecognitionLanguages)
    sema.signal()
}

sema.wait()
