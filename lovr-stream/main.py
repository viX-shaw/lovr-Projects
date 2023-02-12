import time
import traceback

from flask import Flask, send_from_directory, send_file, request
# from threading import Thread
# from queue import Queue
from multiprocessing import Process, Queue

ip_allow_list = ["127.0.0.1"]
ip_allow_list.extend([f"192.168.1.{i}" for i in range(10)])
print(ip_allow_list)
app = Flask(__name__)

@app.route("/stream")
def send_img():
    if not q.empty() and request.environ.get('REMOTE_ADDR') in ip_allow_list:
        return send_file(q.get(), mimetype="image/png")
    return "False"
        # return send_from_directory("images", "visual studio code_.png")

@app.route("/mm/<int:cd1>/<int:cd2>")
def movemouse(cd1, cd2):
    import win32api
    win32api.SetCursorPos((cd1, cd2))
    # For click , https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-mouse_event?redirectedfrom=MSDN
    # ctypes.windll.user32.mouse_event(2, 0, 0, 0,0) # left down
    # ctypes.windll.user32.mouse_event(4, 0, 0, 0,0) # left up
    return "False"


t1 = time.time()

def get_shots(q, t1):
    try:
        import io
        import win32gui
        from PIL import ImageGrab, ImageDraw

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
            # if len(get_screens(screen)) <= 0:
            #     cont = False
            #     print("Saved " + str(i+1) + " images...")
            #     continue
            if i % 50 == 0:
                print("FPS", time.time() - t1)
            # hwnd = screens[0][0]
            try:
                _,_,(x, y) = win32gui.GetCursorInfo()
                # hwnd = win32gui.GetDesktopWindow()
                # bbox = win32gui.GetWindowRect(hwnd)
                # img = ImageGrab.grab(bbox)
                img = ImageGrab.grab()
                draw = ImageDraw.Draw(img)
                draw.polygon([(x,y), (x, y+10), (x+10, y), (x+10, y+10)], fill=128)
                img_io = io.BytesIO()
                img.save(img_io, "PNG")
                img_io.seek(0)
                if q.full():
                    _ = q.get()
                q.put(img_io)
                i += 1
            except:
                print("There was an error...", traceback.print_exc())
            # time.sleep(1)
            winlist = []
    except:
        traceback.print_exc()

if __name__ == '__main__':
    q = Queue(maxsize=2)
    # th = Thread(target=get_shots, args=(q, t1,), daemon=True)
    th = Process(target=get_shots, args=(q, t1,), daemon=True)
    th.start()
    app.run(host="0.0.0.0", port=4990, threaded=True, debug=False)
# else:
#     q = Queue(maxsize=2)
#     # th = Thread(target=get_shots, args=(q, t1,), daemon=True)
#     th = Process(target=get_shots, args=(q, t1,), daemon=True)
#     th.start()