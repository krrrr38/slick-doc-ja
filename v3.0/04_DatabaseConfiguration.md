Slick 3.0.0 documentation - 04 Database Configuration

[Permalink to Database Configuration — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/database.html)

Database Configuration
======================

どのようにしてデータベースへ接続するかを、[Database](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend@Database:Database)オブジェクトを作成する際に情報を内包して、Slickに教えてあげなくてはならない。_slick.jdbc.JdbcBackend.Database_ のためのいくつかの[factory methods](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend\$DatabaseFactoryDef)が存在する。
<!-- You can tell Slick how to connect to the JDBC database of your choice by creating a Database <slick.jdbc.JdbcBackend@Database:Database> object, which encapsulates the information. There are several factory methods <slick.jdbc.JdbcBackend\$DatabaseFactoryDef> on slick.jdbc.JdbcBackend.Database that you can use depending on what connection data you have available. -->

Using Typesafe Config
---------------------

[Play](https://playframework.com/)や[Akka](http://akka.io/)で使われてる`application.conf`に、[Typesafe Config](https://github.com/typesafehub/config)でデータベースに接続する設定を記述するのを推奨する。
<!-- The prefered way to configure database connections is through Typesafe Config\_ in your `application.conf`, which is also used by Play\_ and Akka\_ for their configuration. -->

```scala
mydb = {
  dataSourceClass = "org.postgresql.ds.PGSimpleDataSource"
  properties = {
    databaseName = "mydb"
    user = "myuser"
    password = "secret"
  }
  numThreads = 10
}
```
_Database.forConfig_ を用いて、設定を読み込むことができる。引数などの詳細については[API documentation][API documentation]を見て欲しい。
<!-- Such a configuration can be loaded with Database.forConfig (see the API documentation <slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forConfig(String,Config,Driver):Database> of this method for details on the configuration parameters). -->

```scala
val db = Database.forConfig("mydb")
```

Using a JDBC URL
----------------
JDBC URLは[forURL][forURL]に渡してあげる（URLについては各種利用するデータベースのJDBCドライバーのドキュメントを読んで欲しい）。
<!-- You can pass a JDBC URL to forURL <slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forURL(String,String,String,Properties,String,AsyncExecutor,Boolean):DatabaseDef>. (see your database's JDBC driver's documentation for the correct URL syntax). -->

```scala
val db = Database.forURL("jdbc:h2:mem:test1;DB_CLOSE_DELAY=-1", driver="org.h2.Driver")
```

ここでは、JVMが終了するまで使うことの出来る`test1`という名前の、新しい空のインメモリH2データベースへの情報を記述し、接続を作っている（`DB_CLOSE_DELAY=-1`ってのはH2データベース特有の設定だ）。
<!-- Here we are connecting to a new, empty, in-memory H2 database called `test1` and keep it resident until the JVM ends (`DB_CLOSE_DELAY=-1`, which is H2 specific). -->

Using a DataSource
------------------
[DataSource](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)は、[forDataSource][forDataSource]に渡してあげる。これは、アプリケーションフレームワークのコネクションプールから得られたものを、Slickのプールへと繋げている。
<!-- You can pass a DataSource <javax/sql/DataSource> object to forDataSource <slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forDataSource(DataSource,AsyncExecutor):DatabaseDef>. If you got it from the connection pool of your application framework, this plugs the pool into Slick. -->

```scala
val db = Database.forDataSource(dataSource: javax.sql.DataSource)
```

Using a JNDI Name
-----------------
もし[JNDI](http://en.wikipedia.org/wiki/JNDI)を使っているのならば、[DataSource](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)オブジェクトを見つけられるように、JNDIの名前を[forName](forName)へ渡してあげたら良い。
<!-- If you are using JNDI you can pass a JNDI name to forName <slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forName(String,AsyncExecutor):DatabaseDef> under which a DataSource <javax/sql/DataSource> object can be looked up. -->

```scala
val db = Database.forName(jndiName: String)
```

Database thread pool
--------------------
どの`Database`も、データベースのI/O Actionを非同期に実行するためのスレッドプールを管理する[AsyncExecutor](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.util.AsyncExecutor)を保持している。そのサイズは、`Database`オブジェクトが最も良いパフォーマンスを出せるように調整されたものとなる。昔からある同期的なアプリケーションなどにおいては、コネクションプール数を調整すべきだ（[HikariCP](http://brettwooldridge.github.io/HikariCP/)の[About Pool Sizing](https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing)などのドキュメントも参考にして欲しい）。[Database.forConfig][Database.forConfig]を用いると、スレッドプールは、直接外部の設定からコネクションパラメータなどと一緒に設定する事が出来る。もし`Database`を取得するのに、その他のファクトリーメソッドを用いているのなら、デフォルトの設定をそのまま用いるか、`AsyncExecutor`をカスタマイズして利用して欲しい。
<!-- Every `Database` contains an slick.util.AsyncExecutor that manages the thread pool for asynchronous execution of Database I/O Actions. Its size is the main parameter to tune for the best performance of the `Database` object. It should be set to the value that you would use for the size of the *connection pool* in a traditional, blocking application (see About Pool Sizing\_ in the HikariCP\_ documentation for further information). When using Database.forConfig <slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forConfig(String,Config,Driver):Database>, the thread pool is configured directly in the external configuration file together with the connection parameters. If you use any other factory method to get a `Database`, you can either use a default configuration or specify a custom AsyncExecutor: -->

```scala
val db = Database.forURL("jdbc:h2:mem:test1;DB_CLOSE_DELAY=-1", driver="org.h2.Driver",
  executor = AsyncExecutor("test1", numThreads=10, queueSize=1000))
```

Connection pools
----------------

コネクションプールを用いているのなら（プロダクション環境などでは利用していると思うが...）、コネクションプール数の最小値は少なくとも同じ数分だけ設定すべきである。（`When using a connection pool the minimum size of the connection pool should also be set to at least the same size.`）コネクションプール数の最大値については、同期的なアプリケーションにおいて利用される数より多めの値を設定するのが良い。スレッドプール数を超えるコネクションは、データベースセッションをオープンし続けるために他のコネクションが要求された際に用いられる事になる（例として、トランザクション中の非同期的な計算結果を待っている時など）。
<!-- When using a connection pool (which is always recommended in production environments) the *minimum* size of the *connection pool* should also be set to at least the same size. The *maximum* size of the *connection pool* can be set much higher than in a blocking application. Any connections beyond the size of the *thread pool* will only be used when other connections are required to keep a database session open (e.g. while waiting for the result from an asynchronous computation in the middle of a transaction) but are not actively doing any work on the database. -->

ちなみに、[Database.forConfig][Database.forConfig]を利用した際には、スレッドプール数をもとに系あsんされたコネクションプール数がデフォルト値として提供される。
<!-- Note that reasonable defaults for the connection pool sizes are calculated from the thread pool size when using Database.forConfig <slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forConfig(String,Config,Driver):Database>. -->

Slickはプリペアドステートメントを利用可能な場所では利用しているものの、Slick側でそれらをキャッシュしていない。それゆえ、あなた自身でコネクションプールの設定時にプリペアドステートメントのキャッシュを有効化して欲しい。
<!-- Slick uses *prepared* statements wherever possible but it does not cache them on its own. You should therefore enable prepared statement caching in the connection pool's configuration. -->

DatabaseConfig
--------------

`Database`の設定のトップにおいて、[DatabaseConfig](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.backend.DatabaseConfig)のフォーム内にSlickドライバーに合う`Database`を追加する設定も置くことが出来る。これを利用すると、異なるデータベースを利用する上で、簡単に設定ファイルを変更出来るようにするための抽象化が簡単に行える。
<!-- On top of the configuration syntax for `Database`, there is another layer in the form of slick.backend.DatabaseConfig which allows you to configure a Slick driver plus a matching `Database` together. This makes it easy to abstract over different kinds of database systems by simply changing a configuration file. -->

`driver`にSlickのドライバーを、`db`にデータベースの設定を記述した`DatabaseConfig`の例は次のようになる。
<!-- Here is a typical `DatabaseConfig` with a Slick driver object in `driver` and the database configuration in `db`: -->

```
tsql {
  driver = "slick.driver.H2Driver\$"
  db {
    connectionPool = disabled
    driver = "org.h2.Driver"
    url = "jdbc:h2:mem:tsql1;INIT=runscript from 'src/main/resources/create-schema.sql'"
  }
}
```

[API documentation]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forConfig(String,Config,Driver):Database
[forURL]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forURL(String,String,String,Properties,String,AsyncExecutor,Boolean):DatabaseDef
[forDataSource]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forDataSource(DataSource,AsyncExecutor):DatabaseDef
[Database.forConfig]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forConfig(String,Config,Driver):Database
