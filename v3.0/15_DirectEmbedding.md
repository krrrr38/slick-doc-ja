Slick 3.0.0 documentation - 15 Direct Embedding (Deprecated)

[Permalink to Direct Embedding (Deprecated) — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/direct-embedding.html)

Direct Embedding (Deprecated)
=============================

> DirectEmbeddingはSlick1.0の頃に加えられた、実験的なクエリAPIであったが、バージョン3.0より非推奨となった。この機能はバージョン3.1に削除される予定だ。プロダクション環境などでは、Slickの標準的なクエリAPIを利用して欲しい。
<!-- Deprecated since version 3.0: The direct embedding is an experimental Query API that was added in Slick 1.0. It is deprecated in 3.0 and will be removed in 3.1. You should only use Slick’s standard Scala query API for any kind of production use. -->

（非推奨のAPIについての説明となるため、本章は翻訳していない。）

Unlike the standard API, the direct embedding uses macros instead of operator overloading and implicit conversions for its implementation. For a user the difference in the code is small, but queries using the direct embedding work with ordinary Scala types, which can make error messages easier to understand.

Dependencies
------------

The direct embedding requires access to the Scala compiler at runtime for typechecking. Slick only declares an *optional* dependency on scala-compiler in order to avoid bringing it (along with all transitive dependencies) into your application if you don't need it. You must add it explicitly to your own project's `build.sbt` file if you want to use the direct embedding:

```scala
libraryDependencies <+= (scalaVersion)("org.scala-lang" % "scala-compiler" % _)
```

Imports
-------

```scala
import slick.driver.H2Driver
import H2Driver.api.{Database, DBIO}
import slick.direct._
import slick.direct.AnnotationMapper._
```

Row class and schema
--------------------

The schema description is currently provided as annotations on a case class which is used for holding rows. We will later provide more flexible and customizable means of providing the schema information.

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

Query
-----

Queryable takes an annotated case class as its type argument to formulate queries agains the corresponding table.

`_.price` is of type Int here. The underlying, macro-based implementation takes care of that the shown arguments to map and filter are not executed on the JVM but translated to database queries instead.

```scala
// query database using direct embedding
val q1 = Queryable[Coffee]
val q2 = q1.filter( _.price > 3.0 ).map( _ .name )
```

Execution
---------

To execute the queries we need to create a SlickBackend instance passing in the chosen database backend driver.

```scala
val db = Database.forConfig("h2mem1")
try {
  // execute query using a chosen db backend
  val backend = new SlickBackend( H2Driver, AnnotationMapper )
  println( Await.result(db.run(backend.result(q2)), Duration.Inf) )
  println( Await.result(db.run(backend.result(q2.length)), Duration.Inf) )
} finally db.close
```

Alternative direct embedding bound to a driver and session
----------------------------------------------------------

Using ImplicitQueryable, a queryable can be bound to a backend and session. The query can be further adapted and easily executed this way.

```scala
//
val iq1 = ImplicitQueryable( q1, backend, db )
val iq2 = iq1.filter( c => c.price > 3.0 )
println( iq2.toSeq ) //  <- triggers execution
println( iq2.length ) // <- triggers execution
```

Features
--------

The direct embedding currently only supports database columns, which can be mapped to either `String, Int, Double`.

Queryable and ImplicitQueryable currently support the following methods:

`map, flatMap, filter, length`

The methods are all immutable meaning they leave the left-hand-side Queryable unmodified, but return a new Queryable incorporating the changes by the method call.

Within the expressions passed to the above methods, the following operators may be used:

`Any: ==`

`Int, Double: + < >`

`String: +`

`Boolean: || &&`

Other operators may type check and compile ok, if they are defined for the corresponding types. They can however currently not be translated to SQL, which makes the query fail at runtime, for example: `( coffees.map( c => c.name.repr ) )`. We are evaluating ways to catch those cases at compile time in the future

Queries may result in sequences of arbitrarily nested tuples, which may also contain objects representing complete rows. E.g.

```scala
q1.map( c => (c.name, (c, c.price)) )
```
