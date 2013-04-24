Slick 1.0.0 documentation - 02 始めよう
<!--Getting Started — Slick 1.0.0 documentation-->

[Permalink to Getting Started — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/gettingstarted.html)

# Getting Started

The easiest way of setting up a Slick application is by starting with the [Slick Examples][1] project. You can build and run this project by following the instructions in its README file.

## Dependencies

Let’s take a closer look at what’s happening in that project. First of all, you need to add Slick and the embedded databases or drivers for external databases to your project. If you are using [sbt][2], you do this in your main build.sbt file:

```scala
    libraryDependencies ++= List(
      // use the right Slick version here:
      "com.typesafe.slick" %% "slick" % "1.0.0",
      "org.slf4j" % "slf4j-nop" % "1.6.4",
      "com.h2database" % "h2" % "1.3.166"
    )
```

Slick uses [SLF4J][3] for its own debug logging so you also need to add an SLF4J implementation. Here we are using slf4j-nop to disable logging. You have to replace this with a real logging framework like [Logback][4] if you want to see log output.

## Imports

[Slick example lifted/FirstExample][5] contains a self-contained application that you can run. It starts off with some imports:

```scala
    // Use H2Driver to connect to an H2 database
    import scala.slick.driver.H2Driver.simple._
    
    // Use the implicit threadLocalSession
    import Database.threadLocalSession
``` 

Since we are using [H2][6] as our database system, we need to import features from Slick’s H2Driver. A driver’s simple object contains all commonly needed imports from the driver and other parts of Slick such as [*session handling*][7]. The only extra import we use is the threadLocalSession. This simplifies the session handling by attaching a session to the current thread so you do not have to pass it around on your own (or at least assign it to an implicit variable).

## Database Connection

In the body of the application we create a Database object which specifies how to connect to a database, and then immediately open a session, running all code within the following block inside that session:

```scala
    Database.forURL("jdbc:h2:mem:test1", driver = "org.h2.Driver") withSession {
      // The session is never named explicitly. It is bound to the current
      // thread as the threadLocalSession that we imported
    }
```

In a Java SE environment, database sessions are usually created by connecting to a JDBC URL using a JDBC driver class (see the JDBC driver’s documentation for the correct URL syntax). If you are only using [*plain SQL queries*][8], nothing more is required, but when Slick is generating SQL code for you (using the [*direct embedding*][9] or the [*lifted embedding*][10]), you need to make sure to use a matching Slick driver (in our case the H2Driver import above).

## Schema

We are using the [*lifted embedding*][10] in this application, so we have to write Table objects for our database tables:

```scala
    // Definition of the SUPPLIERS table
    object Suppliers extends Table[(Int, String, String, String, String, String)]("SUPPLIERS") {
      def id = column[Int]("SUP_ID", O.PrimaryKey) // This is the primary key column
      def name = column[String]("SUP_NAME")
      def street = column[String]("STREET")
      def city = column[String]("CITY")
      def state = column[String]("STATE")
      def zip = column[String]("ZIP")
      // Every table needs a * projection with the same type as the table's type parameter
      def * = id ~ name ~ street ~ city ~ state ~ zip
    }
    
    // Definition of the COFFEES table
    object Coffees extends Table[(String, Int, Double, Int, Int)]("COFFEES") {
      def name = column[String]("COF_NAME", O.PrimaryKey)
      def supID = column[Int]("SUP_ID")
      def price = column[Double]("PRICE")
      def sales = column[Int]("SALES")
      def total = column[Int]("TOTAL")
      def * = name ~ supID ~ price ~ sales ~ total
      // A reified foreign key relation that can be navigated to create a join
      def supplier = foreignKey("SUP_FK", supID, Suppliers)(_.id)
    }
```

All columns get a name (usually in camel case for Scala and upper case with underscores for SQL) and a Scala type (from which the SQL type can be derived automatically). Make sure to define them with def and not with val. The table object also needs a Scala name, SQL name and type. The type argument of the table must match the type of the special * projection. In simple cases this is a tuple of all columns but more complex mappings are possible.

The foreignKey definition in the Coffees table ensures that the supID field can only contain values for which a corresponding id exists in the Suppliers table, thus creating an *n to one* relationship: A Coffees row points to exactly one Suppliers row but any number of coffees can point to the same supplier. This constraint is enforced at the database level.

## Populating the Database

The connection to the embedded H2 database engine provides us with an empty database. Before we can execute queries, we need to create the database schema (consisting of the Coffees and Suppliers tables) and insert some test data:

```scala
    // Create the tables, including primary and foreign keys
    (Suppliers.ddl ++ Coffees.ddl).create
    
    // Insert some suppliers
    Suppliers.insert(101, "Acme, Inc.",      "99 Market Street", "Groundsville", "CA", "95199")
    Suppliers.insert( 49, "Superior Coffee", "1 Party Place",    "Mendocino",    "CA", "95460")
    Suppliers.insert(150, "The High Ground", "100 Coffee Lane",  "Meadows",      "CA", "93966")
    
    // Insert some coffees (using JDBC's batch insert feature, if supported by the DB)
    Coffees.insertAll(
      ("Colombian",         101, 7.99, , ),
      ("French_Roast",       49, 8.99, , ),
      ("Espresso",          150, 9.99, , ),
      ("Colombian_Decaf",   101, 8.99, , ),
      ("French_Roast_Decaf", 49, 9.99, , )
    )
```

The tables’ **ddl** methods create **DDL** (data definition language) objects with the database-specific code for creating and dropping tables and other database entities. Multiple **DDL** values can be combined with **++** to allow all entities to be created and dropped in the correct order, even when they have circular dependencies on each other.

Inserting the tuples of data is done with the **insert** and **insertAll** methods. Note that by default a database Session is in *auto-commit* mode. Each call to the database like insert or insertAll executes atomically in its own transaction (i.e. it succeeds or fails completely but can never leave the database in an inconsistent state somewhere in between). In this mode we we have to populate the Suppliers table first because the Coffees data can only refer to valid supplier IDs.

We could also use an explicit transaction bracket encompassing all these statements. Then the order would not matter because the constraints are only enforced at the end when the transaction is committed.

## Querying

The simplest kind of query iterates over all the data in a table:

```scala
    // Iterate through all coffees and output them
    Query(Coffees) foreach { case (name, supID, price, sales, total) =>
      println("  " + name + "t" + supID + "t" + price + "t" + sales + "t" + total)
    }
```    

This corresponds to a SELECT * FROM COFFEES in SQL (except that the * is the table’s * projection we defined earlier and not whatever the database sees as *). The type of the values we get in the loop is, unsurprisingly, the type parameter of Coffees.

Let’s add a *projection* to this basic query. This is written in Scala with the map method or a *for comprehension*:

```scala
    // Why not let the database do the string conversion and concatenation?
val q1 = for(c <- Coffees) // Coffees lifted automatically to a Query
  yield ConstColumn("  ") ++ c.name ++ "\t" ++ c.supID.asColumnOf[String] ++
    "\t" ++ c.price.asColumnOf[String] ++ "\t" ++ c.sales.asColumnOf[String] ++
    "\t" ++ c.total.asColumnOf[String]
// The first string constant needs to be lifted manually to a ConstColumn
// so that the proper ++ operator is found
q1 foreach println
```

The output will be the same: For each row of the table, all columns get converted to strings and concatenated into one tab-separated string. The difference is that all of this now happens inside the database engine, and only the resulting concatenated string is shipped to the client. Note that we avoid Scala’s + operator (which is already heavily overloaded) in favor of ++ (commonly used for sequence concatenation). Also, there is no automatic conversion of other argument types to strings. This has to be done explicitly with the type conversion method asColumnOf.

Joining and filtering tables is done the same way as when working with Scala collections:

```scala
// Perform a join to retrieve coffee names and supplier names for
// all coffees costing less than $9.00
val q2 = for {
  c <- Coffees if c.price < 9.0
  s <- Suppliers if s.id === c.supID
} yield (c.name, s.name)
```

Note the use of === instead of == for comparing two values for equality. Similarly, the lifted embedding uses =!= instead of != for inequality. (The other comparison operators are the same as in Scala: <, <=, >=, >.)

The generator expression Suppliers if s.id === c.supID follows the relationship established by the foreign key Coffees.supplier. Instead of repeating the join condition here we can use the foreign key directly:

```scala
val q3 = for {
  c <- Coffees if c.price < 9.0
  s <- c.supplier
} yield (c.name, s.name)
```

[1]: https://github.com/slick/slick-examples/tree/1.0.0
[2]: http://www.scala-sbt.org/
[3]: http://www.slf4j.org/
[4]: http://logback.qos.ch/
[5]: https://github.com/slick/slick-examples/blob/1.0.0/src/main/scala/com/typesafe/slick/examples/lifted/FirstExample.scala
[6]: http://h2database.com/
[7]: http://slick.typesafe.com/doc/1.0.0/session.html
[8]: http://slick.typesafe.com/doc/1.0.0/sql.html
[9]: http://slick.typesafe.com/doc/1.0.0/direct-embedding.html
[10]: http://slick.typesafe.com/doc/1.0.0/lifted-embedding.html
