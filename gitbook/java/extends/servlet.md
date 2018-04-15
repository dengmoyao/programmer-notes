## Servlet简介

Servlet是J2EE 规范中的一种，主要是为了扩展java作为web服务的功能。狭义的Servlet是Java中一个接口，广义的Servlet是指任何实现了这个Servlet接口的类。Servlet可以响应任意类型的请求，但是使用最广泛的是响应web方面的请求。 Servlet必须部署在Java servlet容器才能使用。

## Servlet体系结构

### Servlet相关接口

{% plantuml %}
interface ServletContext
interface ServletConfig
interface ServletRequest
interface ServletResponse
interface Servlet

ServletResponse <.. Servlet
ServletResponse <.. ServletRequest

ServletContext <.. ServletContext
ServletContext <.. ServletConfig
ServletContext <.. ServletRequest

ServletConfig <.. Servlet

ServletRequest <.. ServletRequest
ServletRequest <.. Servlet

Servlet <.. ServletContext
{% endplantuml %}

*plantuml*

```plantuml
interface ServletContext
interface ServletConfig
interface ServletRequest
interface ServletResponse
interface Servlet

ServletResponse <.. Servlet
ServletResponse <.. ServletRequest

ServletContext <.. ServletContext
ServletContext <.. ServletConfig
ServletContext <.. ServletRequest

ServletConfig <.. Servlet

ServletRequest <.. ServletRequest
ServletRequest <.. Servlet

Servlet <.. ServletContext
```

Servlet规范就是基于上面的几个类(接口)运转的。其中ServletConfig用于描述Servlet的配置属性；而ServletContext提供一系列的方法，供Servlet与Servlet容器交互。

与Servlet主动关联的三个类是：ServletConfig、ServletRequest 和 ServletResponse。这三个类都是通过容器传递给Servlet的，其中ServletConfig是在Servlet初始化时传递给Servlet的，而ServletRequest 和 ServletResponse 是在调用Servlet时传递的。

### Servlet接口方法和生命周期

在Web应用加载并使用一个Servlet时，从初始化到销毁这个Servlet期间会发生一系列的事件。这些事件叫做Servlet的生命周期事件(或方法)。Servlet生命周期的三个核心方法分别是 init() , service() 和 destroy()。每个Servlet都会实现这些方法，并且在特定的运行时间调用它们。

+ 在Servlet生命周期的初始化阶段，web容器通过调用init()方法来初始化Servlet实例，并且可以传递一个实现 javax.servlet.ServletConfig 接口的对象给它。

+ 初始化后，Servlet实例就可以处理客户端请求了。web容器调用Servlet的service()方法来处理每一个请求。

+ 最后，当 Servlet 从 Servlet 容器中移除时，也就表明该 Servlet 的生命周期结束了，web容器调用destroy()方法来终结Servlet。

### 使用Servlet

绝大多数时候不需要自己去实现Servlet接口，直接继承GenericServlet或者更为常见的HttpServlet并重写doGet和doPost方法即可。随后在Web容器中注册新编写的Servlet即可，可以使用配置文件，或者使用注解(@WebServlet)的方式进行注册。

以Tomcat为例，配置web.xml：

```xml
<?xml version="1.0"?>
<web-app     xmlns="http://xmlns.jcp.org/xml/ns/javaee"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
 
http://xmlns.jcp.org/xml/ns/javaee/web-app_3_0.xsd"
 
            version="3.0">
 
    <welcome-file-list>
        <welcome-file>/MyFirstServlet</welcome-file>
    </welcome-file-list>
 
    <servlet>
        <servlet-name>MyFirstServlet</servlet-name>
        <servlet-class>com.servlets.MyFirstServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>MyFirstServlet</servlet-name>
        <url-pattern>/MyFirstServlet</url-pattern>
    </servlet-mapping>
 
</web-app>
```

Servlet可以接受初始化参数，并在处理第一个请求前来使用它们来构建配置参数。

```xml
<web-app>
    <servlet>
        <servlet-name>SimpleServlet</servlet-name>
        <servlet-class>com.howtodoinjava.servlets.SimpleServlet</servlet-class>
 
        <!-- Servlet init param -->
        <init-param>
            <param-name>name</param-name>
            <param-value>value</param-value>
        </init-param>
 
    </servlet>
 
</web-app>
```

设置后，你就可以在代码里调用 getServletConfig.getInitializationParameter() 并传递参数名给该方法来使用参数。

```java
String value = getServletConfig().getInitParameter("name");
```

### Servlet过滤器

通过Filter技术，对web服务器管理的所有web资源：例如Jsp, Servlet, 静态图片文件或静态 html 文件等进行拦截，从而实现一些特殊的功能。例如实现URL级别的权限访问控制、过滤敏感词汇、压缩响应信息等一些高级功能。

过滤器必须要实现 javax.servlet.Filter 接口。这个接口包含了init()，descriptor()和doFilter()这些方法。init()和destroy()方法会被容器调用。 doFilter()方法用来在过滤器类里实现逻辑任务。如果你想把过滤器组成过滤链（chain filter）或者存在多匹配给定URL模式的个过滤器，它们就会根据web.xml里的配置顺序被调用。

```xml
<filter>
    <filter-name>LoggingFilter</filter-name>
    <filter-class>LoggingFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>LogingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

## 参考资料

+ [Java Servlet完全教程](http://www.importnew.com/14621.html)
+ [Servlet 工作原理解析](https://www.ibm.com/developerworks/cn/java/j-lo-servlet/)