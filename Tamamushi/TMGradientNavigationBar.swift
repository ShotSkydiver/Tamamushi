//
//  TMGradientNavigationBar.swift
//  Tamamushi
//
//  Created by 母利 睦人 on 2016/12/06.
//  Copyright © 2016年 Femact Inc. All rights reserved.
//

import UIKit

// Gradient color direction
public enum Direction {
    case vertical
    case horizontal
}

public class TMGradientNavigationBar: NSObject {
    private var gradientColors:[TMColor] = []

    public override init() {
        super.init()
        loadColors()
    }

    public func setInitialBarGradientColor(direction: Direction, typeName: String) {
        if let gradientColor = gradientColorWithName(name: typeName) {
            let image = generateGradientImage(direction: direction, startColor: gradientColor.startColor, endColor: gradientColor.endColor, startPoint: CGPoint(x:0.0,y:0.5), endPoint: CGPoint(x:0.3,y:0.5))
            setInitialImageToNavigationBar(image: image)
        }
    }

    public func setInitialBarGradientColor(direction: Direction, startColor: UIColor, endColor: UIColor) {
        let image = generateGradientImage(direction: direction, startColor: startColor, endColor: endColor, startPoint: CGPoint(x:0.0,y:0.5), endPoint: CGPoint(x:0.3,y:0.5))
        setInitialImageToNavigationBar(image: image)
    }

    public func setGradientColorOnNavigationBar(bar: UINavigationBar, direction: Direction, typeName: String) {
        if let gradientColor = gradientColorWithName(name: typeName) {
            let image = generateGradientImage(direction: direction, startColor: gradientColor.startColor, endColor: gradientColor.endColor, startPoint: CGPoint(x:0.0,y:0.5), endPoint: CGPoint(x:0.3,y:0.5))
            bar.barTintColor = UIColor(patternImage: image)
        }
    }

    // Method to set navigationBar gradient from UIViewController which has NavigationBar
    public func setGradientColorOnNavigationBar(bar: UINavigationBar, direction: Direction, startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {

        let image = generateGradientImage(direction: direction, startColor: startColor, endColor: endColor, startPoint: startPoint, endPoint: endPoint)
        bar.barTintColor = UIColor(patternImage: image)
    }

    // Extract gradient color with the name specified
    private func gradientColorWithName(name: String) -> TMColor? {
        let matchedGradientColors = gradientColors.filter { $0.name == name }
        if matchedGradientColors.count > 0 {
            let gradientColor = matchedGradientColors[0]
            if let _ = gradientColor.startColor, let _ = gradientColor.endColor {
                return gradientColor
            } else {
                print("colors are not specified in JSON file")
                return nil
            }
        } else {
            print("specified type name doesn't match any of the gradient colors")
            return nil
        }
    }

    // Create UIImage with the gradient specified
    public func generateGradientImage(direction: Direction, startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint, height: CGFloat = 64.0) -> UIImage {
        let gradientLayer = CAGradientLayer()
        //    gradient.frame = CGRect(x: 0, y: 0, width: UIApplication.sharedApplication().statusBarFrame.width, height: UIApplication.sharedApplication().statusBarFrame.height + self.navigationController!.navigationBar.frame.height)

        // let sizeLength = UIScreen.main.bounds.size.height * 2
        let navBarFrame = CGRect(x: 0, y: 0, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + height)
        gradientLayer.frame = navBarFrame
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]

        if direction == .horizontal {
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
        }

        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }

    // Method to set image from AppDelegate
    private func setInitialImageToNavigationBar(image: UIImage) {
        UINavigationBar.appearance().setBackgroundImage(image, for: .default)
    }

    // Load gradient colors form json file
    private func loadColors() {
        if let path = Bundle.init(for: TMGradientNavigationBar.self).path(forResource: "gradients", ofType: "json") {
            do {
                let data = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                if let parsedData = try? JSONSerialization.jsonObject(with: data as Data) as! [[String: Any]] {
                    parsedData.forEach({ (eachData) in
                        let name = eachData["name"] as! String
                        var colors = eachData["colors"] as! [String]
                        let startColor = UIColor.hexStr(colors[0] as NSString, alpha: 1.0)
                        let endColor = UIColor.hexStr(colors[1] as NSString, alpha: 1.0)
                        let gradientColor = TMColor(startColor: startColor, endColor: endColor, name: name)
                        gradientColors.append(gradientColor)
                    })
                }
            } catch {
                print("error occured")
            }
        } else {
            print("no json file found")
        }
    }
}
