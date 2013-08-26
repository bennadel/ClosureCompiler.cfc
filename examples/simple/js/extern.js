(function( exports ) {

	"use strict";

	// Trim leading and trailing white space.
	exports.trim = function( value ) {

		return( 
			value.replace( /^\s+|\s+$/g, "" )
		);

	};


	// Convert value to uppercase.
	exports.ucase = function( value ) {

		return( value.toUpperCase() );

	};

})( window );