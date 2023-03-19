import UIKit

public struct SobelEdgeDetectionFilterPackage {
    // Load the input image
    public var inputImage: UIImage
    
    private var width = 0
    private var height = 0
    
    // Get the width and height of the input image
    private mutating func getSizeOfElement(inputImage: UIImage) {
        width = Int(inputImage.size.width)
        height = Int(inputImage.size.height)
    }
    
    public mutating func implementSobelFilter(inputImage: UIImage) -> UIImageView {
        // Create a new output image context
        UIGraphicsBeginImageContextWithOptions(inputImage.size, false, inputImage.scale)
        
        // Convert the input image to grayscale
        let grayScaleImage = inputImage.convertToGrayScale()
        
        // Define the horizontal and vertical Sobel operator kernels
        let sobelKernelX = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
        let sobelKernelY = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]
        
        // Iterate over each pixel in the input image
        for x in 1..<width-1 {
            for y in 1..<height-1 {
                // Initialize the Sobel gradient values
                var gradientX = 0
                var gradientY = 0
                
                // Iterate over each pixel in the Sobel operator kernel
                for i in 0..<3 {
                    for j in 0..<3 {
                        // Calculate the coordinates of the current pixel in the input image
                        let xCoord = x + i - 1
                        let yCoord = y + j - 1
                        
                        // Get the pixel intensity value of the current pixel in the grayscale image
                        if let grayScaleImage {
                            let pixelValue = grayScaleImage.getPixelIntensity(x: xCoord, y: yCoord)
                            
                            // Apply the Sobel operator to the pixel intensity value
                            if let pixelValue {
                                gradientX += pixelValue * sobelKernelX[i][j]
                                gradientY += pixelValue * sobelKernelY[i][j]
                            }
                        }
                    }
                }
                
                // Calculate the magnitude of the Sobel gradient vector
                let gradientMagnitude = sqrt(Double(gradientX * gradientX + gradientY * gradientY))
                
                // Create a new pixel color with the gradient magnitude
                let gradientColor = UIColor(red: CGFloat(gradientMagnitude), green: CGFloat(gradientMagnitude), blue: CGFloat(gradientMagnitude), alpha: 1.0)
                
                // Set the pixel color in the output image context
                gradientColor.setFill()
                UIRectFill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        // Get the output image from the context
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the image context
        UIGraphicsEndImageContext()
        
        // Display the output image on the screen
        let imageView = UIImageView(image: outputImage)
        return imageView
    }
}

extension UIImage {
    func convertToGrayScale() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.draw(self.cgImage!, in: rect)
        
        guard let grayImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: grayImage)
    }
}

extension UIImage {
    func getPixelIntensity(x: Int, y: Int) -> Int? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        var pixelData = [UInt8](repeating: 0, count: bytesPerPixel)
        
        guard let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        let rect = CGRect(x: x, y: height - y - 1, width: 1, height: 1)
        context.draw(cgImage, in: rect)
        
        let red = CGFloat(pixelData[0])
        let green = CGFloat(pixelData[1])
        let blue = CGFloat(pixelData[2])
        let alpha = CGFloat(pixelData[3])
        let intensity = (red + green + blue) / (3 * alpha)
        
        return Int(intensity)
    }
}
