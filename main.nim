import x11/xlib, x11/xutil, x11/x

const
  windowWidth = 1000
  windowHeight = 600
  borderWidth = 5
  eventMask = ButtonPressMask or KeyPressMask or ExposureMask

var
  display: PDisplay
  window: Window
  deleteMessage: Atom
  graphicsContext: GC

const
  controlPoints: array[4, tuple[x, y: cint]] = [
    (100, 300),
    (300, 100),
    (600, 500),
    (900, 300)
  ]


proc init() =
  display = XOpenDisplay(nil)
  if display == nil:
    quit "Error al abrir el display"

  let
    screen = XDefaultScreen(display)
    rootWindow = XRootWindow(display, screen)
    foregroundColor = XBlackPixel(display, screen)
    backgroundColor = XWhitePixel(display, screen)

  window = XCreateSimpleWindow(display, rootWindow, -1, -1, windowWidth,
      windowHeight, borderWidth, foregroundColor, backgroundColor)

  discard XSetStandardProperties(display, window, "Ejemplo X11", "ventana", 0,
      nil, 0, nil)

  discard XSelectInput(display, window, eventMask)
  discard XMapWindow(display, window)

  deleteMessage = XInternAtom(display, "WM_DELETE_WINDOW", false.XBool)
  discard XSetWMProtocols(display, window, deleteMessage.addr, 1)

  graphicsContext = XDefaultGC(display, screen)

proc drawWindow() =
  const text = "Hello, Nim programmers."
  discard XDrawString(display, window, graphicsContext, 10, 50, text, text.len)
proc drawBezierCurve() =
  for i in 0 .. 99:
    var t = i/100
    var oneMinusT = 1.0 - t
    var x = float(oneMinusT * oneMinusT * oneMinusT) * float(controlPoints[0][0]) +
            3.0 * float(oneMinusT * oneMinusT * t) * float(controlPoints[1][0]) +
            3.0 * float(oneMinusT * t * t) * float(controlPoints[2][0]) +
            float(t * t * t) * float(controlPoints[3][0])
    var y = float(oneMinusT * oneMinusT * oneMinusT) * float(controlPoints[0][1]) +
            3.0 * float(oneMinusT * oneMinusT * t) * float(controlPoints[1][1]) +
            3.0 * float(oneMinusT * t * t) * float(controlPoints[2][1]) +
            float(t * t * t) * float(controlPoints[3][1])
    var nextT = t + 0.01
    var nextOneMinusT = 1.0 - nextT
    var xNext = float(nextOneMinusT * nextOneMinusT * nextOneMinusT) * float(controlPoints[0][0]) +
                3.0 * float(nextOneMinusT * nextOneMinusT * nextT) * float(controlPoints[1][0]) +
                3.0 * float(nextOneMinusT * nextT * nextT) * float(controlPoints[2][0]) +
                float(nextT * nextT * nextT) * float(controlPoints[3][0])
    var yNext = float(nextOneMinusT * nextOneMinusT * nextOneMinusT) * float(controlPoints[0][1]) +
                3.0 * float(nextOneMinusT * nextOneMinusT * nextT) * float(controlPoints[1][1]) +
                3.0 * float(nextOneMinusT * nextT * nextT) * float(controlPoints[2][1]) +
                float(nextT * nextT * nextT) * float(controlPoints[3][1])
    XDrawLine(display,window,graphicsContext,int(x),int(y),int(xNext),int(yNext))

proc mainLoop() =
  var event: XEvent
  while true:
    discard XNextEvent(display, event.addr)
    case event.theType
    of Expose:
      drawWindow()
      #drawBezierCurve()  # Llama a la función para dibujar la curva de Bézier
    of ClientMessage:
      if cast[Atom](event.xclient.data.l[0]) == deleteMessage:
        break
    of KeyPress:
      let key = XLookupKeysym(cast[PXKeyEvent](event.addr), 0)
      if key != 0:
        echo "Tecla ", key, " presionada"
    of ButtonPressMask:
      echo "Botón del mouse ", event.xbutton.button, " presionado en ",
          event.xbutton.x, ",", event.xbutton.y
    else:
      discard

proc main() =
  init()
  mainLoop()
  discard XDestroyWindow(display, window)
  discard XCloseDisplay(display)

main()
