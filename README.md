# PF
Tracking by PF
基于粒子滤波的matlab仿真程序，用来跟踪并输出羽毛球轨迹
需要将待跟踪视频首先进行离散化为单帧图片存入特定位置，并对应修改程序内文件位置
示例中初始识别位置已经给定，使用中可以选择在图像中拉取识别框对框内图像进行跟踪，也可以通过拉取识别框获取所需要的位置信息后修改位置信息以达到对初始位置相近的不同离散视频图像内特定位置图像的跟踪
对于速度较慢的物体或者离散后相邻帧中清晰且位置变化较小的物体可以使用较少的粒子数目较为集中的初始粒子分布划定待跟踪物体整体进行跟踪以获得更加稳定且效果良好的跟踪轨迹
对于速度较快的物体或者离散后相邻帧中模糊或位置变化较大的物体可以使用较多的粒子数目较为分散的初始粒子分布划定待跟踪物体贴近中心部分位置进行跟踪以便能够成功跟踪
