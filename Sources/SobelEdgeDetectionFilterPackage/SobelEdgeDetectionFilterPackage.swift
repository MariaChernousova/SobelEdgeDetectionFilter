import UIKit

struct PixelData {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public struct SobelEdgeDetectionFilterPackage {
    // Load the input image
//    public var inputImage: UIImage
    
//    private var width = 0
//    private var height = 0
//
//    // Get the width and height of the input image
//    private mutating func getSizeOfElement(inputImage: UIImage) {
//        width = Int(inputImage.size.width)
//        height = Int(inputImage.size.height)
//    }
    public init() { }
    
    func applySobelFilter(image: UIImage) -> UIImage {
        let inputImage = image.convertToGrayScale()
        let inputPixels = inputImage.getPixels()
        let outputPixels = UnsafeMutablePointer<PixelData>.allocate(capacity: Int(inputImage.size.width * inputImage.size.height))
        defer {
            outputPixels.deallocate()
        }
        let sobelX: [Int16] = [-1, 0, 1, -2, 0, 2, -1, 0, 1]
        let sobelY: [Int16] = [-1, -2, -1, 0, 0, 0, 1, 2, 1]
        let divisor: Int16 = 8
        for y in 1..<Int(inputImage.size.height) - 1 {
            for x in 1..<Int(inputImage.size.width) - 1 {
                var pixelX: Int16 = 0
                var pixelY: Int16 = 0
                var pixel: Int16 = 0
                for dy in -1...1 {
                    for dx in -1...1 {
                        let index = ((y + dy) * Int(inputImage.size.width)) + (x + dx)
                        let intensity = inputImage.getPixelIntensity(x: x + dx, y: y + dy)
                        let sobelIndex = ((dy + 1) * 3) + (dx + 1)
                        pixelX += sobelX[sobelIndex] * Int16(intensity)
                        pixelY += sobelY[sobelIndex] * Int16(intensity)
                    }
                }
                pixel = Int16(sqrt(Double(pixelX * pixelX + pixelY * pixelY)))
                pixel = pixel < 0 ? 0 : pixel > 255 ? 255 : pixel
                pixel /= divisor
                outputPixels[(y * Int(inputImage.size.width)) + x] = PixelData(red: UInt8(pixel), green: UInt8(pixel), blue: UInt8(pixel), alpha: 255)
                //                PixelData(a: 255, r: UInt8(pixel), g: UInt8(pixel), b: UInt8(pixel))
            }
        }
        let outputCGImage = inputImage.createCGImage(pixels: outputPixels, width: Int(inputImage.size.width), height: Int(inputImage.size.height))
        return UIImage(cgImage: outputCGImage!)
    }
    
//    public func implementSobelFilter(inputImage: UIImage) -> UIImageView {
//        let width = Int(inputImage.size.width)
//        let height = Int(inputImage.size.height)
//        // Create a new output image context
//        UIGraphicsBeginImageContextWithOptions(inputImage.size, false, inputImage.scale)
//
//        // Convert the input image to grayscale
//        let grayScaleImage = inputImage.convertToGrayScale()
//
//        // Define the horizontal and vertical Sobel operator kernels
//        let sobelKernelX = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
//        let sobelKernelY = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]
//
//        // Iterate over each pixel in the input image
//        for x in 1..<width-1 {
//            for y in 1..<height-1 {
//                // Initialize the Sobel gradient values
//                var gradientX = 0
//                var gradientY = 0
//
//                // Iterate over each pixel in the Sobel operator kernel
//                for i in 0..<3 {
//                    for j in 0..<3 {
//                        // Calculate the coordinates of the current pixel in the input image
//                        let xCoord = x + i - 1
//                        let yCoord = y + j - 1
//
//                        // Get the pixel intensity value of the current pixel in the grayscale image
//                        if let grayScaleImage {
//                            let pixelValue = grayScaleImage.getPixelIntensity(x: xCoord, y: yCoord)
//
//                            // Apply the Sobel operator to the pixel intensity value
//                            if let pixelValue {
//                                gradientX += pixelValue * sobelKernelX[i][j]
//                                gradientY += pixelValue * sobelKernelY[i][j]
//                            }
//                        }
//                    }
//                }
//
//                // Calculate the magnitude of the Sobel gradient vector
//                let gradientMagnitude = sqrt(Double(gradientX * gradientX + gradientY * gradientY))
//
//                // Create a new pixel color with the gradient magnitude
//                let gradientColor = UIColor(red: CGFloat(gradientMagnitude), green: CGFloat(gradientMagnitude), blue: CGFloat(gradientMagnitude), alpha: 1.0)
//
//                // Set the pixel color in the output image context
//                gradientColor.setFill()
//                UIRectFill(CGRect(x: x, y: y, width: 1, height: 1))
//            }
//        }
//
//        // Get the output image from the context
//        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
//
//        // End the image context
//        UIGraphicsEndImageContext()
//
//        // Display the output image on the screen
//        let imageView = UIImageView(image: outputImage)
//        return imageView
//    }
}

extension UIImage {
    func convertToGrayScale() -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        context.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: self.size))
        let grayImage = context.makeImage()!
        return UIImage(cgImage: grayImage)
    }
    
    func getPixelIntensity(x: Int, y: Int) -> UInt8 {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * y) + x) * 1
        return data[pixelInfo]
    }
    

}

extension UIImage {
    func getPixels() -> [PixelData]? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [PixelData]()
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        for i in 0..<width*height {
            let startIndex = i * bytesPerPixel
            let red = rawData[startIndex]
            let green = rawData[startIndex + 1]
            let blue = rawData[startIndex + 2]
            let alpha = rawData[startIndex + 3]
            let pixel = PixelData(red: red, green: green, blue: blue, alpha: alpha)
            pixelData.append(pixel)
        }
        
        return pixelData
    }
}

extension UIImage {
    func createCGImage(pixels: UnsafeMutablePointer<PixelData>, width: Int, height: Int) -> CGImage? {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixels,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
                                      releaseCallback: nil,
                                      releaseInfo: nil) else {
            return nil
        }
        
        return context.makeImage()
    }
}




//extension UIImage {
//    func convertToGrayScale() -> UIImage? {
//        let colorSpace = CGColorSpaceCreateDeviceGray()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
//        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
//            return nil
//        }
//
//        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
//        context.draw(self.cgImage!, in: rect)
//
//        guard let grayImage = context.makeImage() else {
//            return nil
//        }
//
//        return UIImage(cgImage: grayImage)
//    }
//}
//
//extension UIImage {
//    func getPixelIntensity(x: Int, y: Int) -> Int? {
//        guard let cgImage = self.cgImage else {
//            return nil
//        }
//
//        let width = cgImage.width
//        let height = cgImage.height
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        let bitsPerComponent = 8
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
//        var pixelData = [UInt8](repeating: 0, count: bytesPerPixel)
//
//        guard let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
//            return nil
//        }
//
//        let rect = CGRect(x: x, y: height - y - 1, width: 1, height: 1)
//        context.draw(cgImage, in: rect)
//
//        let red = Int(pixelData[0])
//        let green = Int(pixelData[1])
//        let blue = Int(pixelData[2])
//        let alpha = Int(pixelData[3])
//        let intensity = (red + green + blue) / (3 * alpha)
//
//        return Int(intensity)
//    }
//}
