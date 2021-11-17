//
//  MetalImageFilter.swift
//  MetalImageFilter
//
//  Created by HyeJee Kim on 2021/11/17.
//

import Foundation
import Metal
import MetalKit

class MetalImageFilter {
    
    private let device: MTLDevice
    private let library: MTLLibrary
    
    // MARK: - Initializer
    
    init?() {
        guard let _device: MTLDevice = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        device = _device
        
        do {
            let bundle: Bundle = Bundle(for: MetalImageFilter.self)
            library = try device.makeDefaultLibrary(bundle: bundle)
        } catch {
            return nil
        }
    }
    
    func imageInverColors(of image: UIImage) -> UIImage {
        let function: MTLFunction = library.makeFunction(name: "drawWithInvertedColor")!
        let computePipeLine: MTLComputePipelineState = try! device.makeComputePipelineState(function: function)
        
        // MTKTextureLoader은 CGImage로부터 새로운 texture를 만들 수 있도록 해줌
        let textureLoader: MTKTextureLoader = MTKTextureLoader(device: device)
        let inputTexture: MTLTexture = try! textureLoader.newTexture(cgImage: image.cgImage!)
        
        let width: Int = inputTexture.width
        let height: Int = inputTexture.height
        
        // MTLTextureDescriptor는 새로운 texture object를 만들 수 있게 해줌
        let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm_srgb, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        let outputTexture: MTLTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        let commandQueue: MTLCommandQueue = device.makeCommandQueue()!
        let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        // command encoder set up
        commandEncoder.setComputePipelineState(computePipeLine)
        commandEncoder.setTexture(inputTexture, index: 0)
        commandEncoder.setTexture(outputTexture, index: 1)
        
        let threadsPerThreadGroup: MTLSize = MTLSize(width: 16, height: 16, depth: 1)
        let threadgroupsPerGrid: MTLSize = MTLSize(width: width / 16 + 1, height: height / 16 + 1, depth: 1)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let ciImage: CIImage = CIImage(mtlTexture: outputTexture)!.oriented(.downMirrored)
        let invertedImage: UIImage = UIImage(ciImage: ciImage)
        
        return invertedImage
    }
    
}
