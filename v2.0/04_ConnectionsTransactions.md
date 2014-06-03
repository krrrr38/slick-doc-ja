Slick 2.0.0 documentation - 04 Connection/Transactions

[Permalink to Connections/Transactions - Slick 2.0.0 documentation](http://slick.typesafe.com/doc/2.0.0/connection.html)

Connections / Transactions
==========================

クエリはプログラムのどこにでも書くことが出来る。クエリを実行する際には、データベースコネクションが必要になる。

<!-- You can write queries anywhere in your program. When you want to execute -->
<!-- them you need a database connection. -->

Database connection
-------------------

用いるJDBCデータベースに対してどのように接続するのかを、それらの情報をカプセル化した[`Database`](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトを作成することで、Slickへ伝える事が出来る。`Database`オブジェクトを作成するには`scala.slick.jdbc.JdbcBackend.Database`にいくつかの[ファクトリメソッド](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef)が用意されており、どのような方法で接続するかによって使い分ける事が出来る。

<!-- You can tell Slick how to connect to the JDBC database of your choice by -->
<!-- creating a Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> -->
<!-- object, which encapsulates the information. There are several -->
<!-- factory methods \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef\> on -->
<!-- scala.slick.jdbc.JdbcBackend.Database that you can use depending on what -->
<!-- connection data you have available. -->

### Using a JDBC URL

JDBC URLを用いて接続を行う際には、[`forURL`][1]を用いる事が出来る。(正しいURLを記述する際には、データベースのJDBCドライバー用ドキュメントを参照して欲しい)

<!-- You can provide a JDBC URL to -->
<!-- forURL \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forURL(String,String,String,Properties,String):DatabaseDef\>. -->
<!-- (see your database's JDBC driver's documentation for the correct URL -->
<!-- syntax). -->

```scala
val db = Database.forURL("jdbc:h2:mem:test1;DB_CLOSE_DELAY=-1", driver="org.h2.Driver")
```

ここでは例として、新しく空のデータベースへと接続をしてみる。用いるのはインメモリ型のH2データベースであり、データベース名が`test1`、そしてJVMが終了するまで残り続けるような(`DB_CLOSE_DELAY=-1`はH2データベース特有のオプション)データベースとなっている。

<!-- Here we are connecting to a new, empty, in-memory H2 database called -->
<!-- `test1` and keep it resident until the JVM ends (`DB_CLOSE_DELAY=-1`, -->
<!-- which is H2 specific). -->

### Using a DataSource

[`DataSource`](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)オブジェクトを既に持っているのなら、[`forDataSource`][2]を用いて`Database`オブジェクトを作成出来る。もしアプリケーションフレームワークのコネクションプールから`DataSource`オブジェクトを取得出来るのなら、Slickのプールへと繋いで欲しい。

<!-- You can provide a DataSource \<javax/sql/DataSource\> object to -->
<!-- forDataSource \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forDataSource(DataSource):DatabaseDef\>. -->
<!-- If you got it from the connection pool of your application framework, -->
<!-- this plugs the pool into Slick. -->

```scala
val db = Database.forDataSource(dataSource: javax.sql.DataSource)
```

後でセッションを作成する時には、コネクションはプールから取得出来るし、セッションが閉じた時に、コネクションはプールへ返却される。

<!-- When you later create a Session \<session-handling\>, a connection is -->
<!-- acquired from the pool and when the Session is closed it is returned to -->
<!-- the pool. -->

### Using a JNDI Name

もし[JNDI](http://en.wikipedia.org/wiki/JNDI)を用いているのなら、[DataSource](http://docs.oracle.com/javase/7/docs/api/javax/sql/DataSource.html)オブジェクトが見つかるJNDIの名前を[forName][3]に渡してあげたら良い。

<!-- If you are using JNDI you can provide a JNDI name to -->
<!-- forName \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef@forName(String):DatabaseDef\> -->
<!-- under which a DataSource \<javax/sql/DataSource\> object can be looked -->
<!-- up. -->

Session handling
----------------

[Database](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトを持っているのなら、[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトにSlickがカプセル化したデータベースコネクションを開く事が出来る。

<!-- Now you have a -->
<!-- Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> object and -->
<!-- you can use it to open database connections, which Slick encapsulates in -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> objects. -->

### Automatically closing Session scope

[Database](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトの[withSession][4])関数は、関数を引数に、実行後に接続の閉じる[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を作る。もしコネクションプールを用いたのならば、[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を閉じるとコネクションはプールへと返却される。

<!-- The Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> object's -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- method creates a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\>, passes it to a -->
<!-- given function and closes it afterwards. If you use a connection pool, -->
<!-- closing the Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> -->
<!-- returns the connection to the pool. -->

```scala
val query = for (c <- coffees) yield c.name
val result = db.withSession {
  session =>
    query.list()( session )
}
```

[withSession][5]のスコープの外側で定義されたクエリが使われている事を上の例から確認出来る。データベースに対してクエリを実行する関数は[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を必要とする。先ほどの例では[list][6]関数を用いてクエリを実行し、[List](http://www.scala-lang.org/api/2.10.0/#scala.collection.immutable.List)として結果を取得している。(クエリを実行する関数は暗黙的な変換を通して作られる)

<!-- You can see how we are able to already define the query outside of the -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- scope. Only the methods actually executing the query in the database -->
<!-- require a Session \<scala.slick.jdbc.JdbcBackend@Session:Session\>. Here -->
<!-- we use the list \<scala.slick.jdbc.Invoker@list(P)(SessionDef):List[R]\> -->
<!-- method to execute the query and return the results as a -->
<!-- scala.collection.immutable.List. (The executing methods are made -->
<!-- available via implicit conversions). -->

ただし、デフォルトの設定ではデータベースセッションは*auto-commit*モードになっている。[insert][7]や[insertAll][8]のようなデータベースへの呼び出しは原子的(必ず成功するか失敗するかのいずれかが保証されている)に実行される。いくつかの状態を包括するには[Transactions](http://slick.typesafe.com/doc/2.0.0/connection.html#transactions)を用いる。

<!-- Note that by default a database session is in **auto-commit** mode. Each -->
<!-- call to the database like -->
<!-- insert \<scala.slick.driver.JdbcInvokerComponent\$BaseInsertInvoker@insert(U)(SessionDef):SingleInsertResult\> -->
<!-- or -->
<!-- insertAll \<scala.slick.driver.JdbcInvokerComponent\$BaseInsertInvoker@insertAll(U\*)(SessionDef):MultiInsertResult\> -->
<!-- executes atomically (i.e. it succeeds or fails completely). To bundle -->
<!-- several statements use transactions. -->

**注意:** もし[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトが[withSession][9]のスコープ以外で用いられていたのなら、その接続は既に閉じられており、妥当な利用法にはなっていない。利用を避けるべきではあるば、このような状態を避ける方法がいくつかあり、例としてクロージャを用いる([withSession][9]スコープ内にて[Future][10]を用いるなど)、varへセッションを割り当てる、withSessionスコープの返り値としてセッションを返却するといった方法がある。

<!-- **Be careful:** If the -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> object escapes -->
<!-- the -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- scope, it has already been closed and is invalid. It can escape in -->
<!-- several ways, which should be avoided, e.g. as state of a closure (if -->
<!-- you use a -->
<!-- Future \<scala.concurrent.package@Future[T](=>T)(ExecutionContext):Future[T]\> -->
<!-- inside a -->
<!-- withSession \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withSession[T]((Session)=>T):T\> -->
<!-- scope for example), by assigning the session to a var, by returning the -->
<!-- session as the return value of the withSession scope or else. -->

### Implicit Session

[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を暗黙的なものとしてマークすると、データベースに対する呼び出しを行う関数に対して明示的にSessionを渡す必要がなくなる。

<!-- By marking the Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> -->
<!-- as implicit you can avoid having to pass it to the executing methods -->
<!-- explicitly. -->

```scala
val query = for (c <- coffees) yield c.name
val result = db.withSession {
  implicit session =>
    query.list // <- takes session implicitly
}
// query.list // <- would not compile, no implicit value of type Session
```

これはオプショナルな使い方ではあるが、用いるとよりコードを綺麗にする事が出来る。

<!-- This is optional of course. Use it if you think it makes your code -->
<!-- cleaner. -->

### Transactions

[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトの[withTransaction][11]関数をトランザクションを作成するために使う事が出来る。そのブロックにおいて、1つのトランザクション処理が実行されることになる。もし例外が発生したのなら、Slickはトランザクションをブロックの終了箇所までロールバックさせる。ブロック内のどこからでも[rollback][12]関数を呼び出すことでブロックの末尾までロールバックを強制して起こさせる事も出来る。注意して欲しいのは、Slickはデータベースのオペレーションとしてのロールバックを行うのであり、他のScalaコードの影響を引き起こさない。

<!-- You can use the Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> -->
<!-- object's -->
<!-- withTransaction \<scala.slick.jdbc.JdbcBackend\$SessionDef@withTransaction[T](=>T):T\> -->
<!-- method to create a transaction when you need one. The block passed to it -->
<!-- is executed in a single transaction. If an exception is thrown, Slick -->
<!-- rolls back the transaction at the end of the block. You can force the -->
<!-- rollback at the end by calling -->
<!-- rollback \<scala.slick.jdbc.JdbcBackend\$SessionDef@rollback():Unit\> -->
<!-- anywhere within the block. Be aware that Slick only rolls back database -->
<!-- operations, not the effects of other Scala code. -->

```scala
session.withTransaction {
  // your queries go here
  if (/* some failure */ false){
    session.rollback // signals Slick to rollback later
  }
} // <- rollback happens here, if an exception was thrown or session.rollback was called
```

もし[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)オブジェクトをまだ持っていないのなら、[Database](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Database:Database)オブジェクトの[withTransaciton][13]関数を直接呼ぶ事が出来る。

<!-- If you don't have a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> yet you can use -->
<!-- the Database \<scala.slick.jdbc.JdbcBackend@Database:Database\> object's -->
<!-- withTransaction \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withTransaction[T]((Session)=>T):T\> -->
<!-- method as a shortcut. -->

```scala
db.withTransaction{
  implicit session =>
    // your queries go here
}
```

### Manual Session handling

この方法は推奨されない。もししなければならない場面があるのなら、[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を手動で取り扱うことも出来る。

<!-- This is not recommended, but if you have to, you can handle the lifetime -->
<!-- of a Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> manually. -->

```scala
val query = for (c <- coffees) yield c.name
val session : Session = db.createSession
val result  = query.list()( session )
session.close
```

### Passing sessions around

Slickのクエリに対し、再利用可能な関数を書くことが出来る。これらの関数はSessionを必要としないものであり、クエリのフラグメントやアセンブリ化されたクエリを生成する。もしこれらの関数内でクエリを実行したいのなら、Sessionが必要になる。その際は、関数のシグネチャにおいて(出来れば暗黙的なものとして)引数にあたえてあげるか、もしくはいくつかの同様の関数を包括して、共通化したコードを削除するためにセッションを保持したクラスにする。

<!-- You can write re-useable functions to help with Slick queries. They -->
<!-- mostly do not need a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> as they just -->
<!-- produce query fragments or assemble queries. If you want to execute -->
<!-- queries inside of them however, they need a -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\>. You can either -->
<!-- put it into the function signature and pass it as a (possibly implicit) -->
<!-- argument. Or you can bundle several such methods into a class, which -->
<!-- stores the session to reduce boilerplate code: -->

```scala
class Helpers(implicit session: Session){
  def execute[T](query: Query[T,_]) = query.list
  // ... place further helpers methods here
}
val query = for (c <- coffees) yield c.name
db.withSession {
  implicit session =>
  val helpers = (new Helpers)
  import helpers._
  execute(query)
}
// (new Helpers).execute(query) // <- Would not compile here (no implicit session)
```

### Dynamically scoped sessions

セッションは長い間開きっぱなしにはしたくないが、必要な時にはすぐに開いたり閉じたりしたいと考えるだろう。上記の例では、クエリを実行するために必要な時に暗黙的なセッション引数を用いて[セッションスコープ](http://slick.typesafe.com/doc/2.0.0/connection.html#session-scope)や[トランザクションスコープ](http://slick.typesafe.com/doc/2.0.0/connection.html#transactions)を使っていた。

<!-- You usually do not want to keep sessions open for very long but open and -->
<!-- close them quickly when needed. As shown above you may use a -->
<!-- session scope \<session-scope\> or transaction scope \<transactions\> -->
<!-- with an implicit session argument every time you need to execute some -->
<!-- queries. -->

別の方法として、共通化したコードの部分的なものを保存する、ということが、ファイルの先頭に追加に次の行を追加する事で行える。これにより、セッション引数無しのセッションスコープやトランザクションスコープを利用する事が出来る。

<!-- Alternatively you can save a bit of boilerplate code by putting -->
<!-- at the top of your file and then using a session scope or transaction -->
<!-- scope without a session argument. -->

```scala
import Database.dynamicSession // <- implicit def dynamicSession : Session
```

現在のコールスタック内のどこかで[withDynSession][14]か[withDynTransaction][15]スコープが開かれていた場合において、[dynamicSession](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session)は適切な[Session](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend@Session:Session)を返却する暗黙的な関数となる。

<!-- dynamicSession \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef@dynamicSession:Session\> -->
<!-- is an implicit def that returns a valid -->
<!-- Session \<scala.slick.jdbc.JdbcBackend@Session:Session\> if a -->
<!-- withDynSession \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withDynSession[T](=>T):T\> -->
<!-- or -->
<!-- withDynTransaction :\<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withDynTransaction[T](=>T):T\> -->
<!-- scope is open somewhere on the current call stack. -->

```scala
db.withDynSession {
  // your queries go here
}
```

注意して欲しいのは、もし[dynamicSession](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session)がインポートさあれ、[withDynSession][14]や[withDynTransaction][15]スコープの外側でクエリが実行されようとしているのならば、実行時例外を吐いてしまう事である。つまり、静的な安全性を犠牲にしているのである。[dynamicSession](http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@dynamicSession:Session)は内部的に[DynamicVariable](http://www.scala-lang.org/api/2.10.0/#scala.util.DynamicVariable)を用いる。これは動的にスコープのある変数を作成し、Javaの[InheritableThreadLocal](http://docs.oracle.com/javase/7/docs/api/java/lang/InheritableThreadLocal.html)を順々に用いるものである。静的であることの安全性とスレッドの安全性に配慮して欲しい。

<!-- Be careful, if you import -->
<!-- dynamicSession \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef@dynamicSession:Session\> -->
<!-- and try to execute a query outside of a -->
<!-- withDynSession \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withDynSession[T](=>T):T\> -->
<!-- or -->
<!-- withDynTransaction \<scala.slick.jdbc.JdbcBackend\$DatabaseDef@withDynTransaction[T](=>T):T\> -->
<!-- scope, you will get a runtime exception. So you sacrifice some static -->
<!-- safety for less boilerplate. -->
<!-- dynamicSession \<scala.slick.jdbc.JdbcBackend\$DatabaseFactoryDef@dynamicSession:Session\> -->
<!-- internally uses scala.util.DynamicVariable, which implements dynamically -->
<!-- scoped variables and in turn uses Java's -->
<!-- InheritableThreadLocal \<java/lang/InheritableThreadLocal\>. Be aware of -->
<!-- the consequences regarding static safety and thread safety. -->

Connection Pools
----------------

Slickは独自のコネクションプール実装を持っていない。JEEやSpringのようなある種のコンテナにおけるアプリケーションを動かす際、一般的にコンテナに提供されたコネクションプールを用いる事になるだろう。スタンドアローンなアプリケションにおいては[DBCP](http://commons.apache.org/proper/commons-dbcp/)や[c3p0](http://sourceforge.net/projects/c3p0/)、[BoneCP](http://jolbox.com/)のような外部のコネクションプールの実装を用いる事が出来る。

<!-- Slick does not provide a connection pool implementation of its own. When -->
<!-- you run a managed application in some container (e.g. JEE or Spring), -->
<!-- you should generally use the connection pool provided by the container. -->
<!-- For stand-alone applications you can use an external pool implementation -->
<!-- like DBCP\_, c3p0\_ or BoneCP\_. -->

ちなみに、Slickはどこでも利用可能なプリペアドステートメントを持ってはいるが、独自でキャッシュをしたりはしない。よって、コネクションプールの設定において、プレペア度ステートメントのキャッシュを有効にすべきであるし、充分に大きなプールサイズを用意すべきだ。

<!-- Note that Slick uses *prepared* statements wherever possible but it does -->
<!-- not cache them on its own. You should therefore enable prepared -->
<!-- statement caching in the connection pool's configuration and select a -->
<!-- sufficiently large pool size. -->

[1]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forURL(String,String,String,Properties,String):DatabaseDef
[2]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forDataSource(DataSource):DatabaseDef
[3]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseFactoryDef@forName(String):DatabaseDef
[4]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T]((Session)=>T):T
[5]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T](Session)=>T):T
[6]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.Invoker@list(P)(SessionDef):List[R]
[7]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent$BaseInsertInvoker@insert(U)(SessionDef):SingleInsertResult
[8]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.driver.JdbcInvokerComponent$BaseInsertInvoker@insertAll(U*)(SessionDef):MultiInsertResult
[9]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withSession[T](Session)=>T):T)
[10]: http://www.scala-lang.org/api/2.10.0/#scala.concurrent.package@Future[T](=>T)(ExecutionContext):Future[T]
[11]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$SessionDef@withTransaction[T](=>T):T
[12]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$SessionDef@rollback():Unit
[13]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withTransaction[T]((Session)=>T):T
[14]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynSession[T](=>T):T
[15]: http://slick.typesafe.com/doc/2.0.0/api/#scala.slick.jdbc.JdbcBackend$DatabaseDef@withDynTransaction[T](=>T):T
