import UIKit

public struct SobelEdgeDetectionFilterPackage {
    
    public init() { }
    
    public func applySobelFilter(image: UIImage, completion: @escaping (UIImage) -> Void) {

        guard let inputPixels = image.convertToGrayscale()?.pixelData() else {
                    fatalError()
                }
        let outputPixels = UnsafeMutablePointer<UInt>.allocate(capacity: inputPixels.count)


        let width = Int(image.size.width)
        let height = Int(image.size.height)

                // Sobel kernel matrices
                let sobelX: [Int] = [-1, 0, 1,
                                        -2, 0, 2,
                                        -1, 0, 1]
                let sobelY: [Int] = [-1, -2, -1,
                                        0, 0, 0,
                                        1, 2, 1]

                // Convolve image with Sobel kernels
                for y in 1..<height-1 {
                    for x in 1..<width-1 {
                        var pixelX: Int = 0
                        var pixelY: Int = 0

                        for j in 0..<3 {
                            for i in 0..<3 {
                                let pixelIndex = (y + j - 1) * width + (x + i - 1)
                                let inputPixelsIndex = Int(inputPixels[pixelIndex]) / 10000
                                let sobelXIndex = Int(sobelX[j*3+i])
                                let sobelYIndex = Int(sobelY[j*3+i])
                                pixelX += inputPixelsIndex * sobelXIndex
                                pixelY += inputPixelsIndex * sobelYIndex
                            }
                        }

                        let pixelIndex = y * width + x
                        let pixelValue = sqrt(Double(pixelX * pixelX + pixelY * pixelY))
                        outputPixels[pixelIndex] = UInt(max(0, min(255, pixelValue)))
                    }
                }

                // Create new image from filtered pixel data
                let colorSpace = CGColorSpaceCreateDeviceGray()
                guard let context = CGContext(data: outputPixels,
                                              width: width,
                                              height: height,
                                              bitsPerComponent: 8,
                                              bytesPerRow: width,
                                              space: colorSpace,
                                              bitmapInfo: CGImageAlphaInfo.none.rawValue),
                      let cgImage = context.makeImage()
                else {
                    fatalError()
                }
                completion(UIImage(cgImage: cgImage))
    }
}

extension UIImage {
    // Convert UIImage to grayscale pixel data
    func convertToGrayscale() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.draw(cgImage!, in: rect)
        
        guard let grayscaleImage = context.makeImage() else { return nil }
        return UIImage(cgImage: grayscaleImage)
    }
    
    // Convert pixel data to UIImage
    convenience init?(pixelData: [Int], width: Int, height: Int) {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: UnsafeMutableRawPointer(mutating: pixelData),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue,
                                      releaseCallback: nil,
                                      releaseInfo: nil) else {
            return nil
        }
        
        guard let cgImage = context.makeImage() else { return nil }
        self.init(cgImage: cgImage)
    }
    

    func pixelData() -> [Int]? {
        guard let cgImage = cgImage else { return nil }
        
        let width = Int(size.width)
        let height = Int(size.height)
        let bytesPerPixel = 1
        let bytesPerRow = bytesPerPixel * width
        
        let totalBytes = height * bytesPerRow
        var pixelData = [Int](repeating: 0, count: totalBytes)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue)
        else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(cgImage, in: rect)
        
        return pixelData
    }
}
