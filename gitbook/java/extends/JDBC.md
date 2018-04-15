## JDBC 简介

JDBC(Java Database Connectivity, Java数据库连接)， 是Java语言中用来规范客户端程序如何来访问数据库的应用程序接口，提供了诸如查询和更新数据库中数据的方法。也是J2EE规范中的一种。

## JDBC 使用示例

```java
public class JdbcSample {
    private static final String url = "jdbc:mysql://192.168.5.135:13306/user";
    private static final String user = "root";
    private static final String pass = "123456";

    private void firstQuery() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            // 注册驱动
            Class.forName("com.mysql.cj.jdbc.Driver");
            // 获取连接
            conn = DriverManager.getConnection(url, user, pass);
            // 执行查询
            stmt = conn.createStatement();
            String sql = "select now() as time;";
            rs = stmt.executeQuery(sql);
            // 分析结果
            while (rs.next()) {
                System.out.println(rs.getString("time"));
            }

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        } finally {
            closeQuietly(rs);
            closeQuietly(stmt);
            closeQuietly(conn);
        }
    }

    private void closeQuietly(AutoCloseable r) {
        if (r != null) {
            try {
                r.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        new JdbcSample().firstQuery();
    }
}
```

## JDBC 常用类

+ DriverManager: 负责管理JDBC驱动程序，使用JDBC驱动程序之前，必须先将驱动程序加载并向DriverManager注册后才可以使用

+ Connection： 负责维护Java程序和数据库之间的连接

+ Statement： 通过Statement类提供的方法，可以利用标准的SQL命令，对数据库进性增删改查

## JDBC 最佳实践

+ 使用PrearedStatement： PreparedStatement预编译更快，避免SQL注入

+ 使用ConnectionPool（连接池）： 创建JDBC连接耗时比较长，缓存连接能节省大量的创建关闭连接时间

+ 禁用自动提交： 将自动提交禁用后， 可以将一组数据库操作放在一个事务中；而自动提交模式每次执行SQL语句都将执行自己的事务， 并且在执行结束提交。

+ 使用Batch Update： 通过addBatch()方法向batch中添加SQL查询，然后通过executeBatch()执行批量的查询。 JDBC batch update可以减少数据库数据传输的往返次数，从而提高性能。

+ 使用列名获取ResultSet中的数据，从而避免invalidColumIndexError

+ 要记住关闭Statement、PreparedStatement和Connection，Java 7 之后可以使用try-with-resources
