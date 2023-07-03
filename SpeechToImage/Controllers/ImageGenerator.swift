import UIKit
import StableDiffusion
import CoreML

@MainActor
final class ImageGenerator: ObservableObject {

    struct GenerationParameter {
        var prompt: String
        var negativePrompt: String
        var guidanceScale: Float
        var seed: Int
        var stepCount: Int
        var imageCount: Int
        var disableSafety: Bool
        var startImage: CGImage?
        var strength: Float = 1.0
    }

    struct GeneratedImage: Identifiable {
        let id: UUID = UUID()
        let uiImage: UIImage
    }

    struct GeneratedImages {
        let prompt: String
        let negativePrompt: String
        let guidanceScale: Float
        let imageCount: Int
        let stepCount: Int
        let seed: Int
        let disableSafety: Bool
        let images: [GeneratedImage]
    }

    enum GenerationState: Equatable {
        case idle
        case generating(progressStep: Int)
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, idle): return true
            case (.generating(let step1), .generating(let step2)):
                if step1 == step2 { return true
                } else { return false }
            default:
                return false
            }
        }
    }

    @Published var generationState: GenerationState = .idle
    @Published var generatedImages: GeneratedImages?
    @Published var isPipelineCreated = false

    private var sdPipeline: StableDiffusionPipeline?

    init() {
    }

    func setState(_ state: GenerationState) {
        generationState = state
    }

    func setPipeline(_ pipeline: StableDiffusionPipeline) {
        sdPipeline = pipeline
        isPipelineCreated = true
    }

    func setGeneratedImages(_ images: GeneratedImages) {
        generatedImages = images
    }

    func generateImages(_ parameter: GenerationParameter) {
        guard generationState == .idle else { return }
        Task.detached(priority: .high) {
            await self.setState(.generating(progressStep: 0))

            if await self.sdPipeline == nil {
                guard let path = Bundle.main.path(forResource: "CoreMLModels", ofType: nil, inDirectory: nil) else {
                    fatalError("Fatal error: failed to find the CoreML models.")
                }
                let resourceURL = URL(fileURLWithPath: path)

                let config = MLModelConfiguration()
                config.computeUnits = .cpuAndGPU

                let reduceMemory = ProcessInfo.processInfo.isiOSAppOnMac ? false : true
                if let pipeline = try? StableDiffusionPipeline(resourcesAt: resourceURL, controlNet: [],
                                                               configuration: config,
                                                               reduceMemory: reduceMemory) {
                    await self.setPipeline(pipeline)
                } else {
                    fatalError("Fatal error: failed to create the Stable-Diffusion-Pipeline.")
                }
            }

            if let sdPipeline = await self.sdPipeline {
                do {
                    var configuration = StableDiffusionPipeline.Configuration(prompt: parameter.prompt)
                    configuration.negativePrompt = parameter.negativePrompt
                    configuration.imageCount = parameter.imageCount
                    configuration.stepCount = parameter.stepCount
                    configuration.seed = UInt32(parameter.seed)
                    configuration.guidanceScale = parameter.guidanceScale
                    configuration.disableSafety = parameter.disableSafety
                    configuration.strength = 1.0

                    let cgImages = try sdPipeline.generateImages(configuration: configuration)

                    print("images were generated.")
                    let uiImages = cgImages.compactMap { image in
                        if let cgImage = image { return UIImage(cgImage: cgImage)
                        } else { return nil }
                    }
                    await self.setGeneratedImages(GeneratedImages(prompt: parameter.prompt,
                                                                  negativePrompt: parameter.negativePrompt,
                                                                  guidanceScale: parameter.guidanceScale,
                                                                  imageCount: parameter.imageCount,
                                                                  stepCount: parameter.stepCount,
                                                                  seed: parameter.seed,
                                                                  disableSafety: parameter.disableSafety,
                                    images: uiImages.map { uiImage in GeneratedImage(uiImage: uiImage) }))
                } catch {
                    print("failed to generate images.")
                }
            }

            await self.setState(.idle)
        }
    }
}
