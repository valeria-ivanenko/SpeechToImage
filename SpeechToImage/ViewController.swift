import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet private weak var recordingView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    let imageGenerator = ImageGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftUIViewController: UIViewController = UIHostingController(rootView: StoryRecordingView(imageGenerator: imageGenerator))
        let swiftUIView: UIView = swiftUIViewController.view

        self.recordingView.addSubview(swiftUIView)
        
        swiftUIView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            swiftUIView.topAnchor.constraint(equalTo: self.recordingView.topAnchor),
            swiftUIView.trailingAnchor.constraint(equalTo: self.recordingView.trailingAnchor),
            swiftUIView.bottomAnchor.constraint(equalTo: self.recordingView.bottomAnchor),
            swiftUIView.leadingAnchor.constraint(equalTo: self.recordingView.leadingAnchor)
        ])
        swiftUIViewController.didMove(toParent: self)
    }
}

