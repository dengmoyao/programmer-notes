## SOLID 原则

SOLID 是五个面向对象编程的重要原则的缩写，由 Robert C. Martin （Bob 大叔） 在 21 世纪初定义。

### 单一职责原则 Single Responsibility Principle

一个类只能有一个职责并且只完成为它设计的功能任务。

好处：

+ 降低耦合性。
+ 代码易于理解和维护。

### 开闭原则 Open Closed Principle

软件实体（类，模块，方法等）应该对扩展开放，对修改封闭。

### 里氏替换原则 Liskov Substitution Principle

程序里的对象都应该可以被它的子类实例替换而不用更改程序。

### 接口隔离原则 Interface Segregation Principle

多个专用的接口比一个通用接口好。

### 依赖倒转原则 Dependence Inversion Principle

高层次的模块不应该依赖于低层次的模块，它们都应该依赖于抽象。抽象不应该依赖于细节。细节应该依赖于抽象。