import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.png"
let cs = CGColorSpaceCreateDeviceRGB()

guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: cs,
    // 不输出 alpha 通道：App Store / 图标规范要求不透明
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else {
    fatalError("cannot create context")
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r, g, b, a])!
}

// 背景
let bg = CGGradient(
    colorsSpace: cs,
    colors: [rgb(0.02, 0.01, 0.05), rgb(0.09, 0.03, 0.20), rgb(0.03, 0.01, 0.08)] as CFArray,
    locations: [0, 0.55, 1]
)!
ctx.drawLinearGradient(bg, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size, y: size), options: [])

// 中心光晕
let glow = CGGradient(
    colorsSpace: cs,
    colors: [rgb(0.55, 0.14, 0.85, 0.42), rgb(0.10, 0.03, 0.25, 0)] as CFArray,
    locations: [0, 1]
)!
ctx.drawRadialGradient(
    glow,
    startCenter: CGPoint(x: 512, y: 512), startRadius: 20,
    endCenter: CGPoint(x: 512, y: 512), endRadius: 560,
    options: []
)

// 四角发光方块
func drawBlock(cx: CGFloat, cy: CGFloat, s: CGFloat, angle: CGFloat, color: CGColor) {
    ctx.saveGState()
    ctx.translateBy(x: cx, y: cy)
    ctx.rotate(by: angle)
    let r = s * 0.17
    let rect = CGRect(x: -s/2, y: -s/2, width: s, height: s)
    let path = CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 34, color: color.copy(alpha: 0.55))
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)

    let hi = CGRect(x: -s/2 + s*0.14, y: s/2 - s*0.30, width: s*0.72, height: s*0.16)
    ctx.addPath(CGPath(roundedRect: hi, cornerWidth: s*0.08, cornerHeight: s*0.08, transform: nil))
    ctx.setFillColor(rgb(1, 1, 1, 0.30))
    ctx.fillPath()

    let lo = CGRect(x: -s/2 + s*0.14, y: -s/2 + s*0.12, width: s*0.72, height: s*0.08)
    ctx.addPath(CGPath(roundedRect: lo, cornerWidth: s*0.04, cornerHeight: s*0.04, transform: nil))
    ctx.setFillColor(rgb(0, 0, 0, 0.22))
    ctx.fillPath()
    ctx.restoreGState()
}

drawBlock(cx: 155, cy: 225, s: 190, angle: 0.10, color: rgb(0.16, 0.90, 1.0))
drawBlock(cx: 865, cy: 205, s: 170, angle: -0.12, color: rgb(1.0, 0.18, 0.53))
drawBlock(cx: 150, cy: 800, s: 150, angle: -0.12, color: rgb(1.0, 0.82, 0.24))
drawBlock(cx: 875, cy: 810, s: 145, angle: 0.13, color: rgb(0.54, 0.36, 1.0))

func drawLine(_ text: String, fontName: String, fontSize: CGFloat, kern: CGFloat,
              color: CGColor, centerX: CGFloat, baseline: CGFloat,
              shadow: CGColor? = nil, blur: CGFloat = 0) {
    let font = CTFontCreateWithName(fontName as CFString, fontSize, nil)
    let attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        NSAttributedString.Key(kCTKernAttributeName as String): NSNumber(value: Double(kern))
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    let bounds = CTLineGetBoundsWithOptions(line, [.useOpticalBounds])
    if let shadow = shadow {
        ctx.setShadow(offset: .zero, blur: blur, color: shadow)
    }
    ctx.textPosition = CGPoint(x: centerX - bounds.width/2 - bounds.origin.x, y: baseline)
    CTLineDraw(line, ctx)
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
}

drawLine("TETRIS", fontName: "Helvetica-Bold", fontSize: 74, kern: 12,
         color: rgb(0.78, 0.94, 1.0), centerX: 512, baseline: 700,
         shadow: rgb(0.13, 0.9, 1.0, 0.35), blur: 18)

drawLine("99", fontName: "Helvetica-Bold", fontSize: 400, kern: -12,
         color: rgb(1, 1, 1), centerX: 512, baseline: 300,
         shadow: rgb(1.0, 0.10, 0.5, 0.65), blur: 50)

// 细边框
let borderRect = CGRect(x: 26, y: 26, width: 972, height: 972)
ctx.addPath(CGPath(roundedRect: borderRect, cornerWidth: 180, cornerHeight: 180, transform: nil))
ctx.setStrokeColor(rgb(0.5, 0.7, 1.0, 0.12))
ctx.setLineWidth(2)
ctx.strokePath()

guard let image = ctx.makeImage() else { fatalError("no image") }
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("cannot create destination")
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("cannot write png") }
print("wrote \(outPath)")
