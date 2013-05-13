Slick 1.0.0 documentation - 05 Direct Embedding
<!--Direct Embedding — Slick 1.0.0 documentation-->

[Permalink to Direct Embedding — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/direct-embedding.html)

# Direct Embedding

direct embeddingは新しい，しかしまだ不完全で実験的なクエリAPIである．現在実験中．開発中の段階であるため，リリースに応じて非推奨な期間など無しに変更される事がある．安全に利用する事の出来る，安定したlifted embeddingクエリAPIに取って代わるような予定は無く，direct embeddingは共存させていく．lifted embeddingと違って，direct enbeddingは実装のための暗黙的な変換やオーバーロードするオペレータの代わりにマクロを用いて操作を行う．ユーザのために，コード内における違いは少なくしているが，direct enbeddingを用いるクエリは普遍的なScalaの型を用いて機能している．これは表示されるエラーメッセージの理解性を上げるためでもある．

<!--The direct embedding is a new, still incomplete, experimental Query API under development. It may change without deprecation period in any release during its experimental status. There is no plan to replace the stable lifted embedding Query API, which you can safely bet on for production use. The direct embedding co-exists. Unlike the lifted embedding, the direct embedding uses macros instead of operator overloading and implicit conversions for its implementation. For a user the difference in the code is small, but queries using the direct embedding work with ordinary Scala types, which can make error messages easier to understand.-->

以下の説明はアナログな[*lifted embedding*][1]の説明である．

<!--The following descriptions are anolog to the description of the [*lifted embedding*][1].-->

## Dependencies

direct embeddingは型検査のために実行時にScalaコンパイラにアクセスする必要がある．Slickは必要性に駆られない限り，アプリケーションに対し，依存性を避けるためにScalaコンパイラへの依存性を任意としている．そのため，direct embeddingを用いる際にはプロジェクトの **build.sbt** に対し明示的にその依存性を記述しなくてはならない．

<!--The direct embedding requires access to the Scala compiler at runtime for typechecking. Slick only declares an *optional* dependency on scala-compiler in order to avoid bringing it (along with all transitive dependencies) into your application if you don’t need it. You must add it explicitly to your own project’s build.sbt file if you want to use the direct embedding:-->

```scala
libraryDependencies <+= (scalaVersion)("org.scala-lang" % "scala-compiler" % _)
```

## Imports

```scala
import scala.slick.driver.H2Driver
import H2Driver.simple.Database
import Database.{threadLocalSession => session}
import scala.slick.direct._
import scala.slick.direct.AnnotationMapper._
```

## Row class and schema

スキーマは現在でえは行を保持しているケースクラスに対してアノテーションを付与する事で記述する事が出来る．今後，より柔軟にスキーマの情報を拡張出来るような機能を提供する予定だ．

<!--The schema description is currently provided as annotations on a case class which is used for holding rows. We will later provide more flexible and customizable means of providing the schema information.-->

```scala
// describe schema for direct embedding
@table(name="COFFEES")
case class Coffee(
  @column(name="NAME")
  name : String,
  @column(name="PRICE")
  price : Double
)
```

## Query

Queryableはテーブルデータに対しクエリの演算を行うためのものであり，注釈付けられた型引数を取る．

<!--Queryable takes an annotated case class as its type argument to formulate queries agains the corresponding table.-->

\_.priceはここではInt型である．潜在的な，マクロベースの実装においてはmapやfilterに与えられた引数はJVM上で実行されないが，その代わりにデータベースクエリへと変換される事を覚えておいて欲しい．

<!--_.price is of type Int here. The underlying, macro-based implementation takes care of that the shown arguments to map and filter are not executed on the JVM but translated to database queries instead.-->

```scala
// query database using direct embedding
val q1 = Queryable[Coffee]
val q2 = q1.filter( _.price > 3.0 ).map( _ .name )
```

## Execution

クエリを実行するためには，選択したデータベースのドライバーを用いるSlickBackendインスタンスを作成する必要がある．

<!--To execute the queries we need to create a SlickBackend instance passing in the chosen database backend driver.-->

```scala
val db = Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver")
db withSession {
    // execute query using a chosen db backend
    val backend = new SlickBackend( H2Driver, AnnotationMapper )
    println( backend.result( q2, session ) )
    println( backend.result( q2.length, session ) )
}
```

## Alternative direct embedding bound to a driver and session

ImplicitQueryableを用いると，queryableはバックエンドとセッションに束縛される．クエリはその上で以下のような方法で簡単に実行する事が出来る．

<!--Using ImplicitQueryable, a queryable can be bound to a backend and session. The query can be further adapted and easily executed this way.-->

```scala
//
val iq1 = ImplicitQueryable( q1, backend, session )
val iq2 = iq1.filter( c => c.price > 3.0 )
println( iq2.toSeq ) //  <- triggers execution 
println( iq2.length ) // <- triggers execution
```

## Features

direct embeddingは現在， **String**, **Int**, **Double** といった値にたいしマッピングされるデータベースカラムのみサポートしている．

<!--The direct embedding currently only supports database columns, which can be mapped to either **String** , **Int** , **Double** .-->

QueryableとImplicitQueryableは現在，次のようなメソッドを用意している．

<!--Queryable and ImplicitQueryable currently support the following methods:-->

**map, flatMap, filter, length**

これらのメソッドはimmutableな演算を行うが，関数呼び出しによる変化を包含した新しいQuaryableを返す．

<!--The methods are all immutable meaning they leave the left-hand-side Queryable unmodified, but return a new Queryable incorporating the changes by the method call.-->

上記の関数におけるシンタックスとして，以下の様なオペレータを利用する事が出来る．

<!--Within the expressions passed to the above methods, the following operators may be used:-->

**Any: ==**

**Int, Double: + < >**

**String: +**

**Boolean: || &&**

他に定義された独自のオペレータについても，型検査がマッチしていれば利用する事が出来る．しかし現時点では，それらのオペレータは実行時に失敗するクエリを生成するようなSQLへ変換する事が出来ない．（例: **(coffees.map( c => c.ma,e.repr ))**）将来的には，コンパイル中にそのようなものもキャッチするような方法を検討している．

<!--Other operators may type check and compile ok, if they are defined for the corresponding types. They can however currently not be translated to SQL, which makes the query fail at runtime, for example: **(coffees.map( c => c.name.repr ))** . We are evaluating ways to catch those cases at compile time in the future-->

クエリは行を補完するようなオブジェクトを保持する，任意にネストされたタプルのシーケンスを結果として返す．

<!--Queries may result in sequences of arbitrarily nested tuples, which may also contain objects representing complete rows. E.g.-->

```scala
q1.map( c => (c.name, (c, c.price)) )
```

direct embeddingは現在データの挿入といった機能を持っていない．その代わりに[*lifted embedding*][2]や[*plain SQL queries*][3]などを用いる事ができる．

<!--The direct embedding currently does not feature insertion of data. Instead you can use the [*lifted embedding*][2] or [*plain SQL queries*][3].-->

 [1]: http://slick.typesafe.com/gettingstarted.html
 [2]: http://slick.typesafe.com/lifted-embedding.html
 [3]: http://slick.typesafe.com/sql.html  
