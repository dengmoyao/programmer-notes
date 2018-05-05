# 问题

### Spring

#### 谈谈Spring框架，以及使用Spring带来的好处

Spring是一个开源框架，用于简化Java企业级应用开发。提供了依赖注入，面向切面编程，事务管理，Web应用，数据访问，消息以及测试等功能。

使用Spring主要是可以简化Java应用开发，比如

+ Spring提供IoC，可以更方便实现松散耦合；
+ Spring支持面向切面编程，这样能把应用业务逻辑和系统级别的服务分开，让开发者聚焦业务；

#### 什么是控制反转，什么是依赖注入，什么是Spring IoC 容器

控制反转就是对组件对象控制权的转移，从程序代码本身转移到了外部容器，通过容器来实现对象组件的装配和管理。实现控制反转的手段是依赖注入，即组件所依赖的对象不再自己new，而是在运行期间由容器根据配置文件描述将依赖关系注入到组件中。

Spring IOC容器就是实现依赖注入的容器，负责创建对象，管理对象，装配对象，并且管理这些对象的整个生命周期。

#### BeanFactory 和 ApplicationContext 有什么区别，ApplicationContext有哪些常用实现类

BeanFactory 是Spring 中 Bean工厂的顶级接口，具有bean定义、bean关联关系的设置，根据请求分发bean的功能；

ApplicationContext 继承了 BeanFactory，在 BeanFactory 的基础上增加一些功能，主要包括：

+ 提供国际化的消息访问
+ 统一的资源文件读取方式
+ 事件传播

ApplicationContext 几个常用的实现类：

+ ClassPathXmlApplicationContext: 类路径加载
+ FileSystemXmlApplicationContext: 文件系统路径加载
+ AnnotationConfigApplicationContext: 用于基于注解的配置
+ WebApplicationContext: 专门为web应用准备的，从相对于Web根目录的路径中装载配置文件完成初始化。

#### Spring有几种配置方式

将Spring配置到应用开发中有以下三种方式(不冲突，可搭配使用)：

+ 基于XML的配置
+ 基于注解的配置
+ 基于Java的配置

#### 依赖注入的方式有哪些，怎么选择

+ 构造器依赖注入
+ Setter注入

用构造器参数实现强制依赖，setter方法实现可选依赖。

#### Spring Bean 的生命周期

简单来说，Bean的生命周期就是Bean从初始化到被使用，再到被销毁的过程。

Bean的生命周期由两组回调（call back）方法组成。

+ 初始化之后调用的回调方法。
+ 销毁之前调用的回调方法。

Spring框架提供了以下四种方式来管理bean的生命周期事件：

+ InitializingBean和DisposableBean回调接口
+ 针对特殊行为的其他Aware接口，(BeanNameAware,BeanClassLoaderAware, BeanFactoryAware)
+ Bean配置文件中的自定义的 init()方法和destroy()方法
+ @PostConstruct和@PreDestroy注解方式

#### Spring Bean 的作用域是什么， 有哪些

在Spring容器中是指其创建的Bean对象相对于其他Bean对象的请求可见范围，Spring一共提供了5种作用域类型：

+ singleton：这种bean范围是默认的，这种范围确保不管接受到多少个请求，每个容器中只有一个bean的实例，单例的模式
+ prototype：原形范围与单例范围相反，为每一个bean请求提供一个实例
+ request：每次http请求都会创建一个bean，该作用域仅在基于web的ApplicationContext情形下有效
+ session：在一个HTTP Session中，一个bean定义对应一个实例。该作用域仅在基于web的ApplicationContext情形下有效
+ global-session：在一个全局的HTTP Session中，一个bean定义对应一个实例。该作用域仅在基于web的ApplicationContext情形下有效。

#### 自动装配模式的区别

在Spring框架中共有5种自动装配：

+ no: 默认的方式是不进行自动装配，通过显式设置ref 属性来进行装配
+ byName: 通过参数名 自动装配
+ byType: 通过参数类型自动装配
+ constructor: 这个方式类似于byType， 但是要提供给构造器参数
+ autodetect：首先尝试使用constructor来自动装配，如果无法工作，则使用byType方式

#### 解释一下AOP

即面向切面编程， 是对OOP的一种补充，主要用于处理在模块化编程中一些具有横切性质的服务，常用于安全控制，日志输出，事务管理等。

AOP 的优点是能够把遍布应用各种的系统服务功能(比如日志，安全等)分离出来，这样核心的业务模块完全不需要了解涉及系统服务所带来的复杂性。例如，在对Controller收到的请求进行安全控制或者日志记录的时候，就可以通过编写一个切面，并声明切面生效位置，而不用在每个业务方法中添加代码去实现对应功能了。

Spring AOP 实现的原理是动态代理。Spring AOP提供了对JDK动态代理和CGLib动态代理的支持。

#### JDK动态代理和CGLib动态代理区别

JDK动态代理只能为接口创建动态代理实例，而不能对类创建动态代理。CGLib能够对类创建动态代理。

JDK动态代理是由Java内部的反射机制来实现的。CGLib动态代理需要依赖ASM包，把被代理对象类的class文件加载进来，修改其字节码生成子类。

JDK动态代理使用方法：

TODO

CGLib使用方法：

TODO