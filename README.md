SparkCoreDemo
=============

Objective-C class to wrap Spark api for use with Mac iOS and  OS X

The SparkCore class has methods to create a SparkCore object with a device ID and an access token. This can be done
locally, by passing your hard codded values for device ID and access token, or those values can be downloaded from 
the cloud using your login user name and password. If you have multiple cores, you can create instances of those cores
by name. The methods also allow you to use any of your acccess tokens or create new ones when you instantiate a core.

Once you have the SparkCore object, you can access Spark.variables() and Spark.function() using block based methods
that utilize NSURLRequest and NSURLConnection methods. These methods are documented in the SparkCore.h file.

The demo project gives an example of how to use the methods to read a value and call a Spark.function(). To use the
methods in your own app, you only need to copy the SparkCore.h and SparkCore.m files into yourXcode  project.
 
