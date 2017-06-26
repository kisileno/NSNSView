//
//  ViewController.swift
//  AntiShakeView
//
//  Created by Oleksandr Kisilenko on 6/4/17.
//  Copyright © 2017 Oleksandr Kisilenko. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet var justAView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var datTextView: UITextView!

    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!

    @IBOutlet weak var xProgress: UIProgressView!
    @IBOutlet weak var yProgress: UIProgressView!
    @IBOutlet weak var zProgress: UIProgressView!


    @IBOutlet weak var accelXLabel: UILabel!
    @IBOutlet weak var accelYLabel: UILabel!
    @IBOutlet weak var accelZLabel: UILabel!

    @IBOutlet weak var accelXProgress: UIProgressView!
    @IBOutlet weak var accelYProgress: UIProgressView!
    @IBOutlet weak var accelZProgress: UIProgressView!

    var xVelocity = 0.0;
    var yVelocity = 0.0;
    var zVelocity = 0.0;
    var lastCorrectionX = 0.0;
    var lastCorrectionY = 0.0;
    
    let ACCEL_TRESHOLD = 0.15
    let SAMPLE_T = 0.032
    let MAGIC_MULTIPLIER = 30000.0

    @IBAction func resetPepe(_ sender: Any) {
        imageView.transform = CGAffineTransform(translationX: CGFloat(0.0), y: CGFloat(0.0))
        lastCorrectionX = 0.0;
        lastCorrectionY = 0.0;
        xVelocity = 0.0;
        yVelocity = 0.0;
        zVelocity = 0.0;

    }

    let motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.minificationFilter = kCAFilterTrilinear
        imageView.layer.minificationFilterBias = 0.1



        if self.motionManager.isGyroAvailable {
            print("Is fucking availvale");

            self.motionManager.deviceMotionUpdateInterval = SAMPLE_T
            self.motionManager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
                if let gravity = data?.gravity {


                    self?.xLabel.text = DU.formatDouble(d: gravity.x)
                    self?.yLabel.text = DU.formatDouble(d: gravity.y)
                    self?.zLabel.text = DU.formatDouble(d: gravity.z)

                    self?.xProgress.progress = Float((1 + gravity.x) / 2);
                    self?.yProgress.progress = Float((1 + gravity.y) / 2);
                    self?.zProgress.progress = Float((1 + gravity.z) / 2);


                }

                if let attitude = data?.attitude {
//                    print("attidate ", attitude)
                }

                if let acceleration = data?.userAcceleration {
//                    print("acceleration ", acceleration)
                    self?.accelXLabel.text = DU.formatDouble(d: acceleration.x)
                    self?.accelYLabel.text = DU.formatDouble(d: acceleration.y)
                    self?.accelZLabel.text = DU.formatDouble(d: acceleration.z)

                    self?.accelXProgress.progress = Float(abs(acceleration.x));
                    self?.accelYProgress.progress = Float(abs(acceleration.y));
                    self?.accelZProgress.progress = Float(abs(acceleration.z));

//                    print(String(format: "%f\t%f\t%f", acceleration.x, acceleration.y, acceleration.z))

                    if (abs(acceleration.x) > self!.ACCEL_TRESHOLD) {
                        self!.xVelocity += acceleration.x * self!.SAMPLE_T
                    }

                    if (abs(acceleration.y) > self!.ACCEL_TRESHOLD) {
                        self!.yVelocity += acceleration.y * self!.SAMPLE_T
                    }

                    if (abs(acceleration.z) > self!.ACCEL_TRESHOLD) {
                        self!.zVelocity += acceleration.z * self!.SAMPLE_T
                    }
                    self!.xVelocity = self!.xVelocity * 0.75
                    self!.yVelocity = self!.yVelocity * 0.75
                    self!.zVelocity = self!.zVelocity * 0.75
                    
                    self!.lastCorrectionX = self!.lastCorrectionX * 0.9
                    self!.lastCorrectionY = self!.lastCorrectionY * 0.9

                    print(String(format: "%f\t%f\t%f\t%f\t%f\t%f", acceleration.x, self!.xVelocity, acceleration.y, self!.yVelocity, acceleration.z, self!.zVelocity))

                    self!.lastCorrectionX = self!.lastCorrectionX + self!.xVelocity * self!.SAMPLE_T * self!.MAGIC_MULTIPLIER
                    self!.lastCorrectionY = self!.lastCorrectionY + self!.yVelocity * self!.SAMPLE_T * self!.MAGIC_MULTIPLIER
                    self!.imageView.transform = CGAffineTransform(translationX: CGFloat(self!.lastCorrectionX), y: CGFloat(-self!.lastCorrectionY))

                }
            }

        } else {
            print("motion manager is fucking unavailable")
        }

        print("did exit")

    }

    @IBAction func feelTouchDown(_ sender: Any) {
        let count = datTextView.text.characters.count
        print("\\() feel: \(count)")
        datTextView.text = "dat feel n \(count)\n" + datTextView.text
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}






class DU {
    static func formatDouble(d: Double) -> String {
        return NSString(format: "%.3f", d) as String
    }

    static func roundTo(d: Double, n: Int) -> Double {
        let modulo = pow(10.0, Double(n))

        return Double(round(modulo * d) / modulo)
    }
}

