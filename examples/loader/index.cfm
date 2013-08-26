<cfscript>


	// Create / reterive the Java Loader.
	javaLoader = new vendor.javaloader.javaloader.JavaLoader([
		expandPath( "../../vendor/compiler/compiler.jar" )
	]);

	// Create our Closure compiler facade using the JavaLoader as 
	// our means to instantiate the various Google Closure compiler 
	// classes. Notice that this "ClosureCompiler" is local to the 
	// directory, but EXTENDS the core library.
	compiler = new ClosureCompiler( javaLoader );

	// Configure the compiler for simply optimizations and get code.
	code = compiler
		.setPrettyPrint( true )
		.useSimpleOptimizations()
		.addJavaScriptFile( expandPath( "./js/input.js" ) )
		.stripConsoleDebugging()
		.compile()
	;
	
	// Output the compiled code (remember, we have pretty-print on).
	writeOutput( 
		"<pre>" & 
			htmlEditFormat( code ) &
		"</pre>"
	);

	// If there were any arrors, output them.
	for ( error in compiler.getErrors() ) {

		writeDump( error.toString() );

	}


</cfscript>

<!--- Try to consume the compiled script. --->
<script type="text/javascript" src="./js/extern.js"></script>
<script type="text/javascript">


	// Include the code we compiled.
	<cfoutput>#code#</cfoutput>

	console.log( 
		"tricia ann smith ...", 
		getInitials( "tricia ann smith" )
	);


</script>