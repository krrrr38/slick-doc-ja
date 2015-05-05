Slick 3.0.0 documentation - 16 Slick TestKit

[Permalink to Slick TestKit — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/testkit.html)

Slick TestKitについて
=============

<!-- **note** This chapter is based on the Slick TestKit Example template\_. The prefered way of reading this introduction is in Activator\_, where you can edit and run the code directly while reading the tutorial.  -->

Slickに対し、独自のデータベースドライバを記述する際には、きちんと動作するのか、何が現時点で実装されていないのかなどを確認するために、ユニットテスト（もしくは加えて他の独自のカスタマイズしたテスト）をきちんと記述して欲しい。簡単にテストを記述するためのサポートとして、Slickユニットテスト用のSlick Test Kitプロジェクトを別に用意している。
<!-- When you write your own database driver for Slick, you need a way to run all the standard unit tests on it (in addition to any custom tests you may want to add) to ensure that it works correctly and does not claim to support any capabilities which are not actually implemented. For this purpose the Slick unit tests have been factored out into a separate Slick TestKit project.  -->

これを用いるためには、Slickの基本的なPostgreSQLドライバと、ビルドするために必要なものを全て含んだ[Slick TestKit Example](https://github.com/slick/slick-testkit-example/tree/3.0.0)をcloneして使って欲しい。
<!-- To get started, you can clone the Slick TestKit Example template\_ which contains a copy of Slick's standard PostgreSQL driver and all the infrastructure required to build and test it.  -->

Scaffolding
-----------

build.sbtは以下のように記述する。一般的な名前とバージョン設定と区別して、SlickとTestKit、junit-interface、Logback、PostgreSQL JDBC Driverへの依存性を追加する。そしてテストを行うためのオプションをいくつか記述する必要がある。
<!-- Its `build.sbt` file is straight-forward. Apart from the usual name and version settings, it adds the dependencies for Slick, the TestKit, junit-interface, Logback and the PostgreSQL JDBC driver, and it sets some options for the test runs:  -->

```scala
libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "|release|",
  "com.typesafe.slick" %% "slick-testkit" % "|release|" % "test",
  "com.novocode" % "junit-interface" % "0.10" % "test",
  "ch.qos.logback" % "logback-classic" % "0.9.28" % "test",
  "postgresql" % "postgresql" % "9.1-901.jdbc4" % "test"
)
...
testOptions += Tests.Argument(TestFrameworks.JUnit, "-q", "-v", "-s",
"-a")
...
parallelExecution in Test := false
...
logBuffered := false
```

`src/test/resources/logback-test.xml`に、Slickのlogbackについての設定のコピーがある。もちろん、loggingフレームワーク以外のものを使う事も出来る。
<!-- There is a copy of Slick's logback configuration in `src/test/resources/logback-test.xml` but you can swap out the logging framework if you prefer a different one.  -->

Driver
------

ドライバの実装は`src/main/scala`の中にある。
<!-- The actual driver implementation can be found under `src/main/scala`. -->

Test Harness
------------

TestKitテストを実行するためには、DriberTestを継承したクラスを作成する必要がある。加えて、TestKitに対してどのようにtestデータベースへ接続するのか、テーブルのリストをどのように取得するのか、テスト間におけるクリーンをどのようにして行うのかなどといった事を表すTestDBの実装が必要になる。
<!-- In order to run the TestKit tests, you need to add a class that extends `DriverTest`, plus an implementation of `TestDB` which tells the TestKit how to connect to a test database, get a list of tables, clean up between tests, etc.  -->

PostgreSQLのテストハーネスの場合（`src/test/slick/driver/test/MyPostgresTest.scala`）、大抵のデフォルト実装は、そのままですぐに使える用になっている。`localTables`と`getLocalSequences`のみ、カスタマイズした実装が必要になる。JDBCの`getFunctions`呼び出しをサポートしないドライバである事を明示するために、ドライバの`capabilities`を変更する。
<!-- In the case of the PostgreSQL test harness (in `src/test/slick/driver/test/MyPostgresTest.scala`) most of the default implementations can be used out of the box. Only `localTables` and `getLocalSequences` require custom implementations. We also modify the driver's `capabilities` to indicate that our driver does not support the JDBC `getFunctions` call:  -->

```scala
@RunWith(classOf[Testkit])
class MyPostgresTest extends DriverTest(MyPostgresTest.tdb)
object MyPostgresTest {
  def tdb = new ExternalJdbcTestDB("mypostgres") {
    val driver = MyPostgresDriver
    override def localTables(implicit ec: ExecutionContext): DBIO[Vector[String]] =
      ResultSetAction[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null)).map { ts =>
        ts.filter(_._4.toUpperCase == "TABLE").map(_._3).sorted
      }
    override def getLocalSequences(implicit session: profile.Backend#Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null))
      tables.buildColl[List].filter(_._4.toUpperCase == "SEQUENCE").map(_._3).sorted
    }
    override def capabilities = super.capabilities - TestDB.capabilities.jdbcMetaGetFunctions
  }
}
```

設定のプレフィックス名（上記例では`mypostgres`）は`ExternalJdbcTestDB`へ渡してあげる必要がある。
<!-- The name of a configuration prefix, in this case `mypostgres`, is passed to `ExternalJdbcTestDB`:  -->

```scala
def tdb =
  new ExternalJdbcTestDB("mypostgres") ...
```

Database Configuration
----------------------

PostgreSQLのテストハーネスは`ExternalJdbcTestDB`をベースにしているため、`test-dbs/testkit.conf`の設定をいじる必要がある。
<!-- Since the PostgreSQL test harness is based on `ExternalJdbcTestDB`, it needs to be configured in `test-dbs/testkit.conf`:  -->

```scala
mypostgres.enabled = true
mypostgres.user = myuser
mypostgres.password = secret
```

`ExternalJdbcTestDB`を扱うためのオプショナルな設定が他にもいくつかある。`testkit-reference.conf`には、適切なデフォルト値が設定されており、`testkit.conf`をシンプルに保つのが良い。
<!-- There are several other configuration options that need to be set for an `ExternalJdbcTestDB`. These are defined with suitable defaults in `testkit-reference.conf` so that `testkit.conf` can be kept very simple in most cases.  -->

Testing
-------

`sbt test` を実行すると、 `MyPostgresTest` を探索し、TestKitのJUnit runnerを用いて実行される。これはテストハーネスを通してセットアップされたデータベースを用いており、ドライバを用いて適応可能な全てのテストが実行される事になる。
<!-- Running `sbt test` discovers `MyPostgresTest` and runs it with TestKit's JUnit runner. This in turn causes the database to be set up through the test harness and all tests which are applicable for the driver (as determined by the `capabilities` setting in the test harness) to be run.  -->
