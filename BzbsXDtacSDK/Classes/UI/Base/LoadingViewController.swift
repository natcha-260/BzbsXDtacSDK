//
//  LoadingViewController.swift
//  Pods
//
//  Created by Buzzebees iMac on 1/10/2562 BE.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {
    static var shared = LoadingViewController(nibName: "LoadingViewController", bundle: Bzbs.shared.currentBundle)
    
    @IBOutlet weak var vwLoadingContainer: UIView!
    var animationView = LOTAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vwLoadingContainer.backgroundColor = .clear//UIColor.black.withAlphaComponent(0.8)
        vwLoadingContainer.cornerRadius(corner: 16)
        
        animationView.setAnimation(named: "dtac_loading", bundle: Bzbs.shared.currentBundle)
        animationView.contentMode = .scaleAspectFit
        
        animationView.frame = vwLoadingContainer.bounds
        vwLoadingContainer.addSubview(animationView)
        
        vwLoadingContainer.addConstraints([
            NSLayoutConstraint(item: vwLoadingContainer!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: animationView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: vwLoadingContainer!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: animationView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: vwLoadingContainer!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: animationView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: vwLoadingContainer!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: animationView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0),
        ])
        play()
//        animationView.play(fromProgress: 0,
//                           toProgress: 1,
//                           loopMode: LottieLoopMode.loop,
//                           completion: { (finished) in
//                            if finished {
//                              print("Animation Complete")
//                            } else {
//                              print("Animation cancelled")
//                            }
//        })
    }
    
    func play()
    {
        vwLoadingContainer.layoutIfNeeded()
        animationView.play { (isComplete) in
            Bzbs.shared.delay(0.33) {
                self.play()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        play()
    }
}
