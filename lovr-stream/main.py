import time
import traceback

from flask import Flask, send_from_directory, send_file
from threading import Thread
from queue import Queue

app = Flask(__name__)

@app.route("/stream")
def send_img():
    if not q.empty():
        return send_file(q.get(), mimetype="image/png")
    return "True"
        # return send_from_directory("images", "visual studio code_.png")

def get_shots(q):
    try:
        import io
        import win32gui
        from PIL import ImageGrab

        def enum_cb(hwnd, results):
            winlist.append((hwnd, win32gui.GetWindowText(hwnd)))
            
        def get_screens(screen_name):
            # wait for the program to start initially.
            win32gui.EnumWindows(enum_cb, winlist)
            screens = [(hwnd, title) for hwnd, title in winlist if screen_name in title.lower()]
            # print("SCREENS", winlist)
            while len(screens) == 0:
                screens = [(hwnd, title) for hwnd, title in winlist if screen_name in title.lower()]
                win32gui.EnumWindows(enum_cb, winlist)
            return screens

        winlist = []
        screen = 'visual studio code'
        screens = get_screens(screen)
        i = 0
        cont = True
        while cont:
            if len(get_screens(screen)) <= 0:
                cont = False
                print("Saved " + str(i+1) + " images...")
                continue
            hwnd = screens[0][0]
            try:
                hwnd = win32gui.GetForegroundWindow()
                bbox = win32gui.GetWindowRect(hwnd)
                img = ImageGrab.grab(bbox)
                # img.save('images/'+screen+'_'+'.png')
                img_io = io.BytesIO()
                img.save(img_io, "PNG")
                img_io.seek(0)
                if q.full():
                    _ = q.get()
                q.put(img_io)
                i += 1
            except:
                print("There was an error...", traceback.print_exc())
            time.sleep(1)
            winlist = []
    except:
        traceback.print_exc()

if __name__ == '__main__':
    q = Queue(maxsize=2)
    th = Thread(target=get_shots, args=(q,), daemon=True)
    th.start()
    app.run(host="0.0.0.0", port=4990, threaded=True, debug=True)

    # time.sleep(100)
    # screen = 'visual studio code'
    # screens = get_screens(screen)
    # i = 0
    # cont = True
    # while cont:
    #     if len(get_screens(screen)) <= 0:
    #         cont = False
    #         print("Saved " + str(i+1) + " images...")
    #         continue
    #     hwnd = screens[0][0]
    #     try:
    #         win32gui.SetForegroundWindow(hwnd)
    #         bbox = win32gui.GetWindowRect(hwnd)
    #         img = ImageGrab.grab(bbox)
    #         img.save('images/'+screen+'_'+str(i)+'.png')
    #         i += 1
    #     except:
    #         print("There was an error...", traceback.print_exc())
    #     time.sleep(5)
    #     winlist = []
