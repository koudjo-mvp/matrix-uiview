# matrix-uiview
**MatrixView** is a configurable custom UIView displaying multiple streams of objects scrolling randomly from top to bottom

## How to use it?
### 1. Instanciation
In the `viewDidLoad()` method of your ViewController, use `MatrixView(frame:,grid_dim:,mode:,background:,colors:,write:)` to instanciate the class. You dont have to pass all the arguments, set them as nil if you dont need them.

**Arguments**

* *frame* -> Dimensions of the Frame in which the custom view should be displayed. **Required**
* *grid_dim* -> 2-uple of Integers `(nbcols, nbrows)` setting the number of columns and rows the MatrixView's frame will be divided into. This parameter is used by MatrixView to define the size of each scrolling object in the animation. Value of both nbcols and nbrows must be > 1. **Required**
* *mode* -> Type of the objects that will be animated in the view. You can choose between `CellType.line` (Lines), `CellType.rectangle` (Rectangles, squares), `CellType.circle` (Circles), `CellType.text` (Character). See details of CellType type in `MatrixView.swift` src code. If *mode* set to nil, default value CellType.square is used
* *background* -> 2-uple `(BackgroundType, String)` setting the MatrixView's frame's background color. BackgroundType can be `BackgroundType.clear` - for a transparent background or `BackgroundType.colored` - for a plain colored background. If BackgroundType is set to BackgroundType.colored, then the second argument String (color code value format "FFFFFF" or "0XFFFFFF" or "#FFFFFF") in the tuple will be used to set MatrixView's frame's background color. If *background* set to nil, default value UIColor.clear is used (tranparent background). If *background* set to a value != nil, the 2-uple first argument must *not* be nil
* *colors* -> 2-uple `(String, String)` setting the MatrixView's scrolling objects fill color and border color. 1st argument of the 2-uple sets the scrolling objects fill color, 2nd argument sets the border color. String color code value format accepted are "FFFFFF" or "0XFFFFFF" or "#FFFFFF" or "" (empty string will set a UIColor.clear). If *colors* set to nil, default value UIColor.yellow is used for both fill and border colors of the scrolling objects
* *write* -> 3-uple `(text: String?, font: String?, size: CGFloat?)` setting the properties of the text characters to be rendered when *mode* = `CellType.text`. If *write* set to nil, the default text characters to be scrolled in the view will all be "T" (otherwise it will be a random selection of any character in `text`), the default Font used will be "HelveticaNeue-Thin", and the default Font size to be used will be 17.0
 
**Examples**
 
`let mycustomview = MatrixView(frame: mainframe, grid_dim: (10,20), mode: nil, background: nil, colors: nil, write: nil)` -> Watch the resulting UIView in ./examples/MatrixExample1.mov

`let mycustomview = MatrixView(frame: mainframe, grid_dim: (10,20), mode: CellType.line, background: nil, colors: nil, write: nil)` -> Watch the resulting UIView in ./examples/MatrixExample2.mov

`let mycustomview = MatrixView(frame: mainframe, grid_dim: (10,20), mode: CellType.circle, background: (BackgroundType.clear,nil), colors: nil, write: nil)` -> Watch the resulting UIView in ./examples/MatrixExample3.mov

`let mycustomview = MatrixView(frame: mainframe, grid_dim: (10,20), mode: CellType.rectangle, background: (BackgroundType.colored,"#999900"), colors: ("FFFFFF",nil), write: nil)` -> Watch the resulting UIView in ./examples/MatrixExample4.mov

`let mycustomview = MatrixView(frame: mainframe, grid_dim: (10,20), mode: CellType.text, background: (BackgroundType.colored,"#999900"), colors: ("","#FFFFCC"), write: (text: "ケtイrタyテoリuカt利", font: nil, size: CGFloat(36)))` -> Watch the resulting UIView in ./examples/MatrixExample5.mov

<video width="320" height="240" controls>
  <source src="./examples/MatrixExample5.mov" type="video/mp4">
</video>

### 2. Display
add your newly created MatrixView object to a view of your choice.

**Examples**

Device screen main UIView `self.view = mycustomview` or `self.view.addSubview(mycustomview)`
custom UIImageView `myimageview.addSubview(mycustomview)`

### 3. Start/Stop the animation
Start/Stop the automatic scrolling of the objects you defined above by invoking the `start()` and `stop()` methods.

**Examples**

`mycustomview.start()`

`mycustomview.stop()`

See the sample code in the controllers/ViewController.swift project file
