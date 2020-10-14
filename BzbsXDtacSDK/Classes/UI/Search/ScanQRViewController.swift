//
//  ScanQRViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 30/9/2562 BE.
//

import Foundation
import UIKit
import AVFoundation

protocol ScanQRViewControllerDelegate {
    func didScanWithResult(result:String)
}

class ScanQRViewController: BzbsXDtacBaseViewController {

    @IBOutlet weak var vwCamera: UIView!
    @IBOutlet weak var vwOverlay: UIView!
    
    var delegate: ScanQRViewControllerDelegate?
    
    var qrScannerView : QRScannerView!
    var isFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrScannerView = QRScannerView(frame: vwCamera.bounds)
        qrScannerView.delegate = self
        vwCamera.addSubview(qrScannerView)
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lblTitle.font = UIFont.mainFont()
        lblTitle.textColor = .black
        lblTitle.text = "scan_title".localized()
        lblTitle.sizeToFit()
        self.navigationItem.titleView = lblTitle
        ////self.title = "scan_title".localized()
        self.navigationItem.leftBarButtonItems = BarItem.generate_back(self, selector: #selector(back_1_step))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let connection =  qrScannerView.layer.connection
        {
            connection.videoOrientation = getOrientation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if vwCamera.bounds != qrScannerView.frame
        {
            qrScannerView.frame = vwCamera.bounds
            qrScannerView.layoutIfNeeded()
        }
        
        if let connection =  qrScannerView.layer.connection
        {
            connection.videoOrientation = getOrientation()
        }
    }
    
    func getOrientation() -> AVCaptureVideoOrientation {
        var videoOrientation: AVCaptureVideoOrientation!
        let orientation = preferredInterfaceOrientationForPresentation// UIDevice.current.orientation
//        preferredInterfaceOrientationForPresentation
        switch orientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeLeft
        case .landscapeRight:
            videoOrientation = .landscapeRight
        case .unknown:
            if UIDevice.current.userInterfaceIdiom == .phone
            {
                videoOrientation = .portrait
            } else {
                videoOrientation = .landscapeLeft
            }
        @unknown default:
            break
        }
        return videoOrientation
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        qrScannerView.startScanning()
    }
    
    @IBAction func ClickClose(_ sender: Any) {
        back_1_step()
    }
}

extension ScanQRViewController : QRScannerViewDelegate{
    func qrScanningDidFail() {
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        if isFound { return }
        if let result = str ,
            result != ""
            {
                if isFound { return }
                isFound = true
                delay {
                    DispatchQueue.main.async {
                        self.delegate?.didScanWithResult(result: result)
                    }
                }
                back_1_step()
        }
    }
    
    func qrScanningDidStop() {
    }
    
}

/// Delegate callback for the QRScannerView.
protocol QRScannerViewDelegate: class {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}
    
class QRScannerView: UIView {
    
    weak var delegate: QRScannerViewDelegate?
    
    /// capture settion which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?
    
    // Init methods..
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitialSetup()
    }
    
    //MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.
    override class var layerClass: AnyClass  {
        return AVCaptureVideoPreviewLayer.self
    }
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
}

extension QRScannerView {
    
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }
    
    func startScanning() {
        captureSession?.startRunning()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.qrScanningDidStop()
    }
    
    /// Does the initial setup for captureSession
    private func doInitialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            scanningDidFail()
            return
        }
        
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        
        captureSession?.startRunning()
    }
    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }
    
    func found(code: String) {
        delegate?.qrScanningSucceededWithCode(code)

    }
    
}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        stopScanning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}
