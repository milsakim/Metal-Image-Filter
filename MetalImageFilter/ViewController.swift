//
//  ViewController.swift
//  MetalImageFilter
//
//  Created by HyeJee Kim on 2021/11/17.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let image: UIImage = UIImage(named: "test-img") else {
            return
        }
        guard let imageFilter: MetalImageFilter = MetalImageFilter() else {
            return
        }
        
        let filteredImage = imageFilter.imageInverColors(of: image)
        imageView.image = filteredImage
    }


}

