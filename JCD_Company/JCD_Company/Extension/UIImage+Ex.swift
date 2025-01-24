//
//  UIImage+Ex.swift
//  YS_HelloRead
//
//  Created by Cloud on 2018/12/22.
//  Copyright © 2018 chaoyun. All rights reserved.
//  swiftlint:disable identifier_name

import UIKit

extension UIImage {
    
    func getJPGSize(_ compressionQuality: CGFloat = 0.5) -> Float {
        if let data = jpegData(compressionQuality: compressionQuality) {
            return Float(data.count)/1024
        } else {
            return 0
        }
    }
    
    public static func convertViewToImage(v: UIView) -> UIImage {
        let s = v.bounds.size
        UIGraphicsBeginImageContextWithOptions(s, true, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            v.layer.render(in: context)
        }
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = currentImage {
            return image
        }
        return UIImage()
    }
    
    func createImage(isCornored: Bool = true, size: CGSize = CGSize.zero, backgroundColor: UIColor = UIColor.white, callBack: @escaping(_ image: UIImage) -> Void) {
        DispatchQueue.global().async { //在子线程中执行
            let rect = CGRect(origin: CGPoint.zero, size: size)
            UIGraphicsBeginImageContext(size) //1. 开启上下文
            backgroundColor.setFill() //2. 设置颜色
            UIRectFill(rect) //3. 颜色填充
            let path = UIBezierPath(ovalIn: rect) //4. 图像绘制
            path.addClip() //切回角
            self.draw(in: rect)
            let currentImage = UIGraphicsGetImageFromCurrentImageContext() //5. 获取图片
            UIGraphicsEndImageContext() //6 关闭上下文
            DispatchQueue.main.async(execute: { //回到主线程刷新UI
                if let image = currentImage {
                    callBack(image)
                }
            })
        }
    }
    
    // MARK: - 传进去字符串,生成二维码图片
    static func setupQRCodeImage(_ text: String, image: UIImage?) -> UIImage {
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        //将url加入二维码
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        //取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
            //生成清晰度更好的二维码
            let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: 300)
            //如果有一个头像的话，将头像加入二维码中心
            if let image = image {
                //给头像加一个白色圆边（如果没有这个需求直接忽略）
//                image = circleImageWithImage(image, borderWidth: 5, borderColor: UIColor.white)
                //合成图片
                let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 80, height: 80)
                
                return newImage
            }
            
            return qrCodeImage
        }
        
        return UIImage()
    }
    // MARK: - 生成高清的UIImage
   static  func setupHighDefinitionUIImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion)
        bitmapRef.draw(bitmapImage, in: integral)
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }
    
    //生成边框
    static func circleImageWithImage(_ sourceImage: UIImage, borderWidth: CGFloat, borderColor: UIColor) -> UIImage {
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        UIGraphicsGetCurrentContext()
        
        let radius = (sourceImage.size.width < sourceImage.size.height ? sourceImage.size.width:sourceImage.size.height) * 0.5
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: imageWidth * 0.5, y: imageHeight * 0.5), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    //image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    static func syntheticImage(_ image: UIImage, iconImage: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        //开启图片上下文
        UIGraphicsBeginImageContext(image.size)
        //绘制背景图片
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        // swiftlint:disable identifier_name
        let x = (image.size.width - width) * 0.5
        // swiftlint:disable identifier_name
        let y = (image.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回合成好的图片
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }
    // MARK: 改变图片颜色
    func imageChangeColor(color: UIColor) -> UIImage {
        // 获取画布
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 画笔沾取颜色
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        // 绘制一次
        draw(in: bounds, blendMode: .overlay, alpha: 1.0)
        // 再绘制一次
        draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        // 获取图片
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return img
    }
    
    static func imageFromColor(color: UIColor, rect: CGRect? = CGRect(x: 0, y: 0, width: 10, height: 10)) -> UIImage {
        UIGraphicsBeginImageContext(rect?.size ?? CGSize())
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect ?? .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func getImageWithColor(color: UIColor, size: CGSize, isRounded: Bool) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        if isRounded {
            let radius = 22.5
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            let context = UIGraphicsGetCurrentContext()
            let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: radius, height: radius))
            context!.addPath(path.cgPath)
            context?.clip()
            image?.draw(in: rect)
            context?.drawPath(using: CGPathDrawingMode.fillStroke)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image!
    }
    
    //将图片缩放成指定尺寸（多余部分自动删除）
    func scaled(to newSize: CGSize) -> UIImage {
        //计算比例
        let aspectWidth  = newSize.width/size.width
        let aspectHeight = newSize.height/size.height
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        //图片绘制区域
        var scaledImageRect = CGRect.zero
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = 0
            //(size.width - size.width * aspectRatio)/2
        scaledImageRect.origin.y    = 0
            //(size.height - size.height * aspectRatio)/2
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)//图片不失真
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }

    //获取系统启动页图片
    static func getLaunchImage() -> UIImage {
        var lauchImg: UIImage!
        var viewOrientation: String!
        let viewSize = UIScreen.main.bounds.size
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            viewOrientation = "Landscape"
        } else {
            viewOrientation = "Portrait"
        }
        let imgsInfoArray = Bundle.main.infoDictionary!["UILaunchImages"]
        for dict: [String: String] in imgsInfoArray as! Array {
            let imageSize = NSCoder.cgSize(for: dict["UILaunchImageSize"]!)
            if __CGSizeEqualToSize(imageSize, viewSize) && viewOrientation == dict["UILaunchImageOrientation"]! as String {
                let img = UIImage(named: dict["UILaunchImageName"]!)
                /// iPhone XS Max会取到iPhone XR的启动页，所以造成显示不正确，需加入下面的判断，oc代码一样，就不添加了
                lauchImg = img
            }
        }
        return lauchImg
    }
}
