(function( exports ) {

	"use strict";

	// I return the initials for the given name.
	// --
	// NOTE: Because we are using SIMPLE OPTIMIZATIONS for this example, we
	// don't have to take any special care with the naming - we can use standard
	// dot-notation, rather than array notation.
	exports.getInitials = function( name ) {

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

	};

})( window );