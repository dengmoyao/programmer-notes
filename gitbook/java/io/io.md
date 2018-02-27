# Java I/O

## 基本架构

根据数据格式和传输方式，Java的I/O操作类大概分为如下四组：

+ 基于字节操作的I/O接口：InputStream和OutputStream
+ 基于字符操作的I/O接口：Writer和Reader
+ 基于磁盘操作的I/O接口：File
+ 基于网络操作的I/O接口：Socket

### 字节操作

__类图__

![](./img/InputStream.png)

![](./img/OutputStream.png)

Java I/O使用了[装饰器模式](../../concept/designPattern/Decorator.md)来实现。以InputStream为例，InputStream是抽象组件，FileInputStream是InputStream的子类，是具体组件，提供了字节流的输入操作。FilterInputStream是抽象装饰者，装饰者用于装饰组件，为组件提供额外的功能。


### 字符操作

不管是磁盘还是网络传输，最小的存储单元都是字节，而不是字符，所以 I/O 操作的都是字节而不是字符。但是在程序中操作的数据通常是字符形式，因此需要提供对字符进行操作的方法。

__类图__

![](./img/Writer.png)

Writer类提供公共抽象方法`write(char cbuf[], int off, int len)`

![](./img/Reader.png)

Reader类提供公共抽象方法`int read(char cbuf[], int off, int len)`

### 字符与字节转换

字节和字符的转换过程由InputStreamReader和OutputStreamWriter完成。InputStreamReader 实现从文本文件的字节流解码成字符流；OutputStreamWriter 实现字符流编码成为文本文件的字节流。它们都继承自 Reader 和 Writer。

__类图__

![](./img/InputStreamReader.jpg)

这里使用了[适配器模式](../../concept/designPattern/Adapter.md)，适配器就是InputStreamReader，源角色是InputStream代表的实例对象，目标接口就是Reader类。

![](./img/OutputStreamWriter.jpg)

## 磁盘I/O

### File

文件是操作系统和磁盘驱动器交互的一个最小单元，Java中的File类可以用于表示文件和目录，但是它不代表一个真实存在的文件对象。在创建一个 FileInputStream 对象时，会创建一个 FileDescriptor 对象，真正代表一个存在的文件对象的描述，通过这个对象可以直接控制这个磁盘文件。

### 序列化

序列化就是将一个对象转换成字节序列，方便存储和传输。

序列化的类需要实现 Serializable 接口，它只是一个标准，没有任何方法需要实现。

`transient` 关键字可以使一些属性不会被序列化。


## 常见问题

### Java I/O 中的设计模式

+ 装饰器模式
+ 适配器模式

适配器模式和装饰器模式差别： 

+ 适配器模式是将一个接口转变成另一个接口，它的目的是通过改变接口来达到重复使用的目的；
+ 装饰器模式是不改变被装饰对象的接口，只是增强原有对象的功能。

## 参考资料

[深入分析 Java I/O 的工作机制](https://www.ibm.com/developerworks/cn/java/j-lo-javaio/)
