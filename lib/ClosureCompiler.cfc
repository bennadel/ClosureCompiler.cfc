<cfscript>

component
	output = false
	hint = "I provide a facade to Google's Closure compiler, exposing a subset of the compiler's functionality."
	{

	// I return the initialized component.
	public any function init() {

		// Create the underlying Java object to which we are providing a facade.
		compiler = createCompiler();
		compilerOptions = createCompilerOptions();
		compilationLevel = createCompilationLevel();
		commandLineRunner = createCommandLineRunner();
		sourceFile = createSourceFile();

		// Once the compilation event had taken place, this will contain the result.
		compileErrors = createList();
		compileWarnings = createList();

		// I contain the collection of inputs to compile.
		inputs = createList();

		// I contain the collection of external libraries for which to leave references in
		// the compiled code.
		externs = createList();

		// I define the types and names to remove from the compiled source code. 
		compilerOptions.stripTypes = createSet();
		compilerOptions.stripTypePrefixes = createSet();
		compilerOptions.stripNamePrefixes = createSet();
		compilerOptions.stripNameSuffixes = createSet();

		// Set the default input delimiter.
		setInputDelimiter( "/*! -- File: %name% ( Input %num% ) -- */" );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I add the given content ot the list of extern files to use in the optimization.
	public any function addExternContent(
		required string filename,
		required string content
		) {

		externs.add(
			sourceFile.fromCode(
				javaCast( "string", filename ),
				javaCast( "string", content )
			)
		);

		return( this );

	}


	// I add the given filepath to the list of extern files to use in the optimization.
	public any function addExternFile( required string filepath ) {

		return(
			addExternContent(
				getFileFromPath( filepath ), 
				fileRead( filepath, "utf-8" ) 
			)
		);

	}


	// I add the given content ot the list of files to compile.
	public any function addJavaScriptContent(
		required string filename,
		required string content
		) {

		inputs.add(
			sourceFile.fromCode(
				javaCast( "string", filename ),
				javaCast( "string", content )
			)
		);

		return( this );

	}


	// I add all the JavaScript files in the given directory (that match the given regex 
	// pattern) to the list of files to compile. The directory is searched recursively.
	// --
	// NOTE: Supports POSIX regular expression patterns.
	public any function addJavaScriptDirectory(
		required string directoryPath,
		string pattern = "\.js$"
		) {

		var files = directoryList( directoryPath, true, "path" );

		// Add each file that matches the given pattern. Only check the filename, not
		// the entire path to the file.
		for ( var filepath in files ) {

			if ( reFind( pattern, getFileFromPath( filepath ) ) ) {

				addJavaScriptFile( filepath );

			}

		}

		return( this );

	}


	// I add the given filepath to the list of files to compile.
	public any function addJavaScriptFile( required string filepath ) {

		return(
			addJavaScriptContent(
				getFileFromPath( filepath ), 
				fileRead( filepath, "utf-8" ) 
			)
		);

	}


	// I compile the already-defined list of JavaScript inputs and externs. Returns the 
	// compiled source code.
	public string function compile() {

		var newline = chr( 10 );
		var result = compiler.compile( externs, inputs, compilerOptions );

		// Store any problems that occurred during the compilation.
		addAllToCollection( compileErrors, result.errors );
		addAllToCollection( compileWarnings, result.warnings );

		// If something went wrong, then return a harmless bit of code.
		if ( arrayLen( result.errors ) ) {

			return( newline & ";/*! -- NOTE: Compilation failed. -- */" & newline );

		}

		return( compiler.toSource() );

	}


	// I get the errors from the compilation process. 
	// -- 
	// NOTE: Returns an empty array if compilation has not taken place.
	public array function getErrors() {

		return( toColdFusionArray( compileErrors ) );

	}


	// I get the warnings from the compilation process.
	// --
	// NOTE: Returns an empty array if compilation has not taken place.
	public array function getWarnings() {

		return( toColdFusionArray( compileWarnings ) );

	}


	// I determine whether or not the compilation process returned any errors.
	public boolean function hasErrors() {

		return( !! arrayLen( compileErrors ) );

	}


	// I determine whether or not the compilation process returned any warnings.
	public boolean function hasWarnings() {

		return( !! arrayLen( compileWarnings ) );

	}


	// I define the input delimiter to be included within the source before each file 
	// in the compiled source code.
	// --
	// NOTE: There input delimiter can use two different embedded symbols:
	// -- %name% : the name you provide for the input.
	// -- %num% : the index (base zero) of the input.
	public any function setInputDelimiter( required string inputDelimiter ) {

		// If the input delimiter is valid, then make sure to turn the feature on. If not,
		// turn the feature off.
		compilerOptions.setPrintInputDelimiter( 
			javaCast( "boolean", !! len( inputDelimiter ) ) 
		);

		compilerOptions.setInputDelimiter( javaCast( "string", inputDelimiter ) );

		return( this );

	}


	// I turn on and off the pretty-print formatting of the compiled source-code. The pretty-
	// print mode uses white-space and indentiation to make the code more human-readable.
	public any function setPrettyPrint( required boolean isPrettyPrint ) {

		compilerOptions.setPrettyPrint( javaCast( "boolean", isPrettyPrint ) );

		return( this );

	}


	// I strip out the common references to console debugging like "console.log" and 
	// "console.warn" from the compiled code. The list being used is the one defined by Mozilla
	// Developer Network: https://developer.mozilla.org/en-US/docs/Web/API/console
	public any function stripConsoleDebugging() {

		var consoleMethods = [ "debug", "dir", "error", "group", "groupCollapsed", "groupEnd", "info", "log", "time", "timeEnd", "trace", "warn" ];

		// Strip out both the implied and explicit global object references.
		for ( var methodName in consoleMethods ) {

			stripType( "console.#methodName#" );
			stripType( "window.console.#methodName#" );
			
		}
		
		return( this );

	}


	// I remove the given name prefix from the compiled code. This includes all keys that start
	// with the given prefix, but does not include types that start with the given prefix. For
	// example, the name prefix of, "call", will remove all of the following references from the
	// compiled code:
	// -- "phone.call()"
	// -- "phone.call.duration"
	// -- "window.alert.call()"
	// However, the above will NOT remove the following references since they are not keys within
	// an explicit scope:
	// -- "caller"
	// -- "callHome()"
	public any function stripNamePrefix( required string namePrefix ) {

		compilerOptions.stripNamePrefixes.add( javaCast( "string", namePrefix ) );

		return( this );

	}


	// I remove all of the given name prefixes from the compiled code.
	public any function stripNamePrefixes( required array namePrefixes ) {

		for ( var namePrefix in namePrefixes ) {

			stripNamePrefix( namePrefix );

		}

		return( this );

	}


	// I remove the given name suffix from the compiled code. This includes all keys that end
	// with the given suffix, but does not include types that end with the given suffix. For
	// example, the name suffix of, "call", will remove all of the following references from the
	// compiled code:
	// -- "phone.call()"
	// -- "system.incomingCall"
	// However, the above will NOT remove the following references since they are not keys within
	// an explicit scope:
	// -- "call"
	// -- "makeCall()"
	public any function stripNameSuffix( required string nameSuffix ) {

		compilerOptions.stripNameSuffixes.add( javaCast( "string", nameSuffix ) );

		return( this );

	}


	// I remove all of the given name suffixes from the compiled code.
	public any function stripNameSuffixes( required array nameSuffixes ) {

		for ( var nameSuffix in nameSuffixes ) {

			stripNameSuffix( nameSuffix );

		}

		return( this );

	}


	// I remove the given type from the compiled code. This includes references to the specific 
	// type as well as references to keys off of the given type. For example, the type name of,
	// "console", will remove all of the following references from the compiled code:
	// -- "console"
	// -- "console.log()"
	// -- "console.log.apply()"
	// However, the above will NOT remove the following references, due to the "window" prefix.
	// -- "window.console.log"
	public any function stripType( required string type ) {

		compilerOptions.stripTypes.add( javaCast( "string", type ) );

		return( this );

	}


	// I remove the given type-prefix from the compiled code. This does not require the matching
	// of complete identifiers (at the end of the prefix). For example, the type prefix name of,
	// "console.time", will remove all of the following references from the compiled code:
	// -- "console.time"
	// -- "console.timeEnd"
	// However, the above will NOT remove the following references, due to the "Window" prefix.
	// -- "window.console.time"
	public any function stripTypePrefix( required string typePrefix ) {

		compilerOptions.stripTypePrefixes.add( javaCast( "string", typePrefix ) );

		return( this );

	}


	// I remove all of the given type prefixes from the compiled code.
	public any function stripTypePrefixes( required array typePrefixes ) {

		for ( var typePrefix in typePrefixes ) {

			stripTypePrefix( typePrefix );

		}

		return( this );

	}


	// I remove all of the given types from the compiled code.
	public any function stripTypes( required array types ) {

		for ( var type in types ) {

			stripType( type );

		}

		return( this );

	}


	// I turn on the simple optimizations for the compiler. ADVANCED_OPTIMIZATIONS 
	// aggressively reduces code size by renaming function names and variables, removing 
	// code which is never called, etc.
	// --
	// NOTE: Does not affect unrelated options.
	public any function useAdvancedOptimizations() {

		compilationLevel.ADVANCED_OPTIMIZATIONS.setOptionsForCompilationLevel( compilerOptions );

		return( this );

	}


	// I add the list of externals used by the common JavaScript runtime. This is a massive
	// list (~25,000 lines of definitions) and contains everything from "alert" to "console.log",
	// to "Object.prototype.hasOwnProperty". 
	// --
	// NOTE: You really only need to use this if you are using ADVANCED optimizations.
	public any function useDefaultExterns() {

		externs.addAll( commandLineRunner.getDefaultExterns() );

		return( this );

	}


	// I turn on the simple optimizations for the compiler. SIMPLE_OPTIMIZATIONS performs 
	// transformations to the input JS that do not require any changes to JS that depend 
	// on the input JS. For example, function arguments are renamed (which should not 
	// matter to code that depends on the input JS), but functions themselves are not 
	// renamed (which would otherwise require external code to change to use the renamed
	// function names).
	// --
	// NOTE: Does not affect unrelated options.
	public any function useSimpleOptimizations() {

		compilationLevel.SIMPLE_OPTIMIZATIONS.setOptionsForCompilationLevel( compilerOptions );

		return( this );

	}


	// I turn on the white-space optimizations for the compiler. WHITESPACE_ONLY removes 
	// comments and extra whitespace in the input JS.
	// --
	// NOTE: Does not affect unrelated options. 
	public any function useWhiteSpaceOptimizations() {

		compilationLevel.WHITESPACE_ONLY.setOptionsForCompilationLevel( compilerOptions );

		return( this );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I add all the given values to the list. This is used in situations where an 
	// array, not a collection, is being appended.
	private any function addAllToCollection(
		required any collection,
		required any values
		) {

		// NOTE: We are using an index-loop here since ColdFusion 9 doesn't seem to want
		// to iterate over Java arrays with a for-in loop.
		for ( var i = 1 ; i <= arrayLen( values ) ; i++ ) {

			collection.add( values[ i ] );

		}

		return( collection );

	}


	// I create and return the command line runner Java class.
	private any function createCommandLineRunner() {

		// NOTE: This object is not initialized since we are only using the static 
		// properties and methods on the class.
		return(
			createObject( "java", "com.google.javascript.jscomp.CommandLineRunner" )
		);

	}


	// I create and return the compilation level Java class.
	private any function createCompilationLevel() {

		// NOTE: This object is not initialized since we are only using the static
		// properties and methods on the class.
		return(
			createObject( "java", "com.google.javascript.jscomp.CompilationLevel" )
		);

	}


	// I create and return the compiler Java object.
	private any function createCompiler() {

		return(
			createObject( "java", "com.google.javascript.jscomp.Compiler" ).init()
		);

	}


	// I create and return the compiler options Java object.
	private any function createCompilerOptions() {

		return(
			createObject( "java", "com.google.javascript.jscomp.CompilerOptions" ).init()
		);

	}


	// I create and return a List Java object.
	private any function createList() {

		var arrayList = createObject( "java", "java.util.ArrayList" ).init();

		if ( arrayLen( arguments ) ) {

			arrayList.addAll( arguments );

		}

		return( arrayList );

	}


	// I create and return a Set Java object.
	private any function createSet() {

		var hashSet = createObject( "java", "java.util.HashSet" ).init();

		if ( arrayLen( arguments ) ) {

			hashSet.addAll( arguments );

		}

		return( hashSet );

	}


	// I create and return the source file Java class.
	private any function createSourceFile() {

		// NOTE: This object is not initialized since we are only using the static
		// properties and methods on the class.
		return(
			createObject( "java", "com.google.javascript.jscomp.SourceFile" )
		);

	}


	// I convert the given collection to a native ColdFusion array.
	private array function toColdFusionArray( required any collection ) {

		var array = [];

		array.addAll( collection );

		return( array );

	}

}

</cfscript>