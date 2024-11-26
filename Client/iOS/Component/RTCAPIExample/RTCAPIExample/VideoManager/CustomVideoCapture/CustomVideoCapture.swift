import AVFoundation

protocol CameraDelegate: AnyObject {
    func camera(_ camera: CustomVideoCapture, didOutput sampleBuffer: CMSampleBuffer)
}

class CustomVideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    weak var delegate: CameraDelegate?
    var session: AVCaptureSession
    
    override init() {
        self.session = AVCaptureSession()
        
        super.init()
        // Set the default camera to the front camera.
        let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

        if let camera = frontCamera {
            do {
                let videoInput = try AVCaptureDeviceInput(device: camera)
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
                
            } catch {
                print("Error creating capture device input: \(error.localizedDescription)")
            }
        } else {
            print("Unable to access front camera.")
        }
        // Set resolution.
        if self.session.canSetSessionPreset(.vga640x480) {
            self.session.sessionPreset = .vga640x480
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        // Set the output video frame format to 32BGRA.
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        
        if self.session.canAddOutput(videoOutput) {
            self.session.addOutput(videoOutput)
        }
    }
    
    func updateFormat(to type: OSType) {
        guard let videoOutput = session.outputs.first(where: { $0 is AVCaptureVideoDataOutput }) as? AVCaptureVideoDataOutput else {
            print("No video data output found in the session.")
            return
        }
        
        if type == kCVPixelFormatType_32BGRA || type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange {
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(type)]
        } else {
            print("Unsupported pixel format type.")
        }
    }
    
    func start() {
        if !self.session.isRunning {
            self.session.startRunning()
        }
    }
    
    func stop() {
        if self.session.isRunning {
            self.session.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.camera(self, didOutput: sampleBuffer)
    }
}
