Slick 1.0.0 documentation - 06 Slick TestKit
<!--Slick TestKit — Slick 1.0.0 documentation-->

["Permalink to Slick TestKit — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/testkit.html)

# Slick TestKit

Slickに対し，独自のデータベースドライバーを記述する際には，きちんと動作するのか，何が現時点で実装されていないのかなどを確認するために基本となるユニットテスト（もしくは加えて他の独自のカスタマイズしたテスト）を実行して欲しい．このためにSlickユニットテストとしてのSlick Test Kitプロジェクトを別に用意している．

<!--When you write your own database driver for Slick, you need a way to run all the standard unit tests on it (in addition to any custom tests you may want to add) to ensure that it works correctly and does not claim to support any capabilities which are not actually implemented. For this purpose the Slick unit tests have been factored out into a separate Slick TestKit project.-->

これを用いるためには，Slickの基本的なPostgreSQLドライバーと，それをビルドするために必要なものを全て含んだ[Slick TestKit Example][1]をクローンして，それをテストして欲しい．

<!--To get started, you can clone the [Slick TestKit Example][1] project which contains a (slightly outdated) version of Slick’s standard PostgreSQL driver and all the infrastructure required to build and test it.-->

## Scaffolding

build.sbtは以下のように記述する．一般的な名前とバージョン設定と区別して，SlickとTestKit，junit-interface，Logback，PostgreSQL JDBC Driverへの依存性を追加する．そしてテストを行うためのオプションをいくつか記述する必要がある．

<!--Its build.sbt file is straight-forward. Apart from the usual name and version settings, it adds the dependencies for Slick, the TestKit, junit-interface, Logback and the PostgreSQL JDBC driver, and it sets some options for the test runs:-->

```scala
libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "1.0.0",
  "com.typesafe.slick" %% "slick-testkit" % "1.0.0" % "test",
  "com.novocode" % "junit-interface" % "0.10-M1" % "test",
  "ch.qos.logback" % "logback-classic" % "0.9.28" % "test",
  "postgresql" % "postgresql" % "9.1-901.jdbc4" % "test"
)

testOptions += Tests.Argument(TestFrameworks.JUnit, "-q", "-v", "-s", "-a")

parallelExecution in Test := false

logBuffered := false
```

src/test/resources/logback-test.xmlに，Slickのlogbackについての設定のコピーがある．しかし，もし異なるものを用いたい場合には，loggingフレームワークを取り替える事が出来る．

<!--There is a copy of Slick’s logback configuration in src/test/resources/logback-test.xml but you can swap out the logging framework if you prefer a different one.-->

## Driver

実際のドライバーの実装はsrc/main/scalaの中にある．

<!--The actual driver implementation can be found under src/main/scala.-->

## Test Harness

TestKitテストを実行するためには，DriberTestを継承したクラスを作成する必要がある．加えて，TestKitに対してどのようにtestデータベースへ接続するのか，テーブルのリストをどのように取得するのか，テスト間におけるクリーンをどのようにして行うのかなどといった事を伝えるTestDBの実装が必要になる．

<!--In order to run the TestKit tests, you need to add a class that extends DriverTest, plus an implementation of TestDB which tells the TestKit how to connect to a test database, get a list of tables, clean up between tests, etc.-->

PostgreSQLのテーストハーネス（src/test/scala/scala/slick/driver/test/MyPostgreTestの中にある）の場合は，大抵のデフォルトとなる実装はボックスの外で利用される．

<!--In the case of the PostgreSQL test harness (in **src/test/scala/scala/slick/driver/test/MyPostgresTest.scala**) most of the default implementations can be used out of the box:-->

```scala
@RunWith(classOf[Testkit])
class MyPostgresTest extends DriverTest(MyPostgresTest.tdb)

object MyPostgresTest {
  def tdb(cname: String) = new ExternalTestDB("mypostgres", MyPostgresDriver) {
    override def getLocalTables(implicit session: Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null))
      tables.list.filter(_._4.toUpperCase == "TABLE").map(_._3).sorted
    }
    override def getLocalSequences(implicit session: Session) = {
      val tables = ResultSetInvoker[(String,String,String, String)](_.conn.getMetaData().getTables("", "public", null, null))
      tables.list.filter(_._4.toUpperCase == "SEQUENCE").map(_._3).sorted
    }
    override lazy val capabilities = driver.capabilities + TestDB.plainSql
  }
}
```    

## Database Configuration

PostgreSQLのテストハーネスは **ExternalTestDB** に基づいている一方， **test-dbs/databases.properties** において設定が行われてなくてはならない．

<!--Since the PostgreSQL test harness is based on **ExternalTestDB**, it needs to be configured in **test-dbs/databases.properties**:-->

```scala
# PostgreSQL quick setup:
# - Install PostgreSQL server with default options
# - Change password in mypostgres.password
# - Set mypostgres.enabled = true
mypostgres.enabled = false
mypostgres.url = jdbc:postgresql:[DB]
mypostgres.user = postgres
mypostgres.password = secret
mypostgres.adminDB = postgres
mypostgres.testDB = slick-test
mypostgres.create = CREATE TABLESPACE slick_test LOCATION '[DBPATH]'; CREATE DATABASE "[DB]" TEMPLATE = template0 TABLESPACE slick_test
mypostgres.drop = DROP DATABASE IF EXISTS "[DB]"; DROP TABLESPACE IF EXISTS slick_test
mypostgres.driver = org.postgresql.Driver
```

## Testing

**sbt test** を実行すると， **MyPostgresTest** を探索し，TestKitのJUnit runnerを用いて実行される．これはテストハーネスを通してセットアップされたデータベースを用いており，ドライバーを用いて適応可能な全てのテストが実行される事になる．

<!--Running **sbt test** discovers **MyPostgresTest** and runs it with TestKit’s JUnit runner. This in turn causes the database to be set up through the test harness and all tests which are applicable for the driver (as determined by the **capabilities** setting in the test harness) to be run.-->

 [1]: https://github.com/slick/slick-testkit-example/tree/1.0.0  
