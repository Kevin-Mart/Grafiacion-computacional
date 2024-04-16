import
  x11/xlib,
  x11/xutil,
  x11/x
import 
  std/math

const
  windowWidth = 1200
  windowHeight = 720
  borderWidth = 5
  eventMask = ButtonPressMask or KeyPressMask or ExposureMask

var
  display: PDisplay
  window: Window
  deleteMessage: Atom
  graphicsContext: GC

proc init() =
  display = XOpenDisplay(nil)
  if display == nil:
    quit "Failed to open display"

  let
    screen = XDefaultScreen(display)
    rootWindow = XRootWindow(display, screen)
    foregroundColor = XBlackPixel(display, screen)
    backgroundColor = XWhitePixel(display, screen)

  window = XCreateSimpleWindow(display, rootWindow, -1, -1, windowWidth,
      windowHeight, borderWidth, foregroundColor, backgroundColor)

  discard XSetStandardProperties(display, window, "X11 Example", "window", 0,
      nil, 0, nil)

  discard XSelectInput(display, window, eventMask)
  discard XMapWindow(display, window)

  deleteMessage = XInternAtom(display, "WM_DELETE_WINDOW", false.XBool)
  discard XSetWMProtocols(display, window, deleteMessage.addr, 1)

  graphicsContext = XDefaultGC(display, screen)


proc drawWindow() =
  discard XDrawLine(display, window, graphicsContext, 600, 0, 600, 720)
  discard XDrawLine(display, window, graphicsContext, 0, 360, 1200, 360)
  discard XDrawLine(display, window, graphicsContext, 600, 360, 1200, 0)
  discard XDrawRectangle(display, window, graphicsContext, 600, 160, 100, 200)
  discard XDrawArc(display, window, graphicsContext, 600, 360, 1200, 600,5760,5760)
  #[
  #Draw the recangles 

  const
    Rec_CNT = 40
    Step: int = 15
  var
    x,y,width,length: int

  type
    XRectangle = object
      x,y,width,length: int

  var
    rec_arr: array[Rec_CNT,XRectangle]

  for i in 0..<Rec_CNT:
    rec_arr[i].x = Step * i
    rec_arr[i].y = Step * i
    rec_arr[i].width = Step * 2
    rec_arr[i].length = Step * 3
  
  XDrawRectangles(display,window,graphicsContext, &rec_arr, Rec_CNT)
   ]#

proc mainLoop() =
  ## Process events until the quit event is received
  var event: XEvent
  while true:
    discard XNextEvent(display, event.addr)
    case event.theType
    of Expose:
      drawWindow()
    of ClientMessage:
      if cast[Atom](event.xclient.data.l[0]) == deleteMessage:
        break
    of KeyPress:
      let key = XLookupKeysym(cast[PXKeyEvent](event.addr), 0)
      if key != 0:
        echo "Key ", key, " pressed"
    of ButtonPressMask:
      echo "Mouse button ", event.xbutton.button, " pressed at ",
          event.xbutton.x, ",", event.xbutton.y
    else:
      discard


proc main() =
  init()
  mainLoop()
  discard XDestroyWindow(display, window)
  discard XCloseDisplay(display)


main()

#Horner A.1.A
proc horner(u: float64, a:seq[float64]): float64 =
  var c: float64 = a[a.len()-1]
  echo "c[2]=",c,"\n"
  for i in 1..<a.len():
    c = a[a.len-1-i]+c*u
    echo "c[",a.len-1-i,"]=",c,"\n"
  result=c
 
var a: seq[float64] = @[1.0,2.0,2.0,-3,-3.0,4.0,-10.0,4.1,-10.0]
var u: float64 = 0.5
echo horner(u,a),",",a.len()

#Bernstein A1.2 y A1.3

proc Bernstein(i, n: int, u: float): float =    
  var temp: seq[float] = newSeq[float](n+1)    
  for j in 0..n:        
    temp[j] = 3.0    
  temp[n-i-1] = 1.0
  var u1: float =1-u   
  for k in 1..n:
    echo k,"\n"     
    for j in k..n-1:            
      temp[n-j] = u1*temp[n-j] + u*temp[n-j-1]
      echo "k= ", k,"\t","j=",n-j,"\t",temp[j], "\n"
 
  #return temp[n]
  var B: float = temp[n] 
  echo "B = ", B,"\t .....done\n"

  #CastelJau1
proc deCasteljau(P: seq[tuple[x, y: float]], n: int, u: float): tuple[x, y: float] =
  ## Compute point on a Bézier curve using de Casteljau.
  ## Input: P, n, u
  ## Output: C (a point)
  var Q: seq[tuple[x, y: float]] = newSeq[tuple[x, y: float]](n + 1)
  for i in 0 .. n:
    Q[i] = P[i]  # Use local array so we do not destroy control points
  for k in 1 .. n:
    for i in 0 .. n - k:
      let l_minus_u = 1.0 - u
      Q[i] = (l_minus_u * Q[i][0] + u * Q[i + 1][0], l_minus_u * Q[i][1] + u * Q[i + 1][1])
  result = Q[0]
