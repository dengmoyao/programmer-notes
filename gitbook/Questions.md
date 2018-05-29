# 问题

## Spring

### Spring 基础

#### 谈谈Spring框架，以及使用Spring带来的好处

Spring是一个开源框架，用于简化Java企业级应用开发。提供了依赖注入，面向切面编程，事务管理，Web应用，数据访问，消息以及测试等功能。

使用Spring主要是可以简化Java应用开发，比如

+ Spring提供IoC容器，可以通过依赖注入更方便实现松散耦合；
+ Spring支持面向切面编程，这样能把应用业务逻辑和系统服务分开，让开发者聚焦业务；

#### BeanFactory 和 ApplicationContext 有什么区别，ApplicationContext有哪些常用实现类

BeanFactory 是Spring 中 Bean工厂的顶级接口，具有bean定义、bean关联关系设置，根据请求分发bean的功能；

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

#### Spring框架中有哪些不同类型的事件

Spring ApplicationContext 提供了支持事件和代码中监听器的功能

+ 上下文更新事件（ContextRefreshedEvent）：该事件会在ApplicationContext被初始化或者更新时发布。也可以在调用ConfigurableApplicationContext 接口中的refresh()方法时被触发。
+ 上下文开始事件（ContextStartedEvent）：当容器调用 ConfigurableApplicationContext 的Start()方法开始/重新开始容器时触发该事件。
+ 上下文停止事件（ContextStoppedEvent）：当容器调用 ConfigurableApplicationContext 的Stop()方法停止容器时触发该事件。
+ 上下文关闭事件（ContextClosedEvent）：当ApplicationContext被关闭时触发该事件。容器被关闭时，其管理的所有单例Bean都被销毁。
+ 请求处理事件（RequestHandledEvent）：在Web应用中，当一个http请求（request）结束触发该事件。

### Spring IoC

#### :star2: 什么是控制反转，什么是依赖注入，什么是Spring IoC 容器

控制反转就是对组件对象控制权的转移，从程序代码本身转移到了外部容器，通过容器来实现对象组件的装配和管理。实现控制反转的手段是依赖注入，即组件所依赖的对象不再自己new，而是在运行期间由容器根据配置文件描述将依赖关系注入到组件中。

Spring IoC容器就是实现依赖注入的容器，负责创建对象，管理对象，装配对象，并且管理这些对象的整个生命周期。

#### 依赖注入的方式有哪些，怎么选择

+ 构造器依赖注入
+ Setter注入

用构造器参数实现强制依赖，setter方法实现可选依赖。

#### :star2: Spring Bean 的生命周期

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

### Spring AOP

#### :star2: 解释一下AOP

即面向切面编程， 是对OOP的一种补充，主要用于处理在模块化编程中一些具有横切性质的服务，常用于安全控制，日志输出，事务管理等。

AOP 的优点是能够把遍布应用各种的系统服务功能(比如日志，安全等)分离出来，这样核心的业务模块完全不需要了解涉及系统服务所带来的复杂性。例如，在对Controller收到的请求进行安全控制或者日志记录的时候，就可以通过编写一个切面，并声明切面生效位置，而不用在每个业务方法中添加代码去实现对应功能了。

Spring AOP 实现的原理是动态代理。Spring AOP提供了对JDK动态代理和CGLib动态代理的支持。

#### :star2: JDK动态代理和CGLib动态代理区别

JDK动态代理只能为接口创建动态代理实例，而不能对类创建动态代理。CGLib能够对类创建动态代理。

JDK动态代理是由Java内部的反射机制来实现的。CGLib动态代理需要依赖ASM包，把被代理对象类的class文件加载进来，修改其字节码生成子类。

JDK动态代理使用方法和CGLib使用方法：

TODO

#### AOP术语详解

+ __连接点(JoinPoint)__: 程序执行的某个特定位置，如类开始初始化前、类初始化后、类某个方法调用前、调用后、方法抛出异常后。这些代码中的特定点，称为“连接点”。Spring仅支持方法的连接点，即仅能在方法调用前、方法调用后、方法抛出异常时以及方法调用前后这些程序执行点织入增强。

+ __切点(Pointcut)__: AOP通过“切点”定位特定的连接点，即筛选出来的一组连接点。用数据库类比： 连接点相当于数据库中的记录，而切点相当于查询条件

+ __增强/通知(Advice)__: 增强是织入到目标类连接点上的一段程序代码，比如日志记录，安全控制

+ __目标对象(Target)__: 增强逻辑的织入目标类

+ __织入(Weaving)__: 织入是将增强添加到目标类具体连接点(切点)上的过程，Spring采用动态代理织入，AspectJ采用编译期织入和类装载期织入

+ __切面(Aspect)__: 切面由切点和增强组成，它既包括了横切逻辑的定义，也包括了连接点的定义，Spring AOP就是负责实施切面的框架，它将切面所定义的横切逻辑织入到切面所指定的连接点中。

#### Spring AOP 切点表达式

+ execution: 匹配连接点的执行方法
+ args(): 限制连接点匹配参数为执行类型的执行方法
+ @args(): 限制连接点匹配参数由执行注解标注的执行
+ target() 限制连接点匹配目标对象为指定类型的类
+ @target(): 限制连接点匹配目标对象被指定的注解标注的类
+ within(): 限制连接点匹配匹配指定的类型
+ @within(): 限制连接点匹配指定注解标注的类型

#### Spring AOP 通知类型

+ @Before：前置通知，在一个方法执行前被调用。
+ @After: 在方法执行之后调用的通知，无论方法执行是否成功。
+ @AfterReturning: 仅当方法成功完成后执行的通知。
+ @AfterThrowing: 在方法抛出异常退出时执行的通知。
+ @Around: 在方法执行之前和之后调用的通知。

### Spring 其他

#### :star2: Spring 框架中使用了哪些设计模式

+ 工厂模式： BeanFactory用来创建对象的实例
+ 单例模式： Spring 下默认的bean均为 singleton
+ 代理模式： Spring AOP 中 Jdk 动态代理就是利用代理模式技术实现的
+ 策略模式： Spring 的代理方式有两个 Jdk 动态代理和 CGLIB 代理。这两个代理方式的使用正是使用了策略模式
+ 模板方法:  用来解决代码重复的问题。比如 RestTemplate, JpaTemplate

## MyBatis

### MyBatis 基础

#### MyBatis 有哪些优点，解决了什么问题

+ 将SQL语句配置在mapper.xml文件中与java代码分离，便于统一管理和优化
+ 提供映射标签，支持对象与数据库的orm字段关系映射
+ 提供xml标签，支持编写动态sql（主要优势之一），(if, choose, trim, foreach)

#### MyBatis 中 #{} 和 ${} 区别

是Mybatis中两种占位符：

+ `#{}`解析传递进来的参数数据，是预编译处理；
+ `${}`对传递进来的参数原样拼接在SQL中，是字符串替换

使用#{}可以有效的防止SQL注入，提高系统安全性

#### 当实体类中的属性名和表中的字段名不一样，如何处理

有两种解决办法：

+ 在SQL语句中定义别名
+ 在resultMap 中配置字段名和实体类属性名的映射关系

#### Mybatis动态sql是做什么的，有哪些

Mybatis动态sql可以让我们在Xml映射文件内，以标签的形式编写动态sql，完成逻辑判断和动态拼接sql的功能

主要有以下几种:

+ if
+ choose(搭配 when, otherwise 使用)
+ trim (where, set 自带trim功能，可以自定义trim)
+ foreach

其执行原理为，使用OGNL从sql参数对象中计算表达式的值，根据表达式的值动态拼接sql，以此来完成动态sql的功能

#### MyBatis 缓存

MyBatis 支持一级缓存和二级缓存：

+ 一级缓存，其存储作用域是Session，一级缓存采用 PerpetualCache，HashMap存储，(CacheKey 包含 Statement Id + Offset + Limmit + Sql + Params)
+ 二级缓存，其存储作用为Mapper(Namespace)，是跨Session的，默认也是PerpetualCache，但可以自定义数据源

对于缓存数据更新机制，当某一个作用域(一级缓存Session/二级缓存Namespaces)的进行了 C/U/D 操作后，默认该作用域下所有 select 中的缓存将被clear。