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

