<cfscript>
	

	// Create our Closure compiler facade.
	compiler = new lib.ClosureCompiler();

	// Configure the compiler and get code. Because we are only 
	// using SIMPLE optimizations, we don't have to worry about any
	// of the external dependencies - the Closure compiler will not
	// be so aggressive with renaming.
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