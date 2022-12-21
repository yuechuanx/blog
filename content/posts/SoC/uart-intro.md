---
title: "UART 通信协议"
slug: uart-intro
date: 2022-12-21 17:28:00
---

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-intro-cover.png)

# 什么是 UART

UART（Universal asynchronous receiver-transmitter）通用异步接收器/发送器，也称为串口通讯。

**UART 属于异步通讯**，这意味着没有时钟信号，取而代之的是在**数据帧中添加开始和停止位**。这些位定义了数据帧的开始和结束，因此接收 UART 知道何时读取这些数据。 

在 UART 通信中，两个 UART 直接相互通信。发送 UART 将控制设备（如 CPU）的并行数据转换为串行形式，以串行方式将其发送到接收 UART。只需要两条线即可在两个 UART 之间传输数据，数据从发送 UART 的 Tx 引脚流到接收 UART 的 Rx 引脚：

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-to-uart.png)

当接收 UART 检测到起始位时，它将以特定**波特率**的频率读取。**波特率是数据传输速度的度量**，以每秒比特数（bps）表示。两个 UART 必须以大约相同的波特率工作，发送和接收 UART 之间的波特率只能相差约 10％。

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-spec.png)

# 工作原理

## 信号线

- TX  transmitter 发送信号线
- RX  receiver 接收信号线

## 信号同步设置

在发送端和接收端没有时钟同步的情况下，无法控制何时发送数据，也无法保证双发按照完全相同的速度接收数据。因此，双方以不同的速度进行数据接收和发送，就会出现问题。

解决判断数据何时发送的问题的方式是，UART 为每个字节添加额外的起始位和停止位，从而接收端可以识别数据的发送和停止。

解决数据按相同的速度，需要提前约定好传输速度，设置相同的波特率。

传输速率如果有微小差异不是问题，因为接收器会在每个字节的开头重新同步。相应的协议如下图所示；

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-send-data.png)

> 如果您注意到上图中的 11001010 不等于 0x53。这是一个细节。串口协议通常会首先发送最低有效位，因此最小位在最左边 LSB。低四位字节实际上是 0011 = 0x3，高四位字节是 0101 = 0x5。

异步串行工作得很好，但是在每个字节发送的时候都需要额外的起始位和停止位以及在发送和接收数据所需的复杂硬件方面都有很多开销。

如果接收端和发送端设置的速度都不一致，那么接收到的数据将是垃圾（乱码）。

## 数据帧格式

UART 数据包含有 1 个起始位，5 至 9 个数据位（取决于 UART），一个可选的奇偶校验位以及 1 个或 2 个停止位：

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-data-frame.png)

**起始位：**
UART 数据传输线通常在不传输数据时保持在高电压电平。开始传输时发送 UART 在一个时钟周期内将传输线从高电平拉低到低电平，当接收 UART 检测到高电压到低电压转换时，它开始以波特率的频率读取数据帧中的位。

**数据帧：**
数据帧内包含正在传输的实际数据。如果使用奇偶校验位，则可以是 5 位，最多 8 位。如果不使用奇偶校验位，则数据帧的长度可以为 9 位。 

**校验位：**
奇偶校验位是接收 UART 判断传输期间是否有任何数据更改的方式。接收 UART 读取数据帧后，它将对值为 1 的位数进行计数，并检查总数是偶数还是奇数，是否与数据相匹配。

**停止位：**
为了向数据包的结尾发出信号，发送 UART 将数据传输线从低电压驱动到高电压至少持续两位时间。


## 传输过程

1. 发送 UART 从数据总线并行接收数据： 

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-trans-data-step-1.png)

2. 发送 UART 将起始位，奇偶校验位和停止位添加到数据帧：

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-trans-data-step-2.png)

3. 整个数据包从发送 UART 串行发送到接收 UART。接收 UART 以预先配置的波特率对数据线进行采样：

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-trans-data-step-3.png)

4. 接收 UART 丢弃数据帧中的起始位，奇偶校验位和停止位：

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-trans-data-step-4.png)

5. 接收 UART 将串行数据转换回并行数据，并将其传输到接收端的数据总线：  

![](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/imgs/uart-trans-data-step-5.png)


# 优缺点

## 优点

-   仅使用两根电线
-   无需时钟信号
-   具有奇偶校验位以允许进行错误检查
-   只要双方都设置好数据包的结构    
-   有据可查并得到广泛使用的方法

## 缺点

-   数据帧的大小最大为 9 位
-   不支持多个从属系统或多个主系统
-   每个 UART 的波特率必须在彼此的 10％之内

---

# 参考

- [带你快速对比SPI、UART、I2C通信的区别与应用！-面包板社区](https://www.eet-china.com/mp/a80724.html)