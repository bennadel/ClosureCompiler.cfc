
# ClosureCompiler.cfc - A ColdFusion Facade For Google's Closure Compiler

by [Ben Nadel][1]

## Using An External Class Loader

While most of the examples in this project assume that the Google Closure 
compiler classes are part of the default class loader, the "loader" example
uses [Mark Mandel's JavaLoader library][3] to load the JAR files on the fly
from your local file system.

### Note About CFScript Tags

The ColdFusion components in this project as written using CFScript tags.
These tags are not required for the ColdFusion component to compile and
work properly. I have included them because they make the color-coding work
properly in GitHub. Please feel free to remove them if you like.


[1]: http://www.bennadel.com
[2]: http://javadoc.closure-compiler.googlecode.com/git/index.html
[3]: https://github.com/markmandel/JavaLoader