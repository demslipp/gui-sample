import sys

import os
import subprocess
from PyQt5 import QtWidgets, QtGui, QtCore
from PyQt5.QtGui import (QPixmap, QIcon, QFont)
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *

class Gui(QWidget):

    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):

        self.setWindowTitle('Icon')
        self.setWindowIcon(QIcon('wwb.png'))
        hbox = QHBoxLayout(self)
        pixmap = QPixmap("C:\\Users\\mvide\\PycharmProjects\\gui\\webbb1.jpg")
        lbl = QLabel(self)
        lbl.setPixmap(pixmap)

        hbox.addWidget(lbl)
        self.setLayout(hbox)
        self.lbl = QLabel(self)
        self.lbl.setScaledContents(True)

        self.lbl1 = QLabel(self)
        self.lbl1.setStyleSheet('background-color : white; border-radius:10px; color: black; font-style: italic;')
        self.lbl1.move(35,75)
        self.lbl1.resize(500,500)

        btn0 = QPushButton('Предгенерировать работу сетей', self)
        btn0.setGeometry(QtCore.QRect(650, 290, 275, 50))
        btn0.setStyleSheet("""
        QPushButton{
            font-weight: bold;
            border: 2px solid #1DA1F2;
            border-radius: 20px;
            color: #1DA1F2;
            background-color: #fff;
        }
        """ )
        btn0.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        btn0.clicked.connect(self.gen)

        btn1 = QPushButton('Запустить проверку', self)
        btn1.setGeometry(QtCore.QRect(650, 400, 275, 50))
        btn1.setStyleSheet("""
        QPushButton{
            font-weight: bold;
            border: 2px solid #1DA1F2;
            border-radius: 20px;
            color: #1DA1F2;
            background-color: #fff;
        }
        """)
        btn1.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        btn1.clicked.connect(self.train)


        btn2 = QPushButton('Выбрать файл', self)
        btn2.setGeometry(QtCore.QRect(650, 500, 275, 50))
        btn2.setStyleSheet("""
        QPushButton{
            font-weight: bold;
            border: 2px solid #1DA1F2;
            border-radius: 20px;
            color: #1DA1F2;
            background-color: #fff;
        }
        """)
        btn2.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        btn2.clicked.connect(self.showDialog)

        qbtn = QPushButton('Quit', self)
        qbtn.setStyleSheet("color: black; color: orange; background-color: rgb(89, 125, 163); border-radius:20px; border: 2px solid #1DA1F2")
        qbtn.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        qbtn.setToolTip('Press it to Quit')
        qbtn.setIcon(QIcon("wwb.png"))
        qbtn.setIconSize(QSize(30, 30))
        qbtn.resize(qbtn.sizeHint())
        qbtn.clicked.connect(QCoreApplication.instance().quit)
        qbtn.setGeometry(QtCore.QRect(14, 14, 275, 50))

        self.lbl = QLabel(self)

        self.show()
        self.lbl.setFont(QtGui.QFont("Arial", 10, QtGui.QFont.Bold))
        self.show()

        str1 = '                                  Инструкция:\n\n   Внимание! Bыполнение операций может занять\n   некоторое время\n\n 1)Hажмите кнопку "Предгенерировать работу\n    сетей". Этот этап является обязательным\n\n'
        str2 = ' 2)Нажмите кнопку "Запустить проверку", \n    чтобы Ваш пк выполнил предпроверку\n\n'
        str3 = ' 3)Нажмите кнопку "Выбрать файл" и выберите\n    нужный скрипт'
        self.lbl.setText(str1 + str2+ str3)
        self.lbl.setStyleSheet('background-color : rgb(89, 125, 163); border-radius:12px; color: white; font-style: italic;')
        self.lbl.adjustSize()
        self.lbl.setGeometry(557, 14, 445, 260)
        self.move(0, 0)
        self.setWindowTitle('GUI')
        self.show()

    def train(self):
        os.system("C:\\Users\\mvide\\PycharmProjects\\gui\\ss.bat ")
    def gen(self):

        os.system("C:\\Users\\mvide\\PycharmProjects\\gui\\commands.bat ")


    def showDialog(self):

        fname = QFileDialog.getOpenFileName(self, 'Open file', '/home')[0]
        subprocess.call(fname, shell=True)
        print(fname)


if __name__ == '__main__':

    app = QApplication(sys.argv)
    ex = Gui()
    sys.exit(app.exec_())