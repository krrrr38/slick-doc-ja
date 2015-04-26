Slick 3.0.0 documentation - 14 Slick Extensions

[Permalink to Slick Extensions — Slick 3.0.0 documentation](http://slick.typesafe.com/doc/3.0.0/extensions.html)

Slick Extensions
================

<!-- Slick Extensions, a closed-source package with commercial support provided by Typesafe, Inc contains Slick drivers for:  -->

-   Oracle (`com.typesafe.slick.driver.oracle.OracleDriver`)
-   IBM DB2 (`com.typesafe.slick.driver.db2.DB2Driver`)
-   Microsoft SQL Server
    (`com.typesafe.slick.driver.ms.SQLServerDriver`)

<!-- **note** You may use it for development and testing purposes under the terms and conditions of the Typesafe Subscription Agreement\_ (PDF). Production use requires a Typesafe Subscription\_.  -->

<!-- If you are using sbt\_, you can add *slick-extensions* and the Typesafe repository (which contains the required artifacts) to your build definition like this:  -->

```scala
libraryDependencies += "com.typesafe.slick" %% "slick-extensions" % "3.0.0"
resolvers += "Typesafe Releases" at "<http://repo.typesafe.com/typesafe/maven-releases/>"
```
