import sys,os
import threading
import serial
import serial.tools.list_ports
import time


class SerialDetect:
    com = serial.Serial()

    def findSerialPort(self):
        self.portList = list(serial.tools.list_ports.comports())
        return self.portList

    def DetectProccess(self):
        self.com.baudrate = 115200
        self.com.bytesize = 8
        self.com.parity = 'N'
        self.com.stopbits = 1
        self.com.timeout = 0.3
        for i in self.portList:
            port = i[0]
            self.com.port = port
            try:
                self.com.open()
                read = self.com.read(100).decode()
                if read == "":
                    print(str(port)+": read timeout, not received any data");
                else:
                    print(str(port)+": "+read)
                self.com.close()
            except Exception as e:
                print(e)

def main():
    serialDetect = SerialDetect()
    # 遍历所有串口并保存到变量
    serialDetect.findSerialPort()
    print("========================================================")
    print("find ports:")
    print("--------------------------------------------------------")
    for i in serialDetect.portList:
        print(i)
    print("========================================================")
    
    # 一次打开每个串口，等待接收1秒钟，如果接受到了数据，立马结束这个串口的侦测，
    # 并把接收到的数据和串口号添加到一个变量里方便最后显示
    # 继续下一个
    serialDetect.DetectProccess()


    # 显示所有接收到数据的串口





if __name__ == '__main__':
    main()
    input("press any key to exit");