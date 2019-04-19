import threading, json, time, os.path
import pickle
from urllib import request
from pymouse import *

LoopInterval = 1
ClickInterval = 0.2
# 不用设置
baseUrl = "http://localhost:8080/locations"

# 不用管，目标工程APP的名字，不用设置
XCodeNames = ["Target App"]

# 用数组，是因为一开始想配置多个目标app，然后实现同时修改多个模拟器的定位，最终发现XCode只能支持修改【最后一次启动】的模拟器位置
ServerUrls = [baseUrl]

# 修改为target_project项目文件夹中location.gpx文件的位置（文件需要拖入过XCode中）
GPXPaths = ["/iOS模拟器定位动态模拟/target_project/location.gpx"]
MOUSE = PyMouse()


class Location():
    # def __init__(self, type, index, lat, lon):
    #     self.type = type
    #     self.index = index
    #     self.lat = lat
    #     self.lon = lon

    def __init__(self, jsonObj):
        # Location.__init__(self, jsonObj["type"], jsonObj["index"], jsonObj["lat"], jsonObj["lon"])
        self.type = jsonObj["type"]
        self.index = jsonObj["index"]
        self.lat = jsonObj["lat"]
        self.lon = jsonObj["lon"]
        self.isValid = jsonObj["isValid"]

    def __str__(self):
        return "LocationType: %s, Idx:%d, lat:%s, lon:%s" % (self.type, self.index, self.lat, self.lon)

class XCodeWindowConfig():
    def __init__(self, name, url, gpxPath, focus=None, locBtn=None, chooseGpx=None):
        self.name = name
        self.url = url
        self.gpxPath = gpxPath
        self.focus = focus
        self.locBtn = locBtn
        self.chooseGpx = chooseGpx

class AsyncThread(threading.Thread):

    def __init__(self, configs):
        threading.Thread.__init__(self)
        self.configs = configs

    def run(self):
        LAST_Response = [-1] * len(XCodeNames)
        GPX1 = '<?xml version="1.0" encoding="UTF-8"?>\n<gpx xmlns="http://www.topografix.com/GPX/1/1" version="1.1" creator="Python Scription">\n\t<wpt lat="'
        GPX2 = '" lon="'
        GPX3 = '"></wpt>\n</gpx>'
        while True:
            print("\n==================================================================")
            for idx, config in enumerate(self.configs):

                response = request.urlopen(config.url)
                jsonLoc = json.loads(response.read())
                location = Location(jsonLoc)
                if not location.isValid:
                    print("\nunValid location")
                    continue

                print(location)

                if LAST_Response[idx] != location.index:
                    print("\n" + config.name + "获得新定位")
                    file = config.gpxPath
                    if not os.path.exists(file):
                        print("Error: GPX文件不存在, Path:" + file)
                        exit(0)

                    with open(file, 'w', encoding='utf-8') as gpx:
                        gpx.write(GPX1 + location.lat + GPX2 + location.lon + GPX3)
                        print("新定位写入成功. -> 将操作XCode.")

                    User_Mouse = MOUSE.position()
                    # 获得focus
                    MOUSE.click(config.focus[0], config.focus[1])
                    # GPX 按钮
                    MOUSE.click(config.locBtn[0], config.locBtn[1])
                    time.sleep(ClickInterval)
                    # 选中 GPX
                    MOUSE.move(config.chooseGpx[0], config.chooseGpx[1])
                    time.sleep(ClickInterval)
                    MOUSE.click(config.chooseGpx[0], config.chooseGpx[1])
                    LAST_Response[idx] = location.index
                    MOUSE.move(User_Mouse[0], User_Mouse[1])
            time.sleep(LoopInterval)

def startThread(configs):
    thread = AsyncThread(configs)
    thread.start()

def getConfig():
    mouse = PyMouse()
    configs = []
    print("###该脚本需要手动调整好各窗口位置才能正确修改模拟器定位###")
    for idx, name in enumerate(XCodeNames):
        input("1、将鼠标移动至 -> [工程" + name + "]" + "窗口 -> [空白可点击获得Focus的地方] -> [Enter]确认")
        config = XCodeWindowConfig(name, ServerUrls[idx], GPXPaths[idx])
        config.focus = mouse.position()
        input("2、将鼠标移动至 -> [工程" + name + "]" + "窗口 -> [修改GPX文件的按钮处] -> [Enter]确认")
        config.locBtn = mouse.position()
        input("3、将鼠标移动至 -> [工程" + name + "]" + "窗口 -> [选中GPX文件的按钮处] -> [Enter]确认")
        config.chooseGpx = mouse.position()
        configs.append(config)
    fn = 'config.pkl'
    with open(fn, 'wb') as f:
        pickle.dump(configs, f)

    return configs

def main():
    # if len(sys.argv) > 1:
    # arg = sys.argv[1]
    # if arg != "--no-guide":
    fn = 'config.pkl'
    if os.path.exists(fn):
        if len(sys.argv) > 1 and sys.argv[1] == "--clear-cache":
            os.remove(fn)
            print("已删除缓存的配置文件:config.pkl")
            return
        with open(fn, 'rb') as f:
            configs = pickle.load(f)
            if len(configs) > 0 and input("是否选择上一次配置的指针坐标操作：1-是  0-否（需确保窗口没有发生变化）") == "1":
                startThread(configs)
            else:
                startThread(getConfig())
    else:
        if len(sys.argv) > 1 and sys.argv[1] == "--clear-cache":
            print("没有缓存的配置文件:config.pkl")
            exit(0)
        startThread(getConfig())

if __name__ == '__main__':
    main()
