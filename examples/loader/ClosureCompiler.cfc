<cfscript>

component
	extends = "lib.ClosureCompiler"
	output = false
	hint = "I extend the core Closure Compiler facade, but I define the Java objects using the JavaLoader class loader."
	{

		// I return the initialized component.
	public any function init( required any classLoader ) {

		// Store the class-loader - it will be used to create the Java objects within the Google
		// Closure Compiler library.
		// --
		// NOTE: This has to be called BEFORE the super-init since the Java classes are loaded 
		// within the body of the init method.
		variables.classLoader = classLoader;

		super.init();

		return( this );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I create and return the command line runner Java class.
	private any function createCommandLineRunner() {

		return(
			classLoader.create( "com.google.javascript.jscomp.CommandLineRunner" )
		);

	}


	// I create and return the compilation level Java class.
	private any function createCompilationLevel() {

		return(
			classLoader.create( "com.google.javascript.jscomp.CompilationLevel" )
		);

	}


	// I create and return the compiler Java object.
	private any function createCompiler() {

		return(
			classLoader.create( "com.google.javascript.jscomp.Compiler" ).init()
		);

	}


	// I create and return the compiler options Java object.
	private any function createCompilerOptions() {

		return(
			classLoader.create( "com.google.javascript.jscomp.CompilerOptions" ).init()
		);

	}


	// I create and return the source file Java class.
	private any function createSourceFile() {

		return(
			classLoader.create( "com.google.javascript.jscomp.SourceFile" )
		);

	}

}

</cfscript>