
[Permalink](http://slick.typesafe.com/doc/1.0.0/direct-embedding.html "Permalink to Direct Embedding — Slick 1.0.0 documentation")

# Direct Embedding — Slick 1.0.0 documentation

The direct embedding is a new, still incomplete, experimental Query API under development. It may change without deprecation period in any release during its experimental status. There is no plan to replace the stable lifted embedding Query API, which you can safely bet on for production use. The direct embedding co-exists. Unlike the lifted embedding, the direct embedding uses macros instead of operator overloading and implicit conversions for its implementation. For a user the difference in the code is small, but queries using the direct embedding work with ordinary Scala types, which can make error messages easier to understand.

The following descriptions are anolog to the description of the [*lifted embedding*][1].

## Dependencies

The direct embedding requires access to the Scala compiler at runtime for typechecking. Slick only declares an *optional* dependency on scala-compiler in order to avoid bringing it (along with all transitive dependencies) into your application if you don’t need it. You must add it explicitly to your own project’s build.sbt file if you want to use the direct embedding:

    libraryDependencies  session}
    import scala.slick.direct._
    import scala.slick.direct.AnnotationMapper._
    

## Row class and schema

The schema description is currently provided as annotations on a case class which is used for holding rows. We will later provide more flexible and customizable means of providing the schema information.

    // describe schema for direct embedding
    @table(name="COFFEES")
    case class Coffee(
      @column(name="NAME")
      name : String,
      @column(name="PRICE")
      price : Double
    )
    

## Query

Queryable takes an annotated case class as its type argument to formulate queries agains the corresponding table.

_.price is of type Int here. The underlying, macro-based implementation takes care of that the shown arguments to map and filter are not executed on the JVM but translated to database queries instead.

    // query database using direct embedding
    val q1 = Queryable[Coffee]
    val q2 = q1.filter( _.price &gt; 3.0 ).map( _ .name )
    

## Execution

To execute the queries we need to create a SlickBackend instance passing in the chosen database backend driver.

    val db = Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver")
    db withSession {
        // execute query using a chosen db backend
        val backend = new SlickBackend( H2Driver, AnnotationMapper )
        println( backend.result( q2, session ) )
        println( backend.result( q2.length, session ) )
    }
    

## Alternative direct embedding bound to a driver and session

Using ImplicitQueryable, a queryable can be bound to a backend and session. The query can be further adapted and easily executed this way.

    //
    val iq1 = ImplicitQueryable( q1, backend, session )
    val iq2 = iq1.filter( c =&gt; c.price &gt; 3.0 )
    println( iq2.toSeq ) //   c.name.repr ) ). We are evaluating ways to catch those cases at compile time in the future

Queries may result in sequences of arbitrarily nested tuples, which may also contain objects representing complete rows. E.g.

    q1.map( c =&gt; (c.name, (c, c.price)) )
    

The direct embedding currently does not feature insertion of data. Instead you can use the [*lifted embedding*][2] or [*plain SQL queries*][3].

 [1]: http://slick.typesafe.com/gettingstarted.html
 [2]: http://slick.typesafe.com/lifted-embedding.html
 [3]: http://slick.typesafe.com/sql.html  