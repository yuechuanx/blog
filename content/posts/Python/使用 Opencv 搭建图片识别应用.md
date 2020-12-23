---
title: "使用 Opencv 搭建图片识别应用"
slug: object-detect-using-opencv
date: 2020-12-23T16:12:02+08:00
draft: false
tags:  
- python
- opencv
---

> 一个简单的识别图卡的任务。可以基本涵盖 opencv tutorial 里面使用的东西。

OpenCV 的文档详实丰富，如果觉得阅读官方文档比较吃力， [OpenCV 4.0 中文文档](https://opencv.apachecn.org/#/) 会对你非常有帮助。

## 一个简单的任务情景

我们有一些图卡需要被识别，在这里，我们稍微简单化一下情景：

有一面纯色的背景墙，图卡就像挂照片一样挂置在墙上，有一个 camera 对准这面墙壁， 那么现在我们如何识别出图卡的区域，并且裁剪出来。

## 图片处理流程

明晰了这个简单的场景之后，我们可以建立起来一个基本的图片处理的框架。

这个场景的主要的功能其实是图像裁剪。

1. 读入 camera 的视频帧

   ```python
   # 读入一张图片
   img = cv.imread('path/to/img')
   
   
   # 读入一帧
   cap = cv.VideoCapture(0)
   ret, frame = cap.read()
   if ret:
           # handle frame
   ```

2. 简化运算量，转为灰度图像。

   `cv.cvtColor(img, cv.COLOR_BGR2GRAY)`

   >  大多数的图像处理的第一步就是把色彩转为灰度，因为降低通道数可以有效减少运算量，而且灰度图像中也保存了完整的梯度信息，而梯度信息对后面处理轮廓至关重要。降低噪声，这里有许多中滤波方式（高斯滤波，中值滤波

3. 边缘检测

   边缘检测实际是计算图像的梯度信息，常见的处理方式有 canny，sobel 算子。

   Sobel 算子后是灰度图像，需要再进行阈值处理得到二值化图像

   Canny 算子后能够直接得到二值化图像。一般情况下推荐使用canny 算子。

   ```python
   def sobel_edges(input):
       gradX = cv.Sobel(input, ddepth=cv.CV_32F, dx=1, dy=0, ksize=-1)
       gradY = cv.Sobel(input, ddepth=cv.CV_32F, dx=0, dy=1, ksize=-1)
       # subtract the y-gradient from the x-gradient
       gradient = cv.subtract(gradX, gradY)
       gradient = cv.convertScaleAbs(gradient)
       blurred = cv.blur(gradient, (5, 5))
   
       # cv.threshhold 与 cv.adaptiveThresholud 区别
       # 全局阈值与自适应阈值
       _, thresh = cv.threshold(blurred, 127, 255, cv.THRESH_BINARY)
       # thresh = cv.adaptiveThreshold(
       #     input, 255, cv.ADAPTIVE_THRESH_MEAN_C, cv.THRESH_BINARY, 11, 2)
   
       return thresh
   
   
   def canny_edges(input):
       canny = cv.Canny(input, 0, 255)
       return canny
   ```

   

4. 形态转换。上面一步得到了边缘信息，有时边缘信息会比较不稳定，受到光线等影响，这里使用闭运算，使得线条更加膨胀（稳定）

   ```python
   def handle_edges(input):
       # 膨胀和腐蚀操作的核函数 MORPH_RECT | MORH_ELLIPSE | MORPH_CROSS
       # 分别代表 矩形 | 椭圆型 | 交叉型
       element1 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (5, 5))
       element2 = cv.getStructuringElement(cv.MORPH_RECT, (9, 7))
       kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (9, 9))
       closed = cv.morphologyEx(input, cv.MORPH_CLOSE, kernel, iterations=3)
       open = cv.morphologyEx(closed, cv.MORPH_OPEN, kernel)
       # 膨胀一次，让轮廓突出
       dilation = cv.dilate(closed, element2, iterations=1)
       # 腐蚀一次，去掉细节
       erosion = cv.erode(dilation, element1, iterations=1)
       # 再次膨胀，让轮廓明显一些
       dilation2 = cv.dilate(erosion, element2, iterations=1)
   
       return closed
   ```

   

5. 获取最大轮廓

   ```python
   def get_edge_max_contour(input):
       contours, hierarchy = cv.findContours(
           input,
           cv.RETR_TREE,  # RETR_TREE | RETR_LIST | RETR_EXTERNAL
           cv.CHAIN_APPROX_SIMPLE)
       filtered_contours = [
           cnt for cnt in contours
           if cv.contourArea(cnt) > cv.arcLength(cnt, True)
       ]
   
       if len(filtered_contours) < 2:
           return False
   
       sorted_contours = sorted(filtered_contours,
                                key=cv.contourArea,
                                reverse=True)
       max_contour = sorted_contours[1]
       return max_contour
   ```

   

6. 填充轮廓，并建遮罩层

   ```python
   def get_mask(input, contour):
       mask = np.zeros(input.shape[:2], np.uint8)
       cv.drawContours(mask, contour, -1, 255, -1)
       mask = cv.GaussianBlur(mask, (5, 5), 0)
       masked = cv.bitwise_and(input.copy(), input.copy(), mask=mask)
   
       return masked
   
   canny_mask = cv.drawContours(canny, [canny_max_contour], -1, 255, cv.FILLED)                            
   ```

   

7. 形态学转换，腐蚀掉噪点，进行开运算

   ```python
   def handle_area(input):
       kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (9, 9))
       closed = cv.morphologyEx(input, cv.MORPH_OPEN, kernel, iterations=3)
       return closed
   ```

   

8. 获取遮罩层最大轮廓

   ```python
   def get_area_max_contour(input):
       contours, hierarchy = cv.findContours(
           input,
           cv.RETR_EXTERNAL,  # RETR_TREE | RETR_LIST | RETR_EXTERNAL
           cv.CHAIN_APPROX_SIMPLE)
       filtered_contours = [
           cnt for cnt in contours
           if cv.contourArea(cnt) > cv.arcLength(cnt, True)
       ]
   
       if len(filtered_contours) < 1:
           return False
   
       sorted_contours = sorted(filtered_contours,
                                key=cv.contourArea,
                                reverse=True)
       max_contour = sorted_contours[0]
       return max_contour
   
   ```

   

9. 绘制方框，以及其他一些信息在图像上

现在我们获得的是当前图像上，面积最大的轮廓。

![cv-process](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/cv-process.svg)

**轮廓处理的一般流程：**

需要注意的是cv2.findContours()函数接受的参数为二值图，即黑白的（不是灰度图），所以读取的图像要先转成灰度的，再转成二值图。，参见4、5两行。第六行是检测轮廓，第七行是绘制轮廓。

```python
import cv2

img = cv2.imread('D:\\test\\contour.jpg')
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
ret, binary = cv2.threshold(gray,127,255,cv2.THRESH_BINARY)
contours, hierarchy = cv2.findContours(binary,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
cv2.drawContours(img,contours,-1,(0,0,255),3)
cv2.imshow("img", img)
cv2.waitKey(0)
```

**OpenCV中轮廓等级的表示:**

如果我们打印出cv2.findContours()函数的返回值hierarchy，会发现它是一个包含4个值的数组：[Next, Previous, First Child, Parent] - Next: 与当前轮廓处于同一层级的下一条轮廓，没有为-1。 - Previous: 与当前轮廓处于同一层级的上一条轮廓，没有为-1。 - Firtst Child: 当前轮廓的第一条子轮廓，没有为-1。 - Parent: 当前轮廓的父轮廓，没有为-1。

**轮廓的四种寻找方式：** 

- RETR_LIST：所有轮廓属于同一层级 
- RETR_TREE: 完整建立轮廓的各属性 
- RETR_EXTERNAL: 只寻找最高层级的轮廓 
- RETR_CCOMP: 所有轮廓分2个层级，不是外界就是最里层

**轮廓的性质与特征**

计算物体的周长、面积、质心、最小外接矩形等

OpenCV函数：cv2.contourArea(), cv2.arcLength(), cv2.approxPolyDP()

**寻找等高线的时候，为何我推荐使用边缘检测而非阈值处理作为二值图？**

（具体见：https://zhuanlan.zhihu.com/p/38739563）

我参考的博客里面使用阈值函数cv2.threshold()处理图片得到二值图，不过我建议：在性能允许的情况下，当我们需要框出的是目标的轮廓，那么使用cv2.Canny() 更好，理由：

提取边缘与阈值处理不同，边缘提取可以识别图片中目标的形状、轮廓，而不是简单的区分出图片中的高光与暗调，可以简单地提图片中颜色分布位于中间调的上目标；

使用Canny边缘检测，提取结果的白点数量更少，对等高线检测的混淆因素减少（猜测）；

我对比了一些边缘检测算法，Canny边缘检测效果好（虽然对性能要求高）；

**如果利用边沿检测(或二值图)—>轮廓—>掩码—>抠图**

(见： [OpenCV 中的轮廓应用](https://zhuanlan.zhihu.com/p/77783347) 中第二个应用,有python代码)

步骤：

- 使用 Canny 边缘检测，得到二值图，然后对其进行膨胀和腐蚀操作，方便稍后提取轮廓
- 先使用 cv2.findContours 获取所有轮廓， 再根据轮廓面积进行降序排列，并获取到面积最大的轮廓，即图中人物的轮廓 。
- 接下来通过 cv2.arcLength 得到轮廓周长，并将周长的0.1%作为近似轮廓的精度。然后再使用 cv2.approxPolyDP 得到近似轮廓。
- 然后 根据近似轮廓建立一个轮廓的掩码mask，在其上绘制出最大轮廓对应的填充多边形，用于下一步抠图 。
- 对掩码进行高斯模糊用于平滑边缘，可以消除锯齿。
- 最后一步就是将掩码和原图像进行求与运算，即得到最终结果。



## 完整代码

```python
# encoding:utf-8
from glob import glob
import time

import cv2 as cv
import stackprinter as sp
import numpy as np
import matplotlib.pyplot as plt

TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S'
TIMESTAMP_FILE_FORMAT = '%m%d_%H%M_%S'
CAPTURE_TIMES_PER_TASK = 5


def compare_img_hist(img1, img2):
    img1 = cv.imread(img1)
    img2 = cv.imread(img2)
    # Get the histogram data of image 1, then using normalize the picture for better compare
    img1_hist = cv.calcHist([img1], [1], None, [256], [0, 256])
    img1_hist = cv.normalize(img1_hist, img1_hist, 0, 1, cv.NORM_MINMAX, -1)

    img2_hist = cv.calcHist([img2], [1], None, [256], [0, 256])
    img2_hist = cv.normalize(img2_hist, img2_hist, 0, 1, cv.NORM_MINMAX, -1)
    similarity = cv.compareHist(img1_hist, img2_hist, 0)
    return similarity


def denoising(input):
    # 高斯平滑 去噪
    gaussian = cv.GaussianBlur(input, (3, 3), 0, 0, cv.BORDER_DEFAULT)
    # 中值滤波
    median = cv.medianBlur(gaussian, 5)

    return gaussian, median


def get_edges(input, edge_type='sobel'):
    if edge_type == 'sobel':
        gradX = cv.Sobel(input, ddepth=cv.CV_32F, dx=1, dy=0, ksize=-1)
        gradY = cv.Sobel(input, ddepth=cv.CV_32F, dx=0, dy=1, ksize=-1)
        # subtract the y-gradient from the x-gradient
        gradient = cv.subtract(gradX, gradY)
        gradient = cv.convertScaleAbs(gradient)
        blurred = cv.blur(gradient, (5, 5))
        # cv.threshhold 与 cv.adaptiveThresholud 区别
        # 全局阈值与自适应阈值
        _, thresh = cv.threshold(blurred, 127, 255, cv.THRESH_BINARY)
        # thresh = cv.adaptiveThreshold(
        #     input, 255, cv.ADAPTIVE_THRESH_MEAN_C, cv.THRESH_BINARY, 11, 2)
        return thresh
    else:
        canny = cv.Canny(input, 0, 255)
        return canny


def sobel_edges(input):
    gradX = cv.Sobel(input, ddepth=cv.CV_32F, dx=1, dy=0, ksize=-1)
    gradY = cv.Sobel(input, ddepth=cv.CV_32F, dx=0, dy=1, ksize=-1)
    # subtract the y-gradient from the x-gradient
    gradient = cv.subtract(gradX, gradY)
    gradient = cv.convertScaleAbs(gradient)
    blurred = cv.blur(gradient, (5, 5))

    # cv.threshhold 与 cv.adaptiveThresholud 区别
    # 全局阈值与自适应阈值
    _, thresh = cv.threshold(blurred, 127, 255, cv.THRESH_BINARY)
    # thresh = cv.adaptiveThreshold(
    #     input, 255, cv.ADAPTIVE_THRESH_MEAN_C, cv.THRESH_BINARY, 11, 2)

    return thresh


def canny_edges(input):
    canny = cv.Canny(input, 0, 255)
    return canny


def get_edge_max_contour(input):
    contours, hierarchy = cv.findContours(
        input,
        cv.RETR_TREE,  # RETR_TREE | RETR_LIST | RETR_EXTERNAL
        cv.CHAIN_APPROX_SIMPLE)
    filtered_contours = [
        cnt for cnt in contours
        if cv.contourArea(cnt) > cv.arcLength(cnt, True)
    ]

    if len(filtered_contours) < 2:
        return False

    sorted_contours = sorted(filtered_contours,
                             key=cv.contourArea,
                             reverse=True)
    max_contour = sorted_contours[1]
    return max_contour


def get_area_max_contour(input):
    contours, hierarchy = cv.findContours(
        input,
        cv.RETR_EXTERNAL,  # RETR_TREE | RETR_LIST | RETR_EXTERNAL
        cv.CHAIN_APPROX_SIMPLE)
    filtered_contours = [
        cnt for cnt in contours
        if cv.contourArea(cnt) > cv.arcLength(cnt, True)
    ]

    if len(filtered_contours) < 1:
        return False

    sorted_contours = sorted(filtered_contours,
                             key=cv.contourArea,
                             reverse=True)
    max_contour = sorted_contours[0]
    return max_contour


def get_mask(input, contour):
    mask = np.zeros(input.shape[:2], np.uint8)
    cv.drawContours(mask, contour, -1, 255, -1)
    mask = cv.GaussianBlur(mask, (5, 5), 0)
    masked = cv.bitwise_and(input.copy(), input.copy(), mask=mask)

    return masked


def handle_edges(input):
    # 膨胀和腐蚀操作的核函数 MORPH_RECT | MORH_ELLIPSE | MORPH_CROSS
    # 分别代表 矩形 | 椭圆型 | 交叉型
    element1 = cv.getStructuringElement(cv.MORPH_ELLIPSE, (5, 5))
    element2 = cv.getStructuringElement(cv.MORPH_RECT, (9, 7))
    kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (9, 9))
    closed = cv.morphologyEx(input, cv.MORPH_CLOSE, kernel, iterations=3)
    open = cv.morphologyEx(closed, cv.MORPH_OPEN, kernel)
    # 膨胀一次，让轮廓突出
    dilation = cv.dilate(closed, element2, iterations=1)
    # 腐蚀一次，去掉细节
    erosion = cv.erode(dilation, element1, iterations=1)
    # 再次膨胀，让轮廓明显一些
    dilation2 = cv.dilate(erosion, element2, iterations=1)

    return closed


def handle_area(input):
    kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (9, 9))
    closed = cv.morphologyEx(input, cv.MORPH_OPEN, kernel, iterations=3)
    return closed


def handle_mask(input):
    # 建立一个椭圆核函数
    kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (25, 25))
    # kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3))
    # 执行图像形态学, 细节直接查文档，很简单
    closed = cv.morphologyEx(input, cv.MORPH_CLOSE, kernel, iterations=3)
    # closed = cv.erode(closed, None, iterations=3)
    # closed = cv.dilate(closed, None, iterations=3)
    return closed


def calc_osd(input, contour):
    # epsilon = cv.arcLength(contour, True) * 0.01
    # approx = cv.approxPolyDP(contour, epsilon, True)
    area = cv.contourArea(contour)

    M = cv.moments(contour)
    cx = int(M['m10'] / M['m00'])
    cy = int(M['m01'] / M['m00'])
    rx, ry, rw, rh = cv.boundingRect(contour)

    h, w = input.shape[:2]
    offset = (w // 2 - cx, h // 2 - cy)
    angle = 0
    area_ratio = round(area / input.size * 100, 4)
    # rect = cv.minAreaRect(approx)
    # box = np.int0(cv.boxPoints(rect))
    # print('center point: ', (round(rect_center_x), round(rect_center_y)))

    if area_ratio < 10:
        return input

    # 绘制图卡区域框
    dst = cv.rectangle(input, (rx, ry), (rx + rw, ry + rh),
                       (0, 255, 0), 2)
    # 绘制图卡内容框
    dst = cv.drawContours(dst, [contour], 0, (255, 0, 0), 3)
    osd_timestamp = time.strftime(TIMESTAMP_FORMAT,
                                  time.localtime())
    dst = draw_osd(dst, area_ratio, offset, angle, osd_timestamp)
    dst = draw_crossline(dst, (w // 2, h // 2), 40, (0, 255, 0))
    dst = draw_crossline(dst, (cx, cy), 40, (255, 0, 0))

    return dst


def img2(imgs, h=1080, w=1920):
    for i, img in enumerate(imgs):
        imgs[i] = np.array(img[:h:2, :w:2])
    img = np.concatenate(imgs[:2], 1)
    return img


def img4(imgs, h=1080, w=1920):
    for i, img in enumerate(imgs):
        imgs[i] = img[:h:2, :w:2]
    row1 = np.concatenate(imgs[:2], 1)
    row2 = np.concatenate(imgs[2:4], 1)
    img = np.concatenate([row1, row2], 0)

    return img


def img6(imgs, h=1080, w=1920):
    for i, img in enumerate(imgs):
        imgs[i] = img[:h:3, :w:3]
    row1 = np.concatenate(imgs[:3], 1)
    row2 = np.concatenate(imgs[3:6], 1)
    img = np.concatenate([row1, row2], 0)

    return img


def img9(imgs, h=1080, w=1920):
    for i, img in enumerate(imgs):
        imgs[i] = img[:h:3, :w:3]
    row1 = np.concatenate(imgs[:3], 1)
    row2 = np.concatenate(imgs[3:6], 1)
    row3 = np.concatenate(imgs[6:], 1)
    img = np.concatenate([row1, row2, row3], 0)

    return img


def draw_osd(img, ratio, offset, angle, timestamp):
    x, y = offset
    font = cv.FONT_HERSHEY_SIMPLEX
    text = f'area ratio: {ratio} %\n' \
        f'offset x: {x} \n' \
        f'offset y: {y} \n' \
        f'angle: {angle} \n' \
        f'time: {timestamp}'
    y0, dy = 50, 40
    dst = None
    for i, line in enumerate(text.split('\n')):
        y = y0 + i * dy
        dst = cv.putText(img, line, (50, y), font, 1, (0, 255, 0), 2)

    return dst


def draw_osd_fps(img, fps):
    dst = cv.putText(img, f'fps: {fps}', (50, 200), cv.FONT_HERSHEY_SIMPLEX, 1,
                     (0, 255, 0), 2)
    return dst


def draw_crossline(img, pt, length, color):
    x, y = pt
    pt_x1 = x - length, y
    pt_x2 = x + length, y
    pt_y1 = x, y - length
    pt_y2 = x, y + length
    dst = cv.line(img, pt_x1, pt_x2, color, 5)
    dst = cv.line(img, pt_y1, pt_y2, color, 5)

    return dst


def plot_all(imgs):
    titles = [
        'Source Image', 'Gray Image', 'gaussian Image', 'median Image',
        'Sobel Image', 'Binary Image', 'dilation Image', 'Mask', 'After Mask'
    ]

    for i in range(9):
        plt.subplot(3, 3, i + 1), plt.imshow(imgs[i], 'gray')
        plt.title(titles[i])
        plt.xticks([]), plt.yticks([])
    plt.show()


def save_capture(input, filename):
    cv.imwrite(filename, input)


def detect(input, task=None):
    # 根据input类型确认是frame还是图像
    if isinstance(input, str):
        input = cv.imread(input)

    # 转换色彩空间, opencv默认的imread是以BGR的方式进行存储的
    input = cv.cvtColor(input, cv.COLOR_BGR2RGB)

    gray = cv.cvtColor(input, cv.COLOR_BGR2GRAY)
    gaussian, median = denoising(gray)

    # canny 边缘检测
    canny = canny_edges(gaussian)
    # 边缘处理, 根据 开/闭 操作去除游离线条
    canny_closed = handle_edges(canny)
    canny_max_contour = get_edge_max_contour(canny_closed)
    if canny_max_contour is False:
        return input
    canny_mask = cv.drawContours(canny, [canny_max_contour], -1,
                                 255, cv.FILLED)
    canny_mask = handle_area(canny_mask)
    canny_max_contour = get_area_max_contour(canny_mask)
    if canny_max_contour is False:
        return input
    dst = calc_osd(input, canny_max_contour)
    dst = cv.resize(dst, (960, 540))
    return dst

    sobel = sobel_edges(gaussian)
    sobel_closed = handle_edges(sobel)
    sobel_max_contour = get_edge_max_contour(sobel_closed)
    if sobel_max_contour is False:
        return input
    sobel_mask = cv.drawContours(sobel, [sobel_max_contour], -1,
                                 255, cv.FILLED)
    sobel_mask = handle_mask(sobel_mask)
    sobel_max_contour = get_area_max_contour(sobel_mask)

    mask_compare = [canny_mask, sobel_mask]
    # closed_compare = [canny_closed, sobel_closed]
    # area_filled_compare = [canny_mask, sobel_mask]

    return sobel_mask


def start_detect():
    cap = cv.VideoCapture(0)
    last = cv.getTickCount()
    while True:
        ret, frame = cap.read()
        if ret:
            dst = detect(frame)
            # now = cv.getTickFrequency()
            # time = (now - last) / cv.getTickFrequency()
            # dst = draw_osd_fps(dst, round(1 / time, 2))
            try:
                cv.imshow('dst', dst)
            except:
                sp.show(style='darkbg', source_lines=4)
            # last = now
        if cv.waitKey(1) & 0xFF == ord('q'):
            cv.destroyAllWindows()
            break
        if cv.waitKey(1) & 0xFF == ord('s') and ret:
            cv.imwrite('dst', frame)
            continue
    cap.release()


if __name__ == "__main__":
    # images = glob('classify/charts/*')
    # images = glob('images/stepchart/*')
    # images = [
    #     # 'images/sfr/4K_1M.bmp',
    #     # 'images/sfr/1080P_2M.png',
    #     'images/sfr/100lux.png',
    # ]

    # for image in images:
    # detect_chart_type(image)
    # detect(image)

    start_detect()

```



## 更进一步的任务，如何识别图像类别

现在我们已经裁剪出了我们感兴趣的图卡内容，这里需要做更进一步的处理，比如对于图卡内容的分类。

假设图卡出现的物体都是已知的，而且我们有所有的图卡图片，那么要改如何建立判断呢？

一个简单的思路是，既然我们已经有了所有图片的信息，那么选取一张拍得比较标准的作为参照，其他的图片和它进行比较，判断相似度，相似度最高的就是最有可能的分类。

这里引入一些图像相似度算法的内容：



## 相关资料

文档

- [OpenCV 4.0 中文文档](https://opencv.apachecn.org/#/)
- [OpenCV 官方 Tutorial](https://docs.opencv.org/master/d9/df8/tutorial_root.html)

图像梯度特征：轮廓

[边缘检测，框出物体的轮廓(使用opencv-python)](https://zhuanlan.zhihu.com/p/38739563)

[OpenCV 中的轮廓应用](https://zhuanlan.zhihu.com/p/77783347)

[感兴趣区域的移动物体检测，框出移动物体的轮廓 (固定摄像头, opencv-python)](https://zhuanlan.zhihu.com/p/38720146)

[OpenCV图像处理-轮廓和轮廓特征](https://zhuanlan.zhihu.com/p/61328775)

图像二值化

[OpenCV—图像二值化](https://www.cnblogs.com/ssyfj/p/9272615.html)

[图像二值化,阈值处理(十)](https://www.cnblogs.com/angle6-liu/p/10673585.html)

相关概念：

[数学形态学操作](https://zhuanlan.zhihu.com/p/67566843)

[OpenCV图像处理|1.11 形态学操作](https://zhuanlan.zhihu.com/p/40489282)

[图像卷积、边缘提取和滤波去噪](https://zhuanlan.zhihu.com/p/67197912)

[图像边缘检测 - 图像梯度与Canny算子](https://zhuanlan.zhihu.com/p/64350303)

[OpenCV图像处理-Cany、Sobel、Laplacian算子和图像金字塔](https://zhuanlan.zhihu.com/p/61070886)

[OpenCV—python 图像显著性检测算法—HC/RC/LC/FT](https://blog.csdn.net/wsp_1138886114/article/details/102560328?utm_medium=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-BlogCommendFromMachineLearnPai2-1.nonecase#23__FT_319)
