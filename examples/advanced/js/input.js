(function( exports ) {

	"use strict";

	// I return the initials for the given name.
	function getInitials( name ) {

		// Clean up the name.
		name = trim( ucase( name ) );

		if ( ! name ) {

			console.warn( "Empty string passed into getInitials()" );

			return( name );

		}

		var parts = name.split( /\s+/i );

		// If there is more than one part, then 
		if ( parts.length > 1 ) {

			return(
				parts[ 0 ].slice( 0, 1 ) + 
				parts[ parts.length - 1 ].slice( 0, 1 )
			);

		}

		// If there was only one part, return the first initial.
		return( parts[ 0 ].slice( 0, 1 ) );

	}


	// Export the get-initials method. By using a string to define the 
	// name, we can ensure that the Closure compiler will not mangle
	// the name of the method.
	exports[ "getInitials" ] = getInitials;

})( window );