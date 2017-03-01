
-- ----------------------------
--  Procedure definition for `html_unescape`
-- ----------------------------
DROP FUNCTION IF EXISTS `html_unescape`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `html_unescape`(decodeNumeric INT, txt TEXT CHARSET utf8) RETURNS text CHARSET utf8
    NO SQL
    DETERMINISTIC
BEGIN
    -- decodeNumeric = 0: keep numeric entity escape string.
    -- decodeNumeric = 1: decode numeric entity escape string.
    -- decodeNumeric = X: error, return original string.

    DECLARE result       TEXT CHARSET utf8;
    DECLARE tmp          TEXT CHARSET utf8 DEFAULT txt;
    DECLARE entity       TEXT CHARSET utf8;
    DECLARE codePoint    INT;
    DECLARE dst          TEXT CHARSET utf8;
    DECLARE i            INT;
    DECLARE j            INT;
    DECLARE k            INT;

    DECLARE mapping      TEXT CHARSET utf8 DEFAULT
            '" &quot;' -- " - double-quote
            '& &amp; ' -- & - ampersand
            '< &lt;  ' -- < - less-than
            '> &gt;  ' -- > - greater-than

            -- <!-- the upper part: 32 bytes -->
            -- below data format:
            -- utf16_code_point escape_string

            '00A0 &nbsp;' -- non-breaking space
            '00A1 &iexcl;' -- inverted exclamation mark
            '00A2 &cent;' -- cent sign
            '00A3 &pound;' -- pound sign
            '00A4 &curren;' -- currency sign
            '00A5 &yen;' -- yen sign = yuan sign
            '00A6 &brvbar;' -- broken bar = broken vertical bar
            '00A7 &sect;' -- section sign
            '00A8 &uml;' -- diaeresis = spacing diaeresis
            '00A9 &copy;' -- ? - copyright sign
            '00AA &ordf;' -- feminine ordinal indicator
            '00AB &laquo;' -- left-pointing double angle quotation mark = left pointing guillemet
            '00AC &not;' -- not sign
            '00AD &shy;' -- soft hyphen = discretionary hyphen
            '00AE &reg;' -- ? - registered trademark sign
            '00AF &macr;' -- macron = spacing macron = overline = APL overbar
            '00B0 &deg;' -- degree sign
            '00B1 &plusmn;' -- plus-minus sign = plus-or-minus sign
            '00B2 &sup2;' -- superscript two = superscript digit two = squared
            '00B3 &sup3;' -- superscript three = superscript digit three = cubed
            '00B4 &acute;' -- acute accent = spacing acute
            '00B5 &micro;' -- micro sign
            '00B6 &para;' -- pilcrow sign = paragraph sign
            '00B7 &middot;' -- middle dot = Georgian comma = Greek middle dot
            '00B8 &cedil;' -- cedilla = spacing cedilla
            '00B9 &sup1;' -- superscript one = superscript digit one
            '00BA &ordm;' -- masculine ordinal indicator
            '00BB &raquo;' -- right-pointing double angle quotation mark = right pointing guillemet
            '00BC &frac14;' -- vulgar fraction one quarter = fraction one quarter
            '00BD &frac12;' -- vulgar fraction one half = fraction one half
            '00BE &frac34;' -- vulgar fraction three quarters = fraction three quarters
            '00BF &iquest;' -- inverted question mark = turned question mark
            '00C0 &Agrave;' -- ? - uppercase A, grave accent
            '00C1 &Aacute;' -- ? - uppercase A, acute accent
            '00C2 &Acirc;' -- ? - uppercase A, circumflex accent
            '00C3 &Atilde;' -- ? - uppercase A, tilde
            '00C4 &Auml;' -- ? - uppercase A, umlaut
            '00C5 &Aring;' -- ? - uppercase A, ring
            '00C6 &AElig;' -- ? - uppercase AE
            '00C7 &Ccedil;' -- ? - uppercase C, cedilla
            '00C8 &Egrave;' -- ? - uppercase E, grave accent
            '00C9 &Eacute;' -- ? - uppercase E, acute accent
            '00CA &Ecirc;' -- ? - uppercase E, circumflex accent
            '00CB &Euml;' -- ? - uppercase E, umlaut
            '00CC &Igrave;' -- ? - uppercase I, grave accent
            '00CD &Iacute;' -- ? - uppercase I, acute accent
            '00CE &Icirc;' -- ? - uppercase I, circumflex accent
            '00CF &Iuml;' -- ? - uppercase I, umlaut
            '00D0 &ETH;' -- ? - uppercase Eth, Icelandic
            '00D1 &Ntilde;' -- ? - uppercase N, tilde
            '00D2 &Ograve;' -- ? - uppercase O, grave accent
            '00D3 &Oacute;' -- ? - uppercase O, acute accent
            '00D4 &Ocirc;' -- ? - uppercase O, circumflex accent
            '00D5 &Otilde;' -- ? - uppercase O, tilde
            '00D6 &Ouml;' -- ? - uppercase O, umlaut
            '00D7 &times;' -- multiplication sign
            '00D8 &Oslash;' -- ? - uppercase O, slash
            '00D9 &Ugrave;' -- ? - uppercase U, grave accent
            '00DA &Uacute;' -- ? - uppercase U, acute accent
            '00DB &Ucirc;' -- ? - uppercase U, circumflex accent
            '00DC &Uuml;' -- ? - uppercase U, umlaut
            '00DD &Yacute;' -- ? - uppercase Y, acute accent
            '00DE &THORN;' -- ? - uppercase THORN, Icelandic
            '00DF &szlig;' -- ? - lowercase sharps, German
            '00E0 &agrave;' -- ? - lowercase a, grave accent
            '00E1 &aacute;' -- ? - lowercase a, acute accent
            '00E2 &acirc;' -- ? - lowercase a, circumflex accent
            '00E3 &atilde;' -- ? - lowercase a, tilde
            '00E4 &auml;' -- ? - lowercase a, umlaut
            '00E5 &aring;' -- ? - lowercase a, ring
            '00E6 &aelig;' -- ? - lowercase ae
            '00E7 &ccedil;' -- ? - lowercase c, cedilla
            '00E8 &egrave;' -- ? - lowercase e, grave accent
            '00E9 &eacute;' -- ? - lowercase e, acute accent
            '00EA &ecirc;' -- ? - lowercase e, circumflex accent
            '00EB &euml;' -- ? - lowercase e, umlaut
            '00EC &igrave;' -- ? - lowercase i, grave accent
            '00ED &iacute;' -- ? - lowercase i, acute accent
            '00EE &icirc;' -- ? - lowercase i, circumflex accent
            '00EF &iuml;' -- ? - lowercase i, umlaut
            '00F0 &eth;' -- ? - lowercase eth, Icelandic
            '00F1 &ntilde;' -- ? - lowercase n, tilde
            '00F2 &ograve;' -- ? - lowercase o, grave accent
            '00F3 &oacute;' -- ? - lowercase o, acute accent
            '00F4 &ocirc;' -- ? - lowercase o, circumflex accent
            '00F5 &otilde;' -- ? - lowercase o, tilde
            '00F6 &ouml;' -- ? - lowercase o, umlaut
            '00F7 &divide;' -- division sign
            '00F8 &oslash;' -- ? - lowercase o, slash
            '00F9 &ugrave;' -- ? - lowercase u, grave accent
            '00FA &uacute;' -- ? - lowercase u, acute accent
            '00FB &ucirc;' -- ? - lowercase u, circumflex accent
            '00FC &uuml;' -- ? - lowercase u, umlaut
            '00FD &yacute;' -- ? - lowercase y, acute accent
            '00FE &thorn;' -- ? - lowercase thorn, Icelandic
            '00FF &yuml;' -- ? - lowercase y, umlaut

            -- <!-- Latin Extended-B -->
            '0192 &fnof;' -- latin small f with hook = function= florin, U+0192 ISOtech -->
            -- <!-- Greek -->
            '0391 &Alpha;' -- greek capital letter alpha, U+0391 -->
            '0392 &Beta;' -- greek capital letter beta, U+0392 -->
            '0393 &Gamma;' -- greek capital letter gamma,U+0393 ISOgrk3 -->
            '0394 &Delta;' -- greek capital letter delta,U+0394 ISOgrk3 -->
            '0395 &Epsilon;' -- greek capital letter epsilon, U+0395 -->
            '0396 &Zeta;' -- greek capital letter zeta, U+0396 -->
            '0397 &Eta;' -- greek capital letter eta, U+0397 -->
            '0398 &Theta;' -- greek capital letter theta,U+0398 ISOgrk3 -->
            '0399 &Iota;' -- greek capital letter iota, U+0399 -->
            '039A &Kappa;' -- greek capital letter kappa, U+039A -->
            '039B &Lambda;' -- greek capital letter lambda,U+039B ISOgrk3 -->
            '039C &Mu;' -- greek capital letter mu, U+039C -->
            '039D &Nu;' -- greek capital letter nu, U+039D -->
            '039E &Xi;' -- greek capital letter xi, U+039E ISOgrk3 -->
            '039F &Omicron;' -- greek capital letter omicron, U+039F -->
            '03A0 &Pi;' -- greek capital letter pi, U+03A0 ISOgrk3 -->
            '03A1 &Rho;' -- greek capital letter rho, U+03A1 -->
            -- <!-- there is no Sigmaf, and no U+03A2 character either -->
            '03A3 &Sigma;' -- greek capital letter sigma,U+03A3 ISOgrk3 -->
            '03A4 &Tau;' -- greek capital letter tau, U+03A4 -->
            '03A5 &Upsilon;' -- greek capital letter upsilon,U+03A5 ISOgrk3 -->
            '03A6 &Phi;' -- greek capital letter phi,U+03A6 ISOgrk3 -->
            '03A7 &Chi;' -- greek capital letter chi, U+03A7 -->
            '03A8 &Psi;' -- greek capital letter psi,U+03A8 ISOgrk3 -->
            '03A9 &Omega;' -- greek capital letter omega,U+03A9 ISOgrk3 -->
            '03B1 &alpha;' -- greek small letter alpha,U+03B1 ISOgrk3 -->
            '03B2 &beta;' -- greek small letter beta, U+03B2 ISOgrk3 -->
            '03B3 &gamma;' -- greek small letter gamma,U+03B3 ISOgrk3 -->
            '03B4 &delta;' -- greek small letter delta,U+03B4 ISOgrk3 -->
            '03B5 &epsilon;' -- greek small letter epsilon,U+03B5 ISOgrk3 -->
            '03B6 &zeta;' -- greek small letter zeta, U+03B6 ISOgrk3 -->
            '03B7 &eta;' -- greek small letter eta, U+03B7 ISOgrk3 -->
            '03B8 &theta;' -- greek small letter theta,U+03B8 ISOgrk3 -->
            '03B9 &iota;' -- greek small letter iota, U+03B9 ISOgrk3 -->
            '03BA &kappa;' -- greek small letter kappa,U+03BA ISOgrk3 -->
            '03BB &lambda;' -- greek small letter lambda,U+03BB ISOgrk3 -->
            '03BC &mu;' -- greek small letter mu, U+03BC ISOgrk3 -->
            '03BD &nu;' -- greek small letter nu, U+03BD ISOgrk3 -->
            '03BE &xi;' -- greek small letter xi, U+03BE ISOgrk3 -->
            '03BF &omicron;' -- greek small letter omicron, U+03BF NEW -->
            '03C0 &pi;' -- greek small letter pi, U+03C0 ISOgrk3 -->
            '03C1 &rho;' -- greek small letter rho, U+03C1 ISOgrk3 -->
            '03C2 &sigmaf;' -- greek small letter final sigma,U+03C2 ISOgrk3 -->
            '03C3 &sigma;' -- greek small letter sigma,U+03C3 ISOgrk3 -->
            '03C4 &tau;' -- greek small letter tau, U+03C4 ISOgrk3 -->
            '03C5 &upsilon;' -- greek small letter upsilon,U+03C5 ISOgrk3 -->
            '03C6 &phi;' -- greek small letter phi, U+03C6 ISOgrk3 -->
            '03C7 &chi;' -- greek small letter chi, U+03C7 ISOgrk3 -->
            '03C8 &psi;' -- greek small letter psi, U+03C8 ISOgrk3 -->
            '03C9 &omega;' -- greek small letter omega,U+03C9 ISOgrk3 -->
            '03D1 &thetasym;' -- greek small letter theta symbol,U+03D1 NEW -->
            '03D2 &upsih;' -- greek upsilon with hook symbol,U+03D2 NEW -->
            '03D6 &piv;' -- greek pi symbol, U+03D6 ISOgrk3 -->
            -- <!-- General Punctuation -->
            '2022 &bull;' -- bullet = black small circle,U+2022 ISOpub -->
            -- <!-- bullet is NOT the same as bullet operator, U+2219 -->
            '2026 &hellip;' -- horizontal ellipsis = three dot leader,U+2026 ISOpub -->
            '2032 &prime;' -- prime = minutes = feet, U+2032 ISOtech -->
            '2033 &Prime;' -- double prime = seconds = inches,U+2033 ISOtech -->
            '203E &oline;' -- overline = spacing overscore,U+203E NEW -->
            '2044 &frasl;' -- fraction slash, U+2044 NEW -->
            -- <!-- Letterlike Symbols -->
            '2118 &weierp;' -- script capital P = power set= Weierstrass p, U+2118 ISOamso -->
            '2111 &image;' -- blackletter capital I = imaginary part,U+2111 ISOamso -->
            '211C &real;' -- blackletter capital R = real part symbol,U+211C ISOamso -->
            '2122 &trade;' -- trade mark sign, U+2122 ISOnum -->
            '2135 &alefsym;' -- alef symbol = first transfinite cardinal,U+2135 NEW -->
            -- <!-- alef symbol is NOT the same as hebrew letter alef,U+05D0 although the
            -- same glyph could be used to depict both characters -->
            -- <!-- Arrows -->
            '2190 &larr;' -- leftwards arrow, U+2190 ISOnum -->
            '2191 &uarr;' -- upwards arrow, U+2191 ISOnum-->
            '2192 &rarr;' -- rightwards arrow, U+2192 ISOnum -->
            '2193 &darr;' -- downwards arrow, U+2193 ISOnum -->
            '2194 &harr;' -- left right arrow, U+2194 ISOamsa -->
            '21B5 &crarr;' -- downwards arrow with corner leftwards= carriage return, U+21B5 NEW -->
            '21D0 &lArr;' -- leftwards double arrow, U+21D0 ISOtech -->
            -- <!-- ISO 10646 does not say that lArr is the same as the 'is implied by'
            -- arrow but also does not have any other character for that function.
            -- So ? lArr canbe used for 'is implied by' as ISOtech suggests -->
            '21D1 &uArr;' -- upwards double arrow, U+21D1 ISOamsa -->
            '21D2 &rArr;' -- rightwards double arrow,U+21D2 ISOtech -->
            -- <!-- ISO 10646 does not say this is the 'implies' character but does not
            -- have another character with this function so ?rArr can be used for
            -- 'implies' as ISOtech suggests -->
            '21D3 &dArr;' -- downwards double arrow, U+21D3 ISOamsa -->
            '21D4 &hArr;' -- left right double arrow,U+21D4 ISOamsa -->
            -- <!-- Mathematical Operators -->
            '2200 &forall;' -- for all, U+2200 ISOtech -->
            '2202 &part;' -- partial differential, U+2202 ISOtech -->
            '2203 &exist;' -- there exists, U+2203 ISOtech -->
            '2205 &empty;' -- empty set = null set = diameter,U+2205 ISOamso -->
            '2207 &nabla;' -- nabla = backward difference,U+2207 ISOtech -->
            '2208 &isin;' -- element of, U+2208 ISOtech -->
            '2209 &notin;' -- not an element of, U+2209 ISOtech -->
            '220B &ni;' -- contains as member, U+220B ISOtech -->
            -- <!-- should there be a more memorable name than 'ni'? -->
            '220F &prod;' -- n-ary product = product sign,U+220F ISOamsb -->
            -- <!-- prod is NOT the same character as U+03A0 'greek capital letter pi'
            -- though the same glyph might be used for both -->
            '2211 &sum;' -- n-ary summation, U+2211 ISOamsb -->
            -- <!-- sum is NOT the same character as U+03A3 'greek capital letter sigma'
            -- though the same glyph might be used for both -->
            '2212 &minus;' -- minus sign, U+2212 ISOtech -->
            '2217 &lowast;' -- asterisk operator, U+2217 ISOtech -->
            '221A &radic;' -- square root = radical sign,U+221A ISOtech -->
            '221D &prop;' -- proportional to, U+221D ISOtech -->
            '221E &infin;' -- infinity, U+221E ISOtech -->
            '2220 &ang;' -- angle, U+2220 ISOamso -->
            '2227 &and;' -- logical and = wedge, U+2227 ISOtech -->
            '2228 &or;' -- logical or = vee, U+2228 ISOtech -->
            '2229 &cap;' -- intersection = cap, U+2229 ISOtech -->
            '222A &cup;' -- union = cup, U+222A ISOtech -->
            '222B &int;' -- integral, U+222B ISOtech -->
            '2234 &there4;' -- therefore, U+2234 ISOtech -->
            '223C &sim;' -- tilde operator = varies with = similar to,U+223C ISOtech -->
            -- <!-- tilde operator is NOT the same character as the tilde, U+007E,although
            -- the same glyph might be used to represent both -->
            '2245 &cong;' -- approximately equal to, U+2245 ISOtech -->
            '2248 &asymp;' -- almost equal to = asymptotic to,U+2248 ISOamsr -->
            '2260 &ne;' -- not equal to, U+2260 ISOtech -->
            '2261 &equiv;' -- identical to, U+2261 ISOtech -->
            '2264 &le;' -- less-than or equal to, U+2264 ISOtech -->
            '2265 &ge;' -- greater-than or equal to,U+2265 ISOtech -->
            '2282 &sub;' -- subset of, U+2282 ISOtech -->
            '2283 &sup;' -- superset of, U+2283 ISOtech -->
            -- <!-- note that nsup, 'not a superset of, U+2283' is not covered by the
            -- Symbol font encoding and is not included. Should it be, for symmetry?
            -- It is in ISOamsn --> <!ENTITY nsub USING utf16) USING utf8), '8836',
            -- not a subset of, U+2284 ISOamsn -->
            '2286 &sube;' -- subset of or equal to, U+2286 ISOtech -->
            '2287 &supe;' -- superset of or equal to,U+2287 ISOtech -->
            '2295 &oplus;' -- circled plus = direct sum,U+2295 ISOamsb -->
            '2297 &otimes;' -- circled times = vector product,U+2297 ISOamsb -->
            '22A5 &perp;' -- up tack = orthogonal to = perpendicular,U+22A5 ISOtech -->
            '22C5 &sdot;' -- dot operator, U+22C5 ISOamsb -->
            -- <!-- dot operator is NOT the same character as U+00B7 middle dot -->
            -- <!-- Miscellaneous Technical -->
            '2308 &lceil;' -- left ceiling = apl upstile,U+2308 ISOamsc -->
            '2309 &rceil;' -- right ceiling, U+2309 ISOamsc -->
            '230A &lfloor;' -- left floor = apl downstile,U+230A ISOamsc -->
            '230B &rfloor;' -- right floor, U+230B ISOamsc -->
            '2329 &lang;' -- left-pointing angle bracket = bra,U+2329 ISOtech -->
            -- <!-- lang is NOT the same character as U+003C 'less than' or U+2039 'single left-pointing angle quotation
            -- mark' -->
            '232A &rang;' -- right-pointing angle bracket = ket,U+232A ISOtech -->
            -- <!-- rang is NOT the same character as U+003E 'greater than' or U+203A
            -- 'single right-pointing angle quotation mark' -->
            -- <!-- Geometric Shapes -->
            '25CA &loz;' -- lozenge, U+25CA ISOpub -->
            -- <!-- Miscellaneous Symbols -->
            '2660 &spades;' -- black spade suit, U+2660 ISOpub -->
            -- <!-- black here seems to mean filled as opposed to hollow -->
            '2663 &clubs;' -- black club suit = shamrock,U+2663 ISOpub -->
            '2665 &hearts;' -- black heart suit = valentine,U+2665 ISOpub -->
            '2666 &diams;' -- black diamond suit, U+2666 ISOpub -->

            -- <!-- Latin Extended-A -->
            '0152 &OElig;' -- -- latin capital ligature OE,U+0152 ISOlat2 -->
            '0153 &oelig;' -- -- latin small ligature oe, U+0153 ISOlat2 -->
            -- <!-- ligature is a misnomer, this is a separate character in some languages -->
            '0160 &Scaron;' -- -- latin capital letter S with caron,U+0160 ISOlat2 -->
            '0161 &scaron;' -- -- latin small letter s with caron,U+0161 ISOlat2 -->
            '0178 &Yuml;' -- -- latin capital letter Y with diaeresis,U+0178 ISOlat2 -->
            -- <!-- Spacing Modifier Letters -->
            '02C6 &circ;' -- -- modifier letter circumflex accent,U+02C6 ISOpub -->
            '02DC &tilde;' -- small tilde, U+02DC ISOdia -->
            -- <!-- General Punctuation -->
            '2002 &ensp;' -- en space, U+2002 ISOpub -->
            '2003 &emsp;' -- em space, U+2003 ISOpub -->
            '2009 &thinsp;' -- thin space, U+2009 ISOpub -->
            '200C &zwnj;' -- zero width non-joiner,U+200C NEW RFC 2070 -->
            '200D &zwj;' -- zero width joiner, U+200D NEW RFC 2070 -->
            '200E &lrm;' -- left-to-right mark, U+200E NEW RFC 2070 -->
            '200F &rlm;' -- right-to-left mark, U+200F NEW RFC 2070 -->
            '2013 &ndash;' -- en dash, U+2013 ISOpub -->
            '2014 &mdash;' -- em dash, U+2014 ISOpub -->
            '2018 &lsquo;' -- left single quotation mark,U+2018 ISOnum -->
            '2019 &rsquo;' -- right single quotation mark,U+2019 ISOnum -->
            '201A &sbquo;' -- single low-9 quotation mark, U+201A NEW -->
            '201C &ldquo;' -- left double quotation mark,U+201C ISOnum -->
            '201D &rdquo;' -- right double quotation mark,U+201D ISOnum -->
            '201E &bdquo;' -- double low-9 quotation mark, U+201E NEW -->
            '2020 &dagger;' -- dagger, U+2020 ISOpub -->
            '2021 &Dagger;' -- double dagger, U+2021 ISOpub -->
            '2030 &permil;' -- per mille sign, U+2030 ISOtech -->
            '2039 &lsaquo;' -- single left-pointing angle quotation mark,U+2039 ISO proposed -->
            -- <!-- lsaquo is proposed but not yet ISO standardized -->
            '203A &rsaquo;' -- single right-pointing angle quotation mark,U+203A ISO proposed -->
            -- <!-- rsaquo is proposed but not yet ISO standardized -->
            '20AC &euro;' -- -- euro sign, U+20AC NEW -->
        ;

    IF (decodeNumeric < 0) OR (decodeNumeric > 1) THEN
        RETURN txt;
    END IF;

    IF txt IS NULL THEN
        RETURN NULL;
    END IF;

    SET result = '';
    LOOP
        SET i = LOCATE('&', tmp);
        IF i = 0 THEN
            IF result = '' THEN
                RETURN tmp;
            ELSE
                RETURN CONCAT(result, tmp);
            END IF;
        END IF;

        SET j = LOCATE(';', tmp, i + 1);
        IF j > i THEN
            IF (decodeNumeric = 1) AND (SUBSTRING(tmp, i + 1, 1) = '#') THEN
                SET entity = SUBSTRING(tmp, i + 2, j - i - 2);
                IF entity REGEXP '^[[:digit:]]+$' THEN
                    SET codePoint = CAST(entity AS UNSIGNED);
                    IF (codePoint >> 16) > 0 THEN
                        -- an utf32 char,
                        -- Mysql utf8 not support U+10000 to U+10FFFF which requires 4 bytes space (yet utf8mb4 supports), keep escape string
                        SET result = CONCAT(result, LEFT(tmp, j));
                        SET tmp = SUBSTRING(tmp, j + 1);
                    ELSE
                        IF (codePoint >> 11) = 0x1B THEN  -- codePoint: 0xD800 to 0xDFFF
                            -- an utf16 char's high or low surrogate
                            -- Mysql utf8 not support U+10000 to U+10FFFF which requires 4 bytes space, keep escape string
                            SET result = CONCAT(result, LEFT(tmp, j));
                            SET tmp = SUBSTRING(tmp, j + 1);
                        ELSE
                            -- an utf16 char (U+0000 to U+FFFF)
                            SET dst = CONVERT(CHAR(codePoint USING utf16) USING utf8);
                            IF dst IS NULL THEN SET dst = ''; END IF;
                            SET result = CONCAT(result, LEFT(tmp, i - 1), dst);
                            SET tmp = SUBSTRING(tmp, j + 1);
                        END IF;
                    END IF;
                ELSE
                    -- not escape string, move forward
                    SET result = CONCAT(result, LEFT(tmp, i + 1));
                    SET tmp = SUBSTRING(tmp, i + 2);
                END IF;
            ELSE
                SET entity = SUBSTRING(tmp, i, j - i + 1);
                IF entity REGEXP '^&[[:alpha:]]+[[:digit:]]*;$' THEN
                    SET k = LOCATE(entity, mapping);
                    IF k > 0 THEN
                        -- an escape string
                        IF k <= 32 THEN
                            SET dst = SUBSTRING(mapping, k - 2, 1);
                        ELSE
                            SET codePoint = CONV(SUBSTRING(mapping, k - 5, 4), 16, 10);
                            SET dst = CONVERT(CHAR(codePoint USING utf16) USING utf8);
                            IF dst IS NULL THEN SET dst = ''; END IF;
                        END IF;

                        SET result = CONCAT(result, LEFT(tmp, i - 1), dst);
                        SET tmp = SUBSTRING(tmp, j + 1);
                    ELSE
                        -- not escape string, move forward
                        SET result = CONCAT(result, LEFT(tmp, j));
                        SET tmp = SUBSTRING(tmp, j + 1);
                    END IF;
                ELSE
                    -- not escape string, move forward
                    SET result = CONCAT(result, LEFT(tmp, i));
                    SET tmp = SUBSTRING(tmp, i + 1);
                END IF;
            END IF;
        ELSE
            RETURN CONCAT(result, tmp);
        END IF;
    END LOOP;
END
;;
DELIMITER ;
