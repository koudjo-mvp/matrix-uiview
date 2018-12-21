//
//  MatrixView.swift
//  MatrixViewExample
//
/*:
 
 # MatrixView
 
 It is a custom UIView displaying Matrix-like objects (like in the movie) automatically scrolling randomly from top to bottom
 
 ## Implementation infos

 */

import UIKit

/*:
 
 ### BackgroundType
 
 enum type used to set the background color of the whole MatrixView
 * `BackgroundType.clear` -> MatrixView's background will be transparent. Useful if you insert a MatrixView in a UIImageView for example
 * `BackgroundType.colored` -> MatrixView's background will have the plain color passed to the pick function
 
 */
enum BackgroundType {case clear, colored
    func pick(color: UIColor) -> UIColor {
        switch self {
        case .clear:
            return UIColor.clear
        case .colored:
            return color
        }
    }
}

/*:
 
 ### CellType
 
 enum type used to set what type of object the whole MatrixView will scroll in the view from top to bottom
 * `CellType.line` -> the MatrixView view will scroll vertical lines from top to bottom of its frame
 * `CellType.rectangle` -> the MatrixView view will scroll rectangles/squares from top to bottom of its frame
 * `CellType.circle` -> the MatrixView view will scroll circles lines from top to bottom of its frame
 * `CellType.text` -> the MatrixView view will scroll text characters from top to bottom of its frame
 
 */
enum CellType {case line, rectangle, circle, text
    func drawLine(ctx: CGContext, to: CGPoint, colors: (bg:UIColor, bd:UIColor)) {
        switch self {
        case .line:
            colors.bd.setStroke()
            colors.bg.setFill()
            ctx.addLine(to:to)
        default:
            print("drawLine was not applied to a line CellType")
        }
    }
    func drawRect(ctx: CGContext, rect: CGRect, colors: (bg:UIColor, bd:UIColor)) {
        switch self {
        case .rectangle:
            colors.bd.setStroke()
            colors.bg.setFill()
            ctx.addRect(rect)
        default:
            print("drawRect was not applied to a line CellType")
        }
    }
    func drawCircle(ctx: CGContext, center: CGPoint, radius: CGFloat, colors: (bg:UIColor, bd:UIColor)) {
        switch self {
        case .circle:
            colors.bd.setStroke()
            colors.bg.setFill()
            ctx.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: CGFloat(2.0 * Double.pi), clockwise: false)
        default:
            print("drawCircle was not applied to a line CellType")
        }
    }
    func drawText(ctx: CGContext, pos: (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat), write: (text:Character, font:String, size:CGFloat), colors: (bg:UIColor, bd:UIColor)) {
        switch self {
        case .text:
            let para_style = NSMutableParagraphStyle()
            para_style.alignment = .center
            let render_font = UIFont(name: write.font, size: write.size) ?? UIFont(name: "HelveticaNeue-Thin", size: CGFloat(19))
            let attrs = [NSAttributedString.Key.font: render_font!, NSAttributedString.Key.foregroundColor:colors.bd, NSAttributedString.Key.strokeColor:colors.bd, NSAttributedString.Key.backgroundColor:colors.bg, NSAttributedString.Key.paragraphStyle: para_style]
            //UIGraphicsPushContext(ctx)
            let render_text = NSAttributedString(string: String(write.text), attributes: attrs)
            render_text.draw(with: CGRect(x: pos.x, y: pos.y, width: pos.width, height: pos.height), options: .usesLineFragmentOrigin, context: nil)
            //UIGraphicsPopContext()
        default:
            print("drawText was not applied to a line CellType")
        }
    }
}

/*:
 
 ### getUIColorFromHexString
 
 function that converts `hex`, a RGB color code expressed as a String of HEX (example "FFFFFF" or "0XFFFFFF" or "#FFFFFF"), to a UIColor object.
 
 If `hex` doesn't have the format "FFFFFF" or "0XFFFFFF" or "#FFFFFF" and is not Empty, **getUIColorFromHexString** will return the default gray UIColor.gray.
 
 If `hex` is an empty String, **getUIColorFromHexString** will return the transparent color UIColor.clear
 
 */
func getUIColorFromHexString(hex: String) -> UIColor?{
    var colorhex = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
    // colorhex should be 6 or 8 characters
    if colorhex.isEmpty {return UIColor.clear}
    
    if colorhex.count < 6 {return UIColor.gray}
    
    // strip 0X from colorhex if it appears
    if colorhex.hasPrefix("0X") {
        let index = colorhex.index(after: colorhex.firstIndex(of: "X")!)
        colorhex = String(colorhex[index...])
    }
    
    // strip # from colorhex if it appears
    if colorhex.hasPrefix("#") {
        let index = colorhex.index(after: colorhex.firstIndex(of: "#")!)
        colorhex = String(colorhex[index...])
    }
    
    if colorhex.count != 6 {return UIColor.gray}
    
    // Separate into r, g, b substrings
    var start = String.Index(encodedOffset: 0)
    var stop = String.Index(encodedOffset: 1)
    let r_string = String(colorhex[...stop])
    
    start = String.Index(encodedOffset: 2)
    stop = String.Index(encodedOffset: 3)
    let g_string = String(colorhex[start...stop])
    
    start = String.Index(encodedOffset: 4)
    stop = String.Index(encodedOffset: 5)
    let b_string = String(colorhex[start...])
    
    // Convert HEX RGB values
    var rc:CUnsignedInt = 0, gc:CUnsignedInt = 0, bc:CUnsignedInt = 0;
    Scanner(string: r_string).scanHexInt32(&rc)
    Scanner(string: g_string).scanHexInt32(&gc)
    Scanner(string: b_string).scanHexInt32(&bc)
    
    return UIColor(red: CGFloat(Float(rc) / 255.0), green: CGFloat(Float(gc) / 255.0), blue: CGFloat(Float(bc) / 255.0), alpha: CGFloat(Float(1)))
}

/*:
 
 ### MatrixView
 
 Custom class inheriting from UIView.
 
 */
class MatrixView: UIView {

    var grid = (nbcols: 1, nbrows: 1, width:0, height:0)
    var grid_cell = (w:0, h:0)
    var start_drawingat = [Int]()
    var grid_cells = [String:String]()
    var anim_timer:Timer?
    var ctype:CellType
    var ccolors:(bg: UIColor,bd: UIColor)
    var ctext:String
    var cfontname:String
    var cfontsize:CGFloat
    
    init(frame: CGRect, grid_dim: (Int, Int), mode: CellType?, background: (BackgroundType, String?)?, colors: (String?, String?)?, write: (text: String?, font: String?, size: CGFloat?)?){
        // set frame background properties, set subviews and add subviews if needed
        grid.width = Int(frame.size.width)
        grid.height = Int(frame.size.height)
        if (grid_dim.0 >= 1 && grid_dim.1 >= 1) { (grid.nbcols, grid.nbrows) = grid_dim }
        
        grid_cell.w = Int(frame.size.width / CGFloat(grid.nbcols));
        grid_cell.h = Int(frame.size.height / CGFloat(grid.nbrows));
        for i in 0...grid.nbcols{
            let random_row_selection = Int(arc4random()) % (grid.nbrows);
            start_drawingat.append(Int(random_row_selection))
            for j in 0...grid.nbrows{
                grid_cells["\(i),\(j)"] = "\(i*grid_cell.w),\(j*grid_cell.h)"
            }
        }
        ctype = mode ?? CellType.rectangle
        ccolors = (bg:getUIColorFromHexString(hex:colors?.0 ?? "FFFF00")!, bd:getUIColorFromHexString(hex:colors?.1 ?? "FFFF00")!)
        ctext = write?.text ?? "T"
        cfontname = write?.font ?? "HelveticaNeue-Thin"
        cfontsize = write?.size ?? CGFloat(17.0)
        anim_timer = nil
        super.init(frame:frame) // always before first usage of self.
        self.backgroundColor = background?.0.pick(color: getUIColorFromHexString(hex:background?.1 ?? "FFFF00")!) ?? UIColor.clear
        self.alpha = 1
        self.isHidden = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        anim_timer = nil
        ctype = CellType.rectangle
        ccolors = (bg:getUIColorFromHexString(hex:"000000")!, bd:getUIColorFromHexString(hex:"000000")!)
        ctext = "T"
        cfontname = "HelveticaNeue-Thin"
        cfontsize = CGFloat(17.0)
        super.init(coder: aDecoder)
    }
    
    func matrixAnimation(t: Timer) {
        self.setNeedsDisplay()
    }
    
    func start() {
        anim_timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            self.matrixAnimation(t:timer)
        })
    }
    
    func stop() {
        if anim_timer != nil {
            anim_timer?.invalidate()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        UIColor.black.setStroke()
        UIColor.black.setFill()
        context!.beginPath()
        var grid_cell_letters = [String:Character]()
        for i in 0...grid.nbcols {
            if ctype == CellType.text {
                grid_cell_letters["\(i)"] = ctext[String.Index(encodedOffset: Int(arc4random()) % (ctext.count))]
            }
            for j in 0...grid.nbrows {
                grid_cells["\(i),\(j)"] = "\(i*grid_cell.w),\(j*grid_cell.h)"
                if j == start_drawingat[i]{
                    let posx = CGFloat(Int(grid_cells["\(i),\(j)"]!.components(separatedBy: ",")[0])!)
                    let posy = CGFloat(Int(grid_cells["\(i),\(j)"]!.components(separatedBy: ",")[1])!)
                    let cellrect = CGRect(x:posx, y:posy, width:CGFloat(grid_cell.w), height:CGFloat(grid_cell.h));
                    context!.move(to:CGPoint(x:cellrect.origin.x,y:cellrect.origin.y))
                    switch ctype {
                    case .line:
                        ctype.drawLine(ctx: context!, to: CGPoint(x:cellrect.origin.x,y:cellrect.origin.y+cellrect.height), colors: ccolors)
                    case .rectangle:
                        ctype.drawRect(ctx: context!, rect: cellrect, colors: ccolors)
                    case .circle:
                        ctype.drawCircle(ctx: context!, center: CGPoint(x:cellrect.origin.x,y:cellrect.origin.y), radius: cellrect.width/2, colors: ccolors)
                    case .text:
                        ctype.drawText(ctx: context!, pos: (x:cellrect.origin.x, y:cellrect.origin.y, width:cfontsize, height:cfontsize), write: (text: grid_cell_letters["\(i)"] ?? "T", font: cfontname, size: cfontsize), colors: ccolors)
                    }
                }
            }
            start_drawingat[i] = (start_drawingat[i] + 1) % grid.nbrows
        }
        context!.closePath()
        context!.drawPath(using: CGPathDrawingMode.fillStroke)
        if self.isHidden {
            self.isHidden = false;
        }
    }
    
}
