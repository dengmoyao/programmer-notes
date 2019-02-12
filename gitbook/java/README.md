# Java

## 书单

### 基础

+ [《Java核心技术(卷1):基础知识(原书第10版)》 - 凯 S.霍斯特曼 ](https://www.amazon.cn/dp/B01M06CLQM/ref=pd_bxgy_14_img_2?_encoding=UTF8&psc=1&refRID=KT0NFY9CTMKKNMCN7GNZ)
+ [《Java编程思想(第4版)》 - 埃史尔](https://www.amazon.cn/dp/B0011F7WU4/ref=pd_bxgy_14_img_3?_encoding=UTF8&psc=1&refRID=CNDMVA68EGX7RBFB3Y46)
+ [《Effective Java中文版(第2版)》 - Joshua Bloch](https://www.amazon.cn/dp/B001PTGR52/ref=pd_bxgy_14_img_3?_encoding=UTF8&psc=1&refRID=GTF5J33PK7XMBJN5TMH3)

### 并发

+ [《Java并发编程的艺术》-方腾飞](https://www.amazon.cn/dp/B012QIKPGM/ref=pd_sim_351_2?_encoding=UTF8&psc=1&refRID=BN9AWYWJ8ANKZ80K49SZ)
+ [《Java并发编程实战》 - 盖茨 (Brian Goetz)](https://www.amazon.cn/dp/B0077K9XHW/ref=pd_bxgy_14_img_2?_encoding=UTF8&psc=1&refRID=VFXA1N7FN4D37DAZ7CPD)

### JVM

+ [《深入理解Java虚拟机:JVM高级特性与最佳实践(第2版)》 - 周志明](https://www.amazon.cn/dp/B00D2ID4PK/ref=pd_bxgy_14_2?_encoding=UTF8&psc=1&refRID=MT6DXSTQF8N3V7KQAY59)

### 其他

+ [《写给大忙人看的Java SE 8》 - 霍斯曼 (Horstmann C.S.)](https://www.amazon.cn/dp/B00PYLOFWY/ref=pd_bxgy_14_2?_encoding=UTF8&psc=1&refRID=1PQZATG7DZHFW311Q5WF)

## JVM 相关的常见问题

### 类加载

#### NoClassDefFoundError 和 ClassNotFoundException 区别？

NoClassDefFoundError 表示该类在编译阶段还可以找到，但是在运行Java应用的时候招不到了。 ClassNotFoundException 和编译器没有什么关系，在显示的使用类名称去加载类时，便有可能抛出该受检异常。主要涉及到的方法有： Class.forName， ClassLoader.findSystemClass 和 ClassLoader.loadClass。