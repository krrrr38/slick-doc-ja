Slick 1.0.0 documentation - 07 Slick Extensions
<!--Slick Extensions — Slick 1.0.0 documentation-->

[Permalink to Slick Extensions — Slick 1.0.0 documentation](http://slick.typesafe.com/doc/1.0.0/extensions.html)

Slick Extensions
=================

OracleのためのSlickドライバー（ **com.typesafe.slick.driver.oracle.OracleDriver** ）とDB2（ **com.typesafe.slick.driver.db2.DB2Driver** ）は， Typesafe社によって商用サポートされたパッケージである，*slick-extensions* において利用する事が出来る．[Typesafe Subscription Agreement][1] (PDF)の諸条件の元，利用可能である．


<!--Slick drivers for Oracle (**com.typesafe.slick.driver.oracle.OracleDriver**) and DB2 (**com.typesafe.slick.driver.db2.DB2Driver**) are available in *slick-extensions*, a closed-source package package with commercial support provided by Typesafe, Inc. It is made available under the terms and conditions of the [Typesafe Subscription Agreement][1] (PDF).-->

もし[sbt][2]を用いているのならば， Typesafeのリポジトリを用いるために次のように記述すれば良い．

<!--If you are using [sbt][2], you can add *slick-extensions* and the Typesafe repository (which contains the required artifacts) to your build definition like this:-->

```scala
// Use the right Slick version here:
libraryDependencies += "com.typesafe.slick" %% "slick-extensions" % "1.0.0"
resolvers += "Typesafe Releases" at "http://repo.typesafe.com/typesafe/maven-releases/"
```

 [1]: http://typesafe.com/public/legal/TypesafeSubscriptionAgreement-v1.pdf
 [2]: http://www.scala-sbt.org/  
