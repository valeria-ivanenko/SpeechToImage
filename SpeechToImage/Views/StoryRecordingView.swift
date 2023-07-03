import SwiftUI

struct StoryRecordingView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @ObservedObject var imageGenerator: ImageGenerator
    @State var transcript: String = ""
    @State var isRecording = false
    @GestureState var press = false
    
    let timerRecording = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.orange)
                        .frame(height: 80)
                    Text("Speech to Image")
                        .font(.title)
                        .foregroundColor(.white)
                }.padding([.top, .leading,. trailing])
                HStack {
                    Button(isRecording ? "Stop recording" : "Start recording", action: isRecording ? stopRecording : startRecording)
                        .padding()
                        .background(Color.uiBlueColor)
                        .foregroundColor(isRecording ? .cyan : .white)
                        .clipShape(Capsule())
                    Spacer()
                } .padding([.top, .leading, .trailing])
                HStack {
                    TextField("Your story will be here...", text: $transcript, axis: .vertical)
                        .frame(width: 350, height: 50)
                        .fixedSize(horizontal: true, vertical: false)
                        .textFieldStyle(.roundedBorder)
                    Spacer()
                } .padding([.trailing, .leading])
                HStack {
                    if imageGenerator.generationState == .idle {
                        Button("Generate", action: generate)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    } else {
                        ProgressView()
                    }
                    Spacer()
                } .padding([.leading, .trailing, .bottom])
                
                if let generatedImages = imageGenerator.generatedImages {
                    ForEach(generatedImages.images) { image in
                        
                        Image(uiImage: image.uiImage)
                            .resizable()
                            .scaledToFit()
                        
                        Button ( action: {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: image.uiImage)
                        }) {
                            Label("", systemImage: "square.and.arrow.down")
                                .foregroundColor(Color.uiBlueColor)
                                .font(.title)
                                .clipShape(Capsule())
                        }
                    }
                }
            } .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.yellow)
                .onReceive(timerRecording, perform: { _ in
                    if (isRecording) {
                        self.transcript = speechRecognizer.transcript
                        // TraslatorUK2EN.shared.translateUK2EN(text: transcript)
                        // let prompt = TraslatorUK2EN.shared.translation
                    }
                })
        } .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow)
            .onTapGesture {
                self.endEditing()
            }
    }
    
    func generate() {
        imageGenerator.generateImages(ImageGenerator.GenerationParameter(prompt: transcript,
                                                                         negativePrompt: "bad anatomy",
                                                                         guidanceScale: 8.0,
                                                                         seed: 93,
                                                                         stepCount: 20,
                                                                         imageCount: 1,
                                                                         disableSafety: false))
    }
    
    private func startRecording() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
        isRecording = true
    }
    
    private func stopRecording() {
        speechRecognizer.stopTranscribing()
        self.transcript = speechRecognizer.transcript
        isRecording = false
    }
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

struct StoryRecordingView_Previews: PreviewProvider {
    static let imageGenerator = ImageGenerator()
    static var previews: some View {
        StoryRecordingView(imageGenerator: imageGenerator)
    }
}

extension Color {
    static let uiBlueColor = Color(red: 0, green: 0, blue: 0.5)
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
