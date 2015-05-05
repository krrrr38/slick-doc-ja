Slick 3.0.0 documentation - 05 Database I/O Actions

[Permalink to Database I/O Actions — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/dbio.html)

データベースI/Oアクション
====================

クエリの結果を取得したり（`myQuery.result`）、テーブルを作成したり（`myTable.schema.create`）、データを挿入する（`myTable += item`）といったデータベースに対して実行する全ての事柄は、[DBIOAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)のインスタンスになる。
<!-- Anything that you can execute on a database, whether it is a getting the result of a query (`myQuery.result`), creating a table (`myTable.schema.create`), inserting data (`myTable += item`) or something else, is an instance of slick.dbio.DBIOAction, parameterized by the result type it will produce when you execute it. -->

_Database I/O Actions_ はいくつかの異なるコンビネータにより結合されるが（詳細は[DBIOAction class](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)と[DBIO object](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIO\$)で）、それらはいつも直列に実行され、（少なくとも概念上は）1つのデータベースセッションにおいて実行される。
<!-- *Database I/O Actions* can be combined with several different combinators (see the DBIOAction class \<slick.dbio.DBIOAction\> and DBIO object \<slick.dbio.DBIO\$\> for details), but they will always be executed strictly sequentially and (at least conceptually) in a single database session. -->

大抵の場合、[DBIO](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.package@DBIO[+R]:DBIO[R])の型エイリアスを通常時のデータベースI/Oアクションとして、[StreamingDBIO](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.package@StreamingDBIO[+R,+T]:StreamingDBIO[R,T])の型エイリアスををストリーミング可能なデータベースI/Oアクションとして利用したいと思うだろう。これらは、[DBIOAction](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)によってサポートされた副次的な _effect types_ を省略させる(`They omit the optional *effect types* supported by slick.dbio.DBIOAction.`)。
<!-- In most cases you will want to use the type aliases DBIO \<slick.dbio.package@DBIO[+R]:DBIO[R]\> and StreamingDBIO \<slick.dbio.package@StreamingDBIO[+R,+T]:StreamingDBIO[R,T]\> for non-streaming and streaming Database I/O Actions. They omit the optional *effect types* supported by slick.dbio.DBIOAction.  -->

Executing Database I/O Actions
------------------------------

`DBIOActions`を実行すると、データベースから得られた具象化された結果やストリーミングデータを得る事が出来る。
<!-- `DBIOAction`s can be executed either with the goal of producing a fully materialized result or streaming data back from the database. -->

### Materialized

データベースに対し`DBIOAction`を実行し、具象化された結果を得るには`run`を用いる。これは例えば、単一のクエリ結果を引く場合（`myTable.length.result`）、コレクションを結果として得るクエリを引く場合（`myTable.to[Set].result`）などに利用される。どの`DBIOAction`もこのような実行処理をサポートしている。
<!-- You can use `run` to execute a `DBIOAction` on a Database and produce a materialized result. This can be, for example, a scalar query result (`myTable.length.result`), a collection-valued query result (`myTable.to[Set].result`), or any other action. Every `DBIOAction` supports this mode of execution. -->

`run`が呼ばれた時点で、アクションの実行が開始される。そして具象化された結果は非同期に処理が実行され終了するものとして、`Future`にくるまって返却される。
<!-- Execution of the action starts when `run` is called, and the materialized result is returned as a `Future` which is completed asynchronously as soon as the result is available: -->

```scala
val q = for (c <- coffees) yield c.name
val a = q.result
val f: Future[Seq[String]] = db.run(a)
f.onSuccess { case s => println(s"Result: \$s") }
```

### Streaming

コレクションが得られるクエリには、ストリーミングの結果を返却する機能が備わっている。この場合、実際のコレクションの型は無視され、要素が直接[Reactive Streams](http://www.reactive-streams.org/)の`Publisher`を通して返却されることになる。これは[Akka Streams](http://akka.io/docs/)により処理・計算されたものとなる。
<!-- Collection-valued queries also support streaming results. In this case, the actual collection type is ignored and elements are streamed directly from the result set through a Reactive Streams\_ `Publisher`, which can be processed and consumed by Akka Streams\_. -->

`DBIOAction`の実行処理は、`Subscriber`をストリームに繋げるまで実行されない。`Subscriber`は1つだけ _購読_ させる事が可能であり、それ以上の _購読_ を行おうとするとそれらは失敗してしまう。`DBIOAction`のストリーミング部分において、ストリームの各要素は利用出来る状態になるとすぐに実行可能であると合図を送る。例えばトランザクションの中でストリーミング処理を行った場合にも、全ての要素は正常に届けられ、トランザクションがコミットされなかった場合にもきちんとストリームも失敗するようにできている。
<!-- Execution of the `DBIOAction` does not start until a `Subscriber` is attached to the stream. Only a single `Subscriber` is supported, and any further attempts to subscribe again will fail. Stream elements are signaled as soon as they become available in the streaming part of the `DBIOAction`. The end of the stream is signaled only after the entire action has completed. For example, when streaming inside a transaction and all elements have been delivered successfully, the stream can still fail afterwards if the transaction cannot be committed. -->

```scala
val q = for (c <- coffees) yield c.name
val a = q.result
val p: DatabasePublisher[String] = db.stream(a)
...
// .foreach is a convenience method on DatabasePublisher.
// Use Akka Streams for more elaborate stream processing.
p.foreach { s => println(s"Element: \$s") }
```

JDBCの結果集合をストリーミングする際、もし`Subscriber`が多くのデータを受け取る準備が出来ていないのなら、次の結果ページはバックグラウンドにバッファリングされる。一方で、全ての結果要素は同期的に渡されるし、結果集合は同期処理が終了する前に先に進んでしまったりはしない。これにより、結果集合の状態に依存する`Blob`のようなJDBCの低レベルな値に対しても同期的なコールバックが利用可能となる。`mapResult`のような便利なメソッドがこの目的のために提供されている。
<!-- When streaming a JDBC result set, the next result page will be buffered in the background if the Subscriber is not ready to receive more data, but all elements are signaled synchronously and the result set is not advanced before synchronous processing is finished. This allows synchronous callbacks to low-level JDBC values like `Blob` which depend on the state of the result set. The convenience method `mapResult` is provided for this purpose: -->

```scala
val q = for (c <- coffees) yield c.image
val a = q.result
val p1: DatabasePublisher[Blob] = db.stream(a)
val p2: DatabasePublisher[Array[Byte]] = p1.mapResult { b =>
  b.getBytes(0, b.length().toInt)
}
```

### Transactions and Pinned Sessions

いくつかの小さいアクションで構成された`DBIOAction`を実行する際には、Slickはコネクションプールから得られたセッションを要求し、その後セッションを開放する。データベース外の計算から結果を得るのを待ち合わせる間（例えば、[flatMap][flatMap]）、不必要なセッションは保持されない。データベースに計算させることなく、2つのデータベースのアクションを結合する[DBIOAction combinators](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction)（[andThen][andThen]や[zip][zip]）は、1つのセッション内で融合されたアクションを実行する副作用を伴いつつ、より効率的にこれらのアクションを融合する。1つのセッションでの利用を強制するには、[withPinnedSession](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@withPinnedSession:DBIOAction[R,S,E])を利用すれば良い。これを用いる事で、データベース外での計算を待ち合わせる際に、既存のセッションを開き続けたままにしておくことが出来る。
<!-- When executing a `DBIOAction` which is composed of several smaller actions, Slick acquires sessions from the connection pool and releases them again as needed so that a session is not kept in use unnecessarily while waiting for the result from a non-database computation (e.g. the function passed to flatMap \<slick.dbio.DBIOAction@flatMap[R2,S2\<:NoStream,E2\<:Effect]((R)⇒DBIOAction[R2,S2,E2])(ExecutionContext):DBIOAction[R2,S2,EwithE2]\> that determines the next Action to run). All DBIOAction combinators \<slick.dbio.DBIOAction\> which combine two database actions without any non-database computations in between (e.g. andThen \<slick.dbio.DBIOAction@andThen[R2,S2\<:NoStream,E2\<:Effect](DBIOAction[R2,S2,E2]):DBIOAction[R2,S2,EwithE2]\> or zip \<slick.dbio.DBIOAction@zip[R2,E2\<:Effect](DBIOAction[R2,NoStream,E2]):DBIOAction[(R,R2),NoStream,EwithE2]\>) can fuse these actions for more efficient execution, with the side-effect that the fused action runs inside a single session. You can use withPinnedSession \<slick.dbio.DBIOAction@withPinnedSession:DBIOAction[R,S,E]\> to force the use of a single session, keeping the existing session open even when waiting for non-database computations. -->

トランザクションの利用を強制する[transactionally](http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.driver.JdbcActionComponent\$JdbcActionExtensionMethods@transactionally:DBIOAction[R,S,EwithTransactional])と呼ばれるコンビネータもある。これは、実行される`DBIOAction`の処理全体が自動的に成功か失敗のいずれかに収まる。
<!-- There is a similar combinator called transactionally \<slick.driver.JdbcActionComponent\$JdbcActionExtensionMethods@transactionally:DBIOAction[R,S,EwithTransactional]\> to force the use of a transaction. This guarantees that the entire `DBIOAction` that is executed will either succeed or fail atomically. -->

> **Warning**
>
> 失敗というのは`transactionally`でラップされた個々の`DBIOAction`のアトミック性を保証するものでは無いため、この時点でエラー回復を図るコンビネータを適用すべきではない。作成されたデータベース側のトランザクションは、`transactionally`アクションの外側でコミットやロールバックを行う。

```scala
val a = (for {
  ns <- coffees.filter(_.name.startsWith("ESPRESSO")).map(_.name).result
  _ <- DBIO.seq(ns.map(n => coffees.filter(_.name === n).delete): _*)
} yield ()).transactionally
val f: Future[Unit] = db.run(a)
```

JDBC Interoperability
---------------------

Slickで利用出来ない機能を使うためにJDBCのレベルを落とすには、`SimpleDBIO`アクションを用いれば良い。`SimpleDBIO`アクションは、データベースのスレッド上で実行され、JDBCの`Connection`への接続を得るものである。
<!-- In order to drop down to the JDBC level for functionality that is not available in Slick, you can use a `SimpleDBIO` action which is run on a database thread and gets access to the JDBC `Connection`:  -->

```scala
val getAutoCommit = SimpleDBIO[Boolean](_.connection.getAutoCommit)
```

[flatMap]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@flatMap[R2,S2<:NoStream,E2<:Effect]((R)%E2%87%92DBIOAction[R2,S2,E2])(ExecutionContext):DBIOAction[R2,S2,EwithE2]
[andThen]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@andThen[R2,S2<:NoStream,E2<:Effect](DBIOAction[R2,S2,E2]):DBIOAction[R2,S2,EwithE2]
[zip]: http://slick.typesafe.com/doc/3.0.0/api/index.html#slick.dbio.DBIOAction@zip[R2,E2<:Effect](DBIOAction[R2,NoStream,E2]):DBIOAction[(R,R2),NoStream,EwithE2]
