
# ClosureCompiler.cfc - A ColdFusion Facade For Google's Closure Compiler

by [Ben Nadel][1]

After blogging about [calling the Closure Compiler from ColdFusion][4], I 
thought it would be useful to create a ColdFusion facade to the underlying
collection of Java objects. This is not meant to be some one-to-one wrapper;
rather, it's meant to greatly simplify the interaction with the Closure 
Compiler such that you don't even realize that multiple Java objects are being
consumed behind the scenes.

Since my experience with the Closure Compiler is fairly limited, I am sure 
there are use-cases that I have not even considered yet. That said, here are 
the methods that the ClosureCompiler.cfc exposes. 

## Public Methods

Unless otherwise noted, these methods return a reference to the 
ClosureCompiler.cfc such that they can be easily chained together.

* addExternContent( filename, content )
* addExternFile( filepath )
* addJavaScriptContent( filename, content )
* addJavaScriptDirectory( directoryPath [, filter = "\.js$" ] )
* addJavaScriptFile( filepath )
* compile() :: String
* getErrors() :: Array
* getWarnings() :: Array
* hasErrors() :: Boolean
* hasWarnings() :: Boolean
* setInputDelimiter( inputDelimiter ) 
* setPrettyPrint( isPrettyPrint ) 
* stripConsoleDebugging() 
* stripNamePrefix( namePrefix )
* stripNamePrefixes( namePrefixes )
* stripNameSuffix( nameSuffix )
* stripNameSuffixes( nameSuffixes )
* stripType( type )
* stripTypePrefix( typePrefix )
* stripTypePrefixes( typePrefixes )
* stripTypes( types )
* useAdvancedOptimizations()
* useDefaultExterns()
* useSimpleOptimizations()
* useWhiteSpaceOptimizations()

## Levels of Optimization

Of the methods listed above, these three are specifically meant to turn on and 
off compilation options based on levels of aggressiveness:

* useAdvancedOptimizations()
* useSimpleOptimizations()
* useWhiteSpaceOptimizations()

These methods are meant to be used independently; you wouldn't want to call 
more than one of these three methods for any particular compilation event. 

## Using An External Class Loader

While most of the examples in this project assume that the Google Closure 
compiler classes are part of the default class loader, the "loader" example
uses [Mark Mandel's JavaLoader library][3] to load the JAR files on the fly
from your local file system.

This example works by extending the core ClosureCompiler.cfc component and then
overriding the methods instantiate the underlying Java objects. All creation of
Java objects are isolated within individual private methods such that they any
type of class loader can be used.

### Note About CFScript Tags

The ColdFusion components in this project are written using CFScript tags.
These tags are not required for the ColdFusion component to compile and
work properly. I have included them because they make the color-coding work
properly in GitHub. Please feel free to remove them if you like.


[1]: http://www.bennadel.com
[2]: http://javadoc.closure-compiler.googlecode.com/git/index.html
[3]: https://github.com/markmandel/JavaLoader
[4]: http://www.bennadel.com/blog/2511-Calling-The-Closure-Compiler-From-ColdFusion-And-Java.htm
