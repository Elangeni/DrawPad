/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ViewController: UIViewController {
  
  var lastPoint = CGPoint.zero
  var color = UIColor.black
  var brushWidth: CGFloat = 10.0
  var opacity: CGFloat = 1.0
  var swiped = false

  
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var tempImageView: UIImageView!
  
  // MARK: - Actions
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    swiped = false
    lastPoint = touch.location(in: view)
  }

  func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
    // 1
    UIGraphicsBeginImageContext(view.frame.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    tempImageView.image?.draw(in: view.bounds)
    
    // 2
    context.move(to: fromPoint)
    context.addLine(to: toPoint)
    
    // 3
    context.setLineCap(.round)
    context.setBlendMode(.normal)
    context.setLineWidth(brushWidth)
    context.setStrokeColor(color.cgColor)
    
    // 4
    context.strokePath()
    
    // 5
    tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    tempImageView.alpha = opacity
    UIGraphicsEndImageContext()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    // 6
    swiped = true
    let currentPoint = touch.location(in: view)
    drawLine(from: lastPoint, to: currentPoint)
    
    // 7
    lastPoint = currentPoint
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !swiped {
      // draw a single point
      drawLine(from: lastPoint, to: lastPoint)
    }
    
    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(mainImageView.frame.size)
    mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
    tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    tempImageView.image = nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let navController = segue.destination as? UINavigationController,
      let settingsController = navController.topViewController as? SettingsViewController
      else {
        return
    }
    settingsController.delegate = self
    settingsController.brush = brushWidth
    settingsController.opacity = opacity
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    settingsController.red = red
    settingsController.green = green
    settingsController.blue = blue
  }

  
  @IBAction func resetPressed(_ sender: Any) {
    mainImageView.image = nil
  }
  
  @IBAction func sharePressed(_ sender: Any) {
    guard let image = mainImageView.image else {
      return
    }
    let activity = UIActivityViewController(activityItems: [image],
                                            applicationActivities: nil)
    present(activity, animated: true)

  }
  
  @IBAction func pencilPressed(_ sender: UIButton) {
    // 1
    guard let pencil = Pencil(tag: sender.tag) else {
      return
    }
    
    // 2
    color = pencil.color
    
    // 3
    if pencil == .eraser {
      opacity = 1.0
    }

  }
}

// MARK: - SettingsViewControllerDelegate

extension ViewController: SettingsViewControllerDelegate {
  func settingsViewControllerFinished(_ settingsViewController: SettingsViewController) {
    brushWidth = settingsViewController.brush
    opacity = settingsViewController.opacity
    dismiss(animated: true)
    
    color = UIColor(red: settingsViewController.red,
                    green: settingsViewController.green,
                    blue: settingsViewController.blue,
                    alpha: opacity)

  }
}
