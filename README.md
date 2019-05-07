<a href="https://996.icu"><img src="https://img.shields.io/badge/link-996.icu-red.svg" alt="996.icu" /></a>
[![LICENSE](https://img.shields.io/badge/license-Anti%20996-blue.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)

# iOSDynamicLocation
iOS中高德地图、百度地图在模拟器上，通过GPX文件，利用脚本动态修改目标模拟器位置的示例。

![运行效果](https://github.com/HuangYanQi/assets_repository/blob/master/images/运行效果小gif.gif)

#使用方式
###准备
下载整个项目

```
cd iOSDynamicLocation/Demo-Server
``` 
```
pod install
```
```
cd ../target_project
```
```
pod install
```
到[百度地图开放平台](http://lbsyun.baidu.com)申请***App AK***
到[高德地图开放平台](https://lbs.amap.com)申请***App Key***。（上述AK，Key以下简称***Key***）

对于**Demo-Server**，上述两平台的Key必须重新申请，并设置**Demo-Server**的**bundleId**

对于**target_project**，该项目用于示例，可以换为你自己需要修改定位的***任意app工程***，也可以将bundle id修改为已有工程的bundle id，并在AppDelegate中设置好对应的key。

如果使用你需要动态模拟定位的目标工程，需要在工程中添加好用于修改定位的gpx文件，如**target_project中的location.gpx**，并修改**dynamicLocation.py**中的***GPXPaths***
```
GPXPaths = ["上述GPX文件路径"]
```

###运行

1、打开Demo-Server编译运行在模拟器1，以下简称***模拟器Server***

2、打开你需要修改定位的模拟器工程运行在模拟器2，以下简称***模拟器Client***
3、打开终端cd到**dynamicLocation.py**所在目录，并运行

![准备配置](https://github.com/HuangYanQi/assets_repository/blob/master/images/准备运行.png)
###脚本步骤说明
1、第一步将鼠标移动至XCode目标工程的空白可以点击的地方（不要点击，如窗口边框上），按回车

2、第二步将鼠标移动选择GPX文件的按钮处（不要点击），按回车

![第二步](https://github.com/HuangYanQi/assets_repository/blob/master/images/2.png)

3、第三步先点击选择GPX文件的按钮，弹出菜单，将鼠标移至gpx文件的位置，按ESC，利用控制台的文件标记鼠标位置，点击终端让终端获得焦点（也可以通过快捷键让终端获得焦点），然后按下enter

![第三步1](https://github.com/HuangYanQi/assets_repository/blob/master/images/3-1.png)

![第三步2](https://github.com/HuangYanQi/assets_repository/blob/master/images/3-2.png)

4、随后就能通过在***模拟器server***点击地图上的位置，动态修改***模拟器Client***的位置

5、在***模拟器server***上面选择坐标点后，手指一定要离开触控板，或者不要移动鼠标。否则会影响脚本操作鼠标

##最后
本项目能够帮助你在地图相关iOSapp开发中提高调试效率，希望你能支持[996.icu](https://996.icu/#/en_US)，也希望更多的同行，在编程的路上能拥有更多属于自己的时间陪陪家人


