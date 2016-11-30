(function(factory) {
	"use strict";
	/* global define, module, window */
	if (typeof define === 'function' && define.amd) {
		define([], factory);
	} else if (typeof module !== 'undefined') {
		module.exports = factory();
	} else if (typeof window !== 'undefined') {
		var m = factory();
		for (var prop in m) {
			if (m.hasOwnProperty(prop)) window[prop] = m[prop];
		}
	}
})(function() {
"use strict";

function Set_Transverse_Mercator_Parameters(
	TranMerc_a, TranMerc_f, TranMerc_Origin_Lat, Central_Meridian,
	TranMerc_False_Easting, TranMerc_False_Northing, TranMerc_Scale_Factor
) {
	var MAX_LAT = ((Math.PI * 89.99)/180.0);
	var MAX_DELTA_LONG = ((Math.PI * 90)/180.0);

	/* ---- Parameters ---- */
	if (Central_Meridian > Math.PI) {
		Central_Meridian -= 2*Math.PI;
	}
	var TranMerc_Origin_Long = Central_Meridian;
	/* Eccentricity Squared */
	var TranMerc_es = 2 * TranMerc_f - TranMerc_f * TranMerc_f;
	/* Second Eccentricity Squared */
	var TranMerc_ebs = (1 / (1 - TranMerc_es)) - 1;

	var TranMerc_b = TranMerc_a * (1 - TranMerc_f);
	/* True meridianal constants */
	var tn = (TranMerc_a - TranMerc_b) / (TranMerc_a + TranMerc_b);
	var tn2 = tn * tn;
	var tn3 = tn2 * tn;
	var tn4 = tn3 * tn;
	var tn5 = tn4 * tn;

	var TranMerc_ap = TranMerc_a * (1.0 - tn + 5.0 * (tn2 - tn3)/4.0 +
		81.0 * (tn4 - tn5)/64.0 );
	var TranMerc_bp = 3.0 * TranMerc_a * (tn - tn2 + 7.0 * (tn3 - tn4) /
		8.0 + 55.0 * tn5/64.0 )/2.0;
	var TranMerc_cp = 15.0 * TranMerc_a * (tn2 - tn3 + 3.0 * (tn4 - tn5 )/4.0) /16.0;
	var TranMerc_dp = 35.0 * TranMerc_a * (tn3 - tn4 + 11.0 * tn5 / 16.0) / 48.0;
	var TranMerc_ep = 315.0 * TranMerc_a * (tn4 - tn5) / 512.0;

	function SPHTMD(Latitude) {
		return TranMerc_ap * Latitude -
			TranMerc_bp * Math.sin(2.0 * Latitude) + TranMerc_cp * Math.sin(4.0 * Latitude) -
			TranMerc_dp * Math.sin(6.0 * Latitude) + TranMerc_ep * Math.sin(8.0 * Latitude);
	}

	function SPHSN(Latitude) {
		return TranMerc_a / Math.sqrt(1.0 - TranMerc_es * Math.pow(Math.sin(Latitude), 2));
	}

	function DENOM(Latitude) {
		return Math.sqrt(1.0 - TranMerc_es * Math.pow(Math.sin(Latitude),2));
	}

	function SPHSR(Latitude) {
		return TranMerc_a * (1.0 - TranMerc_es) / Math.pow(DENOM(Latitude), 3);
	}

	function Convert_Geodetic_To_Transverse_Mercator(Latitude, Longitude) {
		if (Longitude > Math.PI) Longitude -= 2 * Math.PI;
		if (
			(Longitude < (TranMerc_Origin_Long - MAX_DELTA_LONG)) ||
			(Longitude > (TranMerc_Origin_Long + MAX_DELTA_LONG))
		) {
			var temp_Long = (Longitude < 0) ?
				(Longitude + 2 * Math.PI) : Longitude;
			var temp_Origin = (TranMerc_Origin_Long < 0) ?
				(TranMerc_Origin_Long + 2 * Math.PI) :
				TranMerc_Origin_Long;
			if (
				(temp_Long < (temp_Origin - MAX_DELTA_LONG)) ||
				(temp_Long > (temp_Origin + MAX_DELTA_LONG))
			) {
				throw new Error("TRANMERC_LON_ERROR");
			}
		}

		var dlam = Longitude - TranMerc_Origin_Long;
		//if (Math.abs(dlam) > (9.0 * Math.PI / 180)) {
			// Distortion will result if Longitude is more than 9 degrees from the Central Meridian
		//	console.log("TRANMERC_LON_WARNING");
		//}

		if (dlam > Math.PI) dlam -= (2 * Math.PI);
		if (dlam < -Math.PI) dlam += (2 * Math.PI);
		if (Math.abs(dlam) < 2e-10) dlam = 0.0;

		var s = Math.sin(Latitude);
		var c = Math.cos(Latitude);
		var c2 = c * c;
		var c3 = c2 * c;
		var c5 = c3 * c2;
		var c7 = c5 * c2;
		var t = Math.tan(Latitude);
		var tan2 = t * t;
		var tan3 = tan2 * t;
		var tan4 = tan3 * t;
		var tan5 = tan4 * t;
		var tan6 = tan5 * t;
		var eta = TranMerc_ebs * c2;
		var eta2 = eta * eta;
		var eta3 = eta2 * eta;
		var eta4 = eta3 * eta;

		/* radius of curvature in prime vertical */
		var sn = SPHSN(Latitude);

		/* True Meridianal Distances */
		var tmd = SPHTMD(Latitude);

		/*  Origin  */
		var tmdo = SPHTMD(TranMerc_Origin_Lat);

		/* northing */
		var t1 = (tmd - tmdo) * TranMerc_Scale_Factor;
		var t2 = sn * s * c * TranMerc_Scale_Factor/ 2.0;
		var t3 = sn * s * c3 * TranMerc_Scale_Factor * (5.0 - tan2 + 9.0 * eta +
			4.0 * eta2) /24.0;

		var t4 = sn * s * c5 * TranMerc_Scale_Factor * (61.0 - 58.0 * tan2 +
			tan4 + 270.0 * eta - 330.0 * tan2 * eta + 445.0 * eta2 +
			324.0 * eta3 -680.0 * tan2 * eta2 + 88.0 * eta4 -
			600.0 * tan2 * eta3 - 192.0 * tan2 * eta4) / 720.0;

		var t5 = sn * s * c7 * TranMerc_Scale_Factor * (1385.0 - 3111.0 *
			tan2 + 543.0 * tan4 - tan6) / 40320.0;

		var Northing = TranMerc_False_Northing + t1 + Math.pow(dlam,2.0) * t2 +
			Math.pow(dlam,4.0) * t3 + Math.pow(dlam,6.0) * t4 +
			Math.pow(dlam,8.0) * t5;

		/* Easting */
		var t6 = sn * c * TranMerc_Scale_Factor;
		var t7 = sn * c3 * TranMerc_Scale_Factor * (1.0 - tan2 + eta ) /6.0;
		var t8 = sn * c5 * TranMerc_Scale_Factor * (5.0 - 18.0 * tan2 + tan4 +
			14.0 * eta - 58.0 * tan2 * eta + 13.0 * eta2 + 4.0 * eta3 -
			64.0 * tan2 * eta2 - 24.0 * tan2 * eta3 )/ 120.0;
		var t9 = sn * c7 * TranMerc_Scale_Factor * ( 61.0 - 479.0 * tan2 +
			179.0 * tan4 - tan6 ) /5040.0;

		var Easting = TranMerc_False_Easting + dlam * t6 + Math.pow(dlam,3.0) * t7 +
			Math.pow(dlam,5.0) * t8 + Math.pow(dlam,7.0) * t9;

		return [ Easting, Northing ];
	}

	var r = Convert_Geodetic_To_Transverse_Mercator(
		MAX_LAT, MAX_DELTA_LONG + Central_Meridian
	);
	var TranMerc_Delta_Northing = r[1] + 1;
	r = Convert_Geodetic_To_Transverse_Mercator(
		0, MAX_DELTA_LONG + Central_Meridian
	);
	var TranMerc_Delta_Easting = r[0] + 1;

	function Convert_Transverse_Mercator_To_Geodetic(Easting, Northing) {
		if (
			(Easting < (TranMerc_False_Easting - TranMerc_Delta_Easting)) ||
			(Easting > (TranMerc_False_Easting + TranMerc_Delta_Easting))
		) {
			throw new Error("TRANMERC_EASTING_ERROR");
		}
		if (
			(Northing < (TranMerc_False_Northing - TranMerc_Delta_Northing)) ||
			(Northing > (TranMerc_False_Northing + TranMerc_Delta_Northing))
		) {
			throw new Error("TRANMERC_NORTHING_ERROR");
		}

		/* True Meridional Distances for latitude of origin */
		var tmdo = SPHTMD(TranMerc_Origin_Lat);

		/*  Origin  */
		var tmd = tmdo + (Northing - TranMerc_False_Northing) / TranMerc_Scale_Factor;

		/* First Estimate */
		var sr = SPHSR(0.0);
		var ftphi = tmd/sr;
		var t10;

		for (var i = 0; i < 5; i++) {
			t10 = SPHTMD(ftphi);
			sr = SPHSR(ftphi);
			ftphi = ftphi + (tmd - t10) / sr;
		}

		/* Radius of Curvature in the meridian */
		sr = SPHSR(ftphi);

		/* Radius of Curvature in the meridian */
		var sn = SPHSN(ftphi);

		/* Sine Cosine terms */
		//UNUSEDvar s = Math.sin(ftphi);
		var c = Math.cos(ftphi);

		/* Tangent Value */
		var t = Math.tan(ftphi);
		var tan2 = t * t;
		var tan4 = tan2 * tan2;
		var eta = TranMerc_ebs * Math.pow(c,2);
		var eta2 = eta * eta;
		var eta3 = eta2 * eta;
		var eta4 = eta3 * eta;
		var de = Easting - TranMerc_False_Easting;
		if (Math.abs(de) < 0.0001) de = 0.0;

		/* Latitude */
		t10 = t / (2.0 * sr * sn * Math.pow(TranMerc_Scale_Factor, 2));
		var t11 = t * (5.0  + 3.0 * tan2 + eta - 4.0 * Math.pow(eta,2) -
			9.0 * tan2 * eta) / (24.0 * sr * Math.pow(sn,3) *
				Math.pow(TranMerc_Scale_Factor,4));
		var t12 = t * (61.0 + 90.0 * tan2 + 46.0 * eta + 45.0 * tan4 -
			252.0 * tan2 * eta - 3.0 * eta2 + 100.0 *
			eta3 - 66.0 * tan2 * eta2 - 90.0 * tan4 *
			eta + 88.0 * eta4 + 225.0 * tan4 * eta2 +
			84.0 * tan2 * eta3 - 192.0 * tan2 * eta4) /
			(720.0 * sr * Math.pow(sn,5) * Math.pow(TranMerc_Scale_Factor, 6));
		var t13 = t * (1385.0 + 3633.0 * tan2 + 4095.0 * tan4 + 1575.0 *
			Math.pow(t,6)) / (40320.0 * sr * Math.pow(sn,7) * Math.pow(TranMerc_Scale_Factor,8));
		var Latitude = ftphi - Math.pow(de,2) * t10 + Math.pow(de,4) * t11 - Math.pow(de,6) * t12 +
			Math.pow(de,8) * t13;

		var t14 = 1.0 / (sn * c * TranMerc_Scale_Factor);

		var t15 = (1.0 + 2.0 * tan2 + eta) / (6.0 * Math.pow(sn,3) * c *
			Math.pow(TranMerc_Scale_Factor,3));

		var t16 = (5.0 + 6.0 * eta + 28.0 * tan2 - 3.0 * eta2 +
			8.0 * tan2 * eta + 24.0 * tan4 - 4.0 *
			eta3 + 4.0 * tan2 * eta2 + 24.0 *
			tan2 * eta3) / (120.0 * Math.pow(sn,5) * c *
				Math.pow(TranMerc_Scale_Factor,5));

		var t17 = (61.0 + 662.0 * tan2 + 1320.0 * tan4 + 720.0 *
			Math.pow(t,6)) / (5040.0 * Math.pow(sn,7) * c *
			Math.pow(TranMerc_Scale_Factor,7));

		/* Difference in Longitude */
		var dlam = de * t14 - Math.pow(de,3) * t15 + Math.pow(de,5) * t16 - Math.pow(de,7) * t17;

		/* Longitude */
		var Longitude = TranMerc_Origin_Long + dlam;

		if (Math.abs(Latitude) > (90.0 * Math.PI / 180.0)) {
			throw new Error("TRANMERC_NORTHING_ERROR");
		}
		if (Longitude > Math.PI) {
			Longitude -= 2 * Math.PI;
			if (Math.abs(Longitude) > Math.PI) {
				throw new Error("TRANMERC_EASTING_ERROR");
			}
		} else if (Longitude < -Math.PI) {
			Longitude += 2 * Math.PI;
			if (Math.abs(Longitude) > Math.PI) {
				throw new Error("TRANMERC_EASTING_ERROR");
			}
		}

		//if (Math.abs(dlam) > (9.0 * Math.PI / 180) * Math.cos(Latitude)) {
			/* Distortion will result if Longitude is more than 9 degrees from the Central Meridian at the equator */
			/* and decreases to 0 degrees at the poles */
			/* As you move towards the poles, distortion will become more significant */
		//	console.log("TRANMERC_LON_WARNING");
		//}

		return [ Latitude, Longitude ];
	}

	return {
		Convert_Geodetic_To_Transverse_Mercator: Convert_Geodetic_To_Transverse_Mercator,
		Convert_Transverse_Mercator_To_Geodetic: Convert_Transverse_Mercator_To_Geodetic,
	};
}

function Set_Polar_Stereographic_Parameters(
	a, f, Latitude_of_True_Scale, Longitude_Down_from_Pole,
	False_Easting, False_Northing
) {
	var inv_f = 1/f;
	if (a <= 0.0) {
		throw new Error("POLAR_A_ERROR");
	}
	if ((inv_f < 250) || (inv_f > 350)) {
		throw new Error("POLAR_INV_F_ERROR");
	}
	if (
		(Latitude_of_True_Scale < Math.PI/-2) ||
		(Latitude_of_True_Scale > Math.PI/2)
	) {
		throw new Error("POLAR_ORIGIN_LAT_ERROR");
	}
	if (
		(Longitude_Down_from_Pole < -Math.PI) ||
		(Longitude_Down_from_Pole > 2*Math.PI)
	) {
		throw new Error("POLAR_ORIGIN_LON_ERROR");
	}

	var Polar_a = a;
	var two_Polar_a = 2.0 * Polar_a;
	var Polar_f = f;

	if (Longitude_Down_from_Pole > Math.PI) {
		Longitude_Down_from_Pole -= 2*Math.PI;
	}
	var Southern_Hemisphere, Polar_Origin_Lat, Polar_Origin_Long;
	if (Latitude_of_True_Scale < 0) {
		Southern_Hemisphere = true;
		Polar_Origin_Lat = -Latitude_of_True_Scale;
		Polar_Origin_Long = -Longitude_Down_from_Pole;
	} else {
		Southern_Hemisphere = false;
		Polar_Origin_Lat = Latitude_of_True_Scale;
		Polar_Origin_Long = Longitude_Down_from_Pole;
	}
	var Polar_False_Easting = False_Easting;
	var Polar_False_Northing = False_Northing;

	var es2 = 2 * Polar_f - Polar_f * Polar_f;
	var es = Math.sqrt(es2);
	var es_OVER_2 = es / 2.0;

	function POLAR_POW(EsSin) {
		return Math.pow((1.0 - EsSin) / (1.0 + EsSin), es_OVER_2);
	}

	var Polar_a_mc = null;
	var tc = null;
	var e4 = null;
	if (Math.abs(Math.abs(Polar_Origin_Lat) - Math.PI/2) > 1.0e-10) {
		var slat = Math.sin(Polar_Origin_Lat);
		var essin = es * slat;
		var pow_es = POLAR_POW(essin);
		var clat = Math.cos(Polar_Origin_Lat);
		var mc = clat / Math.sqrt(1.0 - essin * essin);
		Polar_a_mc = Polar_a * mc;
		tc = Math.tan(Math.PI/4 - Polar_Origin_Lat / 2.0) / pow_es;
	} else {
		var one_PLUS_es = 1.0 + es;
		var one_MINUS_es = 1.0 - es;
		e4 = Math.sqrt(Math.pow(one_PLUS_es, one_PLUS_es) * Math.pow(one_MINUS_es, one_MINUS_es));
	}

	function Convert_Geodetic_To_Polar_Stereographic(Latitude, Longitude) {
		if ((Latitude < Math.PI/-2) || (Latitude > Math.PI/2)) {
			throw new Error("POLAR_LAT_ERROR");
		}
		if ((Latitude < 0) && (!Southern_Hemisphere)) {
			throw new Error("POLAR_LAT_ERROR");
		}
		if ((Latitude > 0) && Southern_Hemisphere) {
			throw new Error("POLAR_LAT_ERROR");
		}
		if ((Longitude < -Math.PI) || (Longitude > Math.PI*2)) {
			throw new Error("POLAR_LON_ERROR");
		}

		if (Math.abs(Math.abs(Latitude) - Math.PI/2) < 1e-10) {
			return [ Polar_False_Easting, Polar_False_Northing ];
		}
		if (Southern_Hemisphere) {
			Longitude *= -1;
			Latitude *= -1;
		}
		var dlam = Longitude - Polar_Origin_Long;
		if (dlam > Math.PI) dlam -= Math.PI*2;
		if (dlam < -Math.PI) dlam += Math.PI*2;

		var slat = Math.sin(Latitude);
		var essin = es * slat;
		var pow_es = POLAR_POW(essin);
		var t = Math.tan(Math.PI/4 - Latitude / 2.0) / pow_es;

		var rho = (Math.abs(Math.abs(Polar_Origin_Lat) - Math.PI/2) > 1e-10) ?
			(Polar_a_mc * t / tc) :
			(two_Polar_a * t / e4);

		if (Southern_Hemisphere) {
			return [
				-(rho * Math.sin(dlam) - Polar_False_Easting),
				rho * Math.cos(dlam) + Polar_False_Northing,
			];
		} else {
			return [
				rho * Math.sin(dlam) + Polar_False_Easting,
				-rho * Math.cos(dlam) + Polar_False_Northing,
			];
		}
	}

	/* Calculate Radius */
	var r = Convert_Geodetic_To_Polar_Stereographic(0, Longitude_Down_from_Pole);
	var temp_northing = r[1];

	var Polar_Delta_Northing = temp_northing;
	if (Polar_False_Northing) {
		Polar_Delta_Northing -= Polar_False_Northing;
	}
	if (Polar_Delta_Northing < 0) {
		Polar_Delta_Northing = -Polar_Delta_Northing;
	}
	Polar_Delta_Northing *= 1.01;

	var Polar_Delta_Easting = Polar_Delta_Northing;

	function Convert_Polar_Stereographic_To_Geodetic(Easting, Northing) {
		var min_easting = Polar_False_Easting - Polar_Delta_Easting;
		var max_easting = Polar_False_Easting + Polar_Delta_Easting;
		var min_northing = Polar_False_Northing - Polar_Delta_Northing;
		var max_northing = Polar_False_Northing + Polar_Delta_Northing;

		if (Easting > max_easting || Easting < min_easting) {
			throw new Error("POLAR_EASTING_ERROR");
		}
		if (Northing > max_northing || Northing < min_northing) {
			throw new Error("POLAR_NORTHING_ERROR");
		}

		var dy = Northing - Polar_False_Northing;
		var dx = Easting - Polar_False_Easting;

		/* Radius of point with origin of false easting, false northing */
		var rho = Math.sqrt(dx * dx + dy * dy);

		var delta_radius = Math.sqrt(Polar_Delta_Easting * Polar_Delta_Easting + Polar_Delta_Northing * Polar_Delta_Northing);

		if (rho > delta_radius) {
			/* Point is outside of projection area */
			throw new Error("POLAR_RADIUS_ERROR");
		}
		var Latitude, Longitude;
		if ((dy === 0.0) && (dx === 0.0)) {
			Latitude = Math.PI/2;
			Longitude = Polar_Origin_Long;
		} else {
			if (Southern_Hemisphere) {
				dy *= -1;
				dx *= -1;
			}
			var t = (Math.abs(Math.abs(Polar_Origin_Lat) - Math.PI/2) > 1e-10) ?
				(rho * tc / Polar_a_mc) :
				(rho * e4 / two_Polar_a);
			var PHI = Math.PI/2 - 2.0 * Math.atan(t);
			var tempPHI = 0.0;
			while (Math.abs(PHI - tempPHI) > 1e-10) {
				tempPHI = PHI;
				var sin_PHI = Math.sin(PHI);
				essin = es * sin_PHI;
				pow_es = POLAR_POW(essin);
				PHI = Math.PI/2 - 2.0 * Math.atan(t * pow_es);
			}
			Latitude = PHI;
			Longitude = Polar_Origin_Long + Math.atan2(dx, -dy);

			if (Longitude > Math.PI) {
				Longitude -= Math.PI*2;
			} else if (Longitude < -Math.PI) {
				Longitude += Math.PI*2;
			}

			if (Latitude > Math.PI/2) {
				/* force distorted values to 90, -90 degrees */
				Latitude = Math.PI/2;
			} else if (Latitude < Math.PI/-2) {
				Latitude = Math.PI/-2;
			}

			if (Longitude > Math.PI) {
				/* force distorted values to 180, -180 degrees */
				Longitude = Math.PI;
			} else if (Longitude < -Math.PI) {
				Longitude = -Math.PI;
			}
		}

		if (Southern_Hemisphere) {
			Latitude *= -1;
			Longitude *= -1;
		}

		return [ Latitude, Longitude ];
	}

	return {
		Convert_Geodetic_To_Polar_Stereographic: Convert_Geodetic_To_Polar_Stereographic,
		Convert_Polar_Stereographic_To_Geodetic: Convert_Polar_Stereographic_To_Geodetic,
	};
}

var MIN_EAST_NORTH = 0;
var MAX_EAST_NORTH = 4000000;
var MAX_ORIGIN_LAT = (81.114528 * Math.PI) / 180.0;
var UPS_a = 6378137.0;
var UPS_f = 1 / 298.257223563;
var UPS_Origin_Longitude = 0.0;
var UPS_False_Easting = 2000000;
var UPS_False_Northing = 2000000;
var MIN_NORTH_LAT = 83.5*Math.PI/180.0;
var MIN_SOUTH_LAT = -79.5*Math.PI/180.0;
function Convert_UPS_To_Geodetic(Hemisphere, Easting, Northing) {
	if ((Hemisphere !== 'N') && (Hemisphere !== 'S')) {
		throw new Error("UPS_HEMISPHERE_ERROR");
	}
	if ((Easting < MIN_EAST_NORTH) || (Easting > MAX_EAST_NORTH)) {
		throw new Error("UPS_EASTING_ERROR");
	}
	if ((Northing < MIN_EAST_NORTH) || (Northing > MAX_EAST_NORTH)) {
		throw new Error("UPS_NORTHING_ERROR");
	}
	var UPS_Origin_Latitude = (Hemisphere === 'N') ?
		MAX_ORIGIN_LAT : -MAX_ORIGIN_LAT;

	var converter = Set_Polar_Stereographic_Parameters(
		UPS_a, UPS_f,
		UPS_Origin_Latitude, UPS_Origin_Longitude,
		UPS_False_Easting, UPS_False_Northing
	);

	var latlon = converter.Convert_Polar_Stereographic_To_Geodetic(Easting, Northing);

	if ((latlon[0] < 0) && (latlon[0] > MIN_SOUTH_LAT)) {
		throw new Error("UPS_LAT_ERROR");
	}
	if ((latlon[0] >= 0) && (latlon[0] < MIN_NORTH_LAT)) {
		throw new Error("UPS_LAT_ERROR");
	}

	return latlon;
}

var MIN_EASTING = 100000;
var MAX_EASTING = 900000;
var MIN_NORTHING = 0;
var MAX_NORTHING = 10000000;
var UTM_a = 6378137.0;
var UTM_f = 1 / 298.257223563;
var MIN_LAT = (-80.5 * Math.PI) / 180.0;
var MAX_LAT = (84.5 * Math.PI) / 180.0;
function Convert_UTM_To_Geodetic(Zone, Hemisphere, Easting, Northing) {
	if ((Zone < 1) || (Zone > 60)) throw new Error("UTM_ZONE_ERROR");
	if ((Hemisphere !== 'S') && (Hemisphere !== 'N')) {
		throw new Error("UTM_HEMISPHERE_ERROR");
	}
	if ((Easting < MIN_EASTING) || (Easting > MAX_EASTING)) {
		throw new Error("UTM_EASTING_ERROR");
	}
	if ((Northing < MIN_NORTHING) || (Northing > MAX_NORTHING)) {
		throw new Error("UTM_NORTHING_ERROR");
	}

	var Central_Meridian = (Zone >= 31) ?
		((6 * Zone - 183) * Math.PI / 180.0) :
		((6 * Zone + 177) * Math.PI / 180.0);

	var False_Northing = (Hemisphere === 'S') ? 10000000 : 0;
	var False_Easting = 500000;
	var Origin_Latitude = 0;
	var Scale = 0.9996;

	var converter = Set_Transverse_Mercator_Parameters(
		UTM_a, UTM_f, Origin_Latitude, Central_Meridian,
		False_Easting, False_Northing, Scale
	);

	var latlon = converter.Convert_Transverse_Mercator_To_Geodetic(Easting, Northing);

	if ((latlon[0] < MIN_LAT) || (latlon[0] > MAX_LAT)) {
		/* Latitude out of range */
		throw new Error("UTM_NORTHING_ERROR");
	}

	return latlon;
}

var LETTER_A = 0;
var LETTER_C = 2;
var LETTER_D = 3;
var LETTER_E = 4;
var LETTER_H = 7;
var LETTER_I = 8;
var LETTER_J = 9;
var LETTER_L = 11;
var LETTER_M = 12;
var LETTER_N = 13;
var LETTER_O = 14;
var LETTER_P = 15;
var LETTER_R = 17;
var LETTER_S = 18;
var LETTER_U = 20;
var LETTER_V = 21;
var LETTER_W = 22;
var LETTER_X = 23;
var LETTER_Y = 24;
var LETTER_Z = 25;
var ONEHT = 100000.0;
var TWOMIL = 2000000.0;

function Get_Latitude_Band(letter) {
	var Latitude_Band_Table = [
		{ min_northing: 1100000.0, north: -72.0, south: -80.5, northing_offset:       0.0 },
		{ min_northing: 2000000.0, north: -64.0, south: -72.0, northing_offset: 2000000.0 },
		{ min_northing: 2800000.0, north: -56.0, south: -64.0, northing_offset: 2000000.0 },
		{ min_northing: 3700000.0, north: -48.0, south: -56.0, northing_offset: 2000000.0 },
		{ min_northing: 4600000.0, north: -40.0, south: -48.0, northing_offset: 4000000.0 },
		{ min_northing: 5500000.0, north: -32.0, south: -40.0, northing_offset: 4000000.0 },
		{ min_northing: 6400000.0, north: -24.0, south: -32.0, northing_offset: 6000000.0 },
		{ min_northing: 7300000.0, north: -16.0, south: -24.0, northing_offset: 6000000.0 },
		{ min_northing: 8200000.0, north:  -8.0, south: -16.0, northing_offset: 8000000.0 },
		{ min_northing: 9100000.0, north:   0.0, south:  -8.0, northing_offset: 8000000.0 },
		{ min_northing:       0.0, north:   8.0, south:   0.0, northing_offset:       0.0 },
		{ min_northing:  800000.0, north:  16.0, south:   8.0, northing_offset:       0.0 },
		{ min_northing: 1700000.0, north:  24.0, south:  16.0, northing_offset:       0.0 },
		{ min_northing: 2600000.0, north:  32.0, south:  24.0, northing_offset: 2000000.0 },
		{ min_northing: 3500000.0, north:  40.0, south:  32.0, northing_offset: 2000000.0 },
		{ min_northing: 4400000.0, north:  48.0, south:  40.0, northing_offset: 4000000.0 },
		{ min_northing: 5300000.0, north:  56.0, south:  48.0, northing_offset: 4000000.0 },
		{ min_northing: 6200000.0, north:  64.0, south:  56.0, northing_offset: 6000000.0 },
		{ min_northing: 7000000.0, north:  72.0, south:  64.0, northing_offset: 6000000.0 },
		{ min_northing: 7900000.0, north:  84.5, south:  72.0, northing_offset: 6000000.0 },
	];
	if ((letter >= LETTER_C) && (letter <= LETTER_H)) {
		return Latitude_Band_Table[letter-2];
	} else if ((letter >= LETTER_J) && (letter <= LETTER_N)) {
		return Latitude_Band_Table[letter-3];
	} else if ((letter >= LETTER_P) && (letter <= LETTER_X)) {
		return Latitude_Band_Table[letter-4];
	}
}

function Get_Grid_Values(zone) {
	var set_number = zone % 6;
	if (!set_number) set_number = 6;

	/* Some code for support of various non-WGS84 ellipsoids removed */
	var aa_pattern = true;

	var ltr2_low_value = null;
	var ltr2_high_value = null;
	if ((set_number === 1) || (set_number === 4)) {
		ltr2_low_value = LETTER_A;
		ltr2_high_value = LETTER_H;
	} else if ((set_number === 2) || (set_number === 5)) {
		ltr2_low_value = LETTER_J;
		ltr2_high_value = LETTER_R;
	} else if ((set_number === 3) || (set_number === 6)) {
		ltr2_low_value = LETTER_S;
		ltr2_high_value = LETTER_Z;
	}

	/* False northing at A for second letter of grid square */
	var pattern_offset = 0.0;
	if (aa_pattern) {
		if ((set_number % 2) === 0) pattern_offset = 500000.0;
	} else {
		if ((set_number % 2) === 0) {
			pattern_offset = 1500000.0;
		} else {
			pattern_offset = 1000000.0;
		}
	}

	return [ ltr2_low_value, ltr2_high_value, pattern_offset ];
}

function Break_MGRS_String(MGRS) {
	var m = MGRS.match(/^ *(\d{0,2})([A-HJ-NP-Za-hj-np-z]{3})(\d{0,10})/);
	if (m === null) throw new Error("MGRS_STRING_ERROR");

	var Zone = 0;
	if (m[1].length > 0) {
		Zone = parseInt(m[1], 10);
		if ((Zone < 1) || (Zone > 60)) {
			throw new Error("MGRS_STRING_ERROR");
		}
	}

	var Letters = m[2].toUpperCase();
	var Letter0 = Letters.charCodeAt(0) - "A".charCodeAt(0);
	var Letter1 = Letters.charCodeAt(1) - "A".charCodeAt(0);
	var Letter2 = Letters.charCodeAt(2) - "A".charCodeAt(0);

	if ((m[3].length) & 1) throw new Error("MGRS_STRING_ERROR");
	var Precision = m[3].length >> 1;
	var Easting = 0.0;
	var Northing = 0.0;
	if (m[3].length > 0) {
		var east = parseInt(m[3].substring(0, Precision), 10);
		var north = parseInt(m[3].substring(Precision), 10);
		var multiplier = Math.pow(10, 5-Precision);
		Easting = east * multiplier;
		Northing = north * multiplier;
	}

	return [ Zone, Letter0, Letter1, Letter2, Easting, Northing, Precision ];
}

function Convert_MGRS_To_UTM(MGRS) {
	var r = Break_MGRS_String(MGRS);
	var Zone = r[0];
	var letter0 = r[1];
	var letter1 = r[2];
	var letter2 = r[3];
	var Easting = r[4];
	var Northing = r[5];
	//UNUSEDvar in_precision = r[6];

	if (Zone === 0) {
		throw new Error("MGRS_STRING_ERROR");
	}
	if ((letter0 === LETTER_X) && ((Zone === 32) || (Zone === 34) || (Zone === 36))) {
		throw new Error("MGRS_STRING_ERROR");
	}
	var Hemisphere = (letter0 < LETTER_N) ? 'S' : 'N';

	r = Get_Grid_Values(Zone);
	var ltr2_low_value = r[0];
	var ltr2_high_value = r[1];
	var pattern_offset = r[2];

	/* Check that the second letter of the MGRS string is within
	 * the range of valid second letter values
	 * Also check that the third letter is valid */
	if (
		(letter1 < ltr2_low_value) ||
		(letter1 > ltr2_high_value) ||
		(letter2 > LETTER_V)
	) {
		throw new Error("MGRS_STRING_ERROR");
	}

	var row_letter_northing = letter2 * ONEHT;
	var grid_easting = (letter1 - ltr2_low_value + 1) * ONEHT;
	if ((ltr2_low_value === LETTER_J) && (letter1 > LETTER_O)) {
		grid_easting -= ONEHT;
	}

	if (letter2 > LETTER_O) {
		row_letter_northing -= ONEHT;
	}
	if (letter2 > LETTER_I) {
		row_letter_northing -= ONEHT;
	}
	if (row_letter_northing >= TWOMIL) {
		row_letter_northing -= TWOMIL;
	}

	var band = Get_Latitude_Band(letter0);
	var min_northing = band.min_northing;
	var northing_offset = band.northing_offset;

	var grid_northing = row_letter_northing - pattern_offset;
	if (grid_northing < 0) grid_northing += TWOMIL;

	grid_northing += northing_offset;
	if (grid_northing < min_northing) grid_northing += TWOMIL;

	Easting += grid_easting;
	Northing += grid_northing;

	/* check that point is within Zone Letter bounds */

	/* ...or not...
	var latlon = Convert_UTM_To_Geodetic(Zone, Hemisphere, Easting, Northing);

	var divisor = Math.pow(10.0, in_precision);
	if (!(
		((band.lower_lat_limit - (Math.PI/180.0)/divisor) <= latlon[0]) &&
		(latlon[0] <= (band.upper_lat_limit + DEG_TO_RAD/divisor))
	)) {
		console.log("MGRS_LAT_WARNING");
	}
	*/

	return [ Zone, Hemisphere, Easting, Northing ];
}

var UPS_Constant_Table = [
	{ ltr2_low_value: LETTER_J, ltr2_high_value: LETTER_Z, ltr3_high_value: LETTER_Z,
		false_easting: 800000, false_northing: 800000 },
	{ ltr2_low_value: LETTER_A, ltr2_high_value: LETTER_R, ltr3_high_value: LETTER_Z,
		false_easting: 2000000, false_northing: 800000 },
	{ ltr2_low_value: LETTER_J, ltr2_high_value: LETTER_Z, ltr3_high_value: LETTER_P,
		false_easting: 800000, false_northing: 1300000 },
	{ ltr2_low_value: LETTER_A, ltr2_high_value: LETTER_J, ltr3_high_value: LETTER_P,
		false_easting: 2000000, false_northing: 1300000 },
];

function Convert_MGRS_To_UPS(MGRS) {
	var r = Break_MGRS_String(MGRS);
	var zone = r[0];
	var letter0 = r[1];
	var letter1 = r[2];
	var letter2 = r[3];
	var Easting = r[4];
	var Northing = r[5];
	//UNUSEDvar in_precision = r[6];

	if (zone) {
		throw new Error("MGRS_STRING_ERROR");
	}
	var Hemisphere, index;
	if (letter0 >= LETTER_Y) {
		Hemisphere = 'N';
		index = letter0 - 22;
	} else {
		Hemisphere = 'S';
		index = letter0;
	}
	var ltr2_low_value = UPS_Constant_Table[index].ltr2_low_value;
	var ltr2_high_value = UPS_Constant_Table[index].ltr2_high_value;
	var ltr3_high_value = UPS_Constant_Table[index].ltr3_high_value;
	var false_easting = UPS_Constant_Table[index].false_easting;
	var false_northing = UPS_Constant_Table[index].false_northing;

	if (
		(letter1 < ltr2_low_value) ||
		(letter1 > ltr2_high_value) ||
		(letter1 === LETTER_D) || (letter1 === LETTER_E) ||
		(letter1 === LETTER_M) || (letter1 === LETTER_N) ||
		(letter1 === LETTER_V) || (letter1 === LETTER_W) ||
		(letter2 > ltr3_high_value)
	) {
		throw new Error("MGRS_STRING_ERROR");
	}

	var grid_northing = letter2 * ONEHT + false_northing;
	if (letter2 > LETTER_I) {
		grid_northing -= ONEHT;
	}
	if (letter2 > LETTER_O) {
		grid_northing -= ONEHT;
	}

	var grid_easting = (letter1 - ltr2_low_value) * ONEHT + false_easting;
	if (ltr2_low_value !== LETTER_A) {
		if (letter1 > LETTER_L) {
			grid_easting -= 300000.0;
		}
		if (letter1 > LETTER_U) {
			grid_easting -= 200000.0;
		}
	} else {
		if (letter1 > LETTER_C) {
			grid_easting -= 200000.0;
		}
		if (letter1 > LETTER_I) {
			grid_easting -= ONEHT;
		}
		if (letter1 > LETTER_L) {
			grid_easting -= 300000.0;
		}
	}

	return [ Hemisphere,  grid_easting + Easting, grid_northing + Northing ];
}

function Check_Zone(MGRS) {
	var zone = MGRS.match(/^ *(\d*)/)[1];
	if (zone.length === 0) return false;
	if (zone.length > 2) throw new Error("MGRS_STRING_ERROR");
	return true;
}

function Convert_MGRS_To_Geodetic(MGRS) {
	if (Check_Zone(MGRS)) {
		var utm = Convert_MGRS_To_UTM(MGRS);
		var zone = utm[0];
		var hemisphere = utm[1];
		var easting = utm[2];
		var northing = utm[3];
		return Convert_UTM_To_Geodetic(zone, hemisphere, easting, northing);
	} else {
		var ups = Convert_MGRS_To_UPS(MGRS);
		return Convert_UPS_To_Geodetic(ups[0], ups[1], ups[2]);
	}
}

return {
	Convert_MGRS_To_Geodetic: Convert_MGRS_To_Geodetic,
	Convert_MGRS_To_UPS: Convert_MGRS_To_UPS,
	Convert_MGRS_To_UTM: Convert_MGRS_To_UTM,
	Convert_UPS_To_Geodetic: Convert_UPS_To_Geodetic,
	Convert_UTM_To_Geodetic: Convert_UTM_To_Geodetic,
	Set_Polar_Stereographic_Parameters: Set_Polar_Stereographic_Parameters,
	Set_Transverse_Mercator_Parameters: Set_Transverse_Mercator_Parameters,
};

});
