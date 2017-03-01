
-- ----------------------------
--  Procedure definition for `unicode_unescape`
-- ----------------------------
DROP FUNCTION IF EXISTS `unicode_unescape`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `unicode_unescape`(txt TEXT CHARSET utf8) RETURNS text CHARSET utf8
    NO SQL
    DETERMINISTIC
BEGIN
    DECLARE result    TEXT CHARSET utf8;
    DECLARE tmp       TEXT CHARSET utf8 DEFAULT txt;
    DECLARE entity    TEXT CHARSET utf8;
    DECLARE codePoint INT;
    DECLARE dst       TEXT CHARSET utf8;
    DECLARE i         INT;

    IF txt IS NULL THEN
        RETURN NULL;
    END IF;

    SET result = '';
    LOOP
        SET i = LOCATE('\\u', tmp);
        IF i = 0 THEN
            IF result = '' THEN
                RETURN tmp;
            ELSE
                RETURN CONCAT(result, tmp);
            END IF;
        END IF;

        SET entity = SUBSTRING(tmp, i + 2, 4);
        IF entity REGEXP '^[[:xdigit:]]{4}$' THEN
            SET codePoint = CONV(entity, 16, 10);
            IF (codePoint >> 11) = 0x1B THEN  -- codePoint: 0xD800 to 0xDFFF
                -- an utf16 char's high or low surrogate
                -- Mysql utf8 not support U+10000 to U+10FFFF which requires 4 bytes space, keep escape string
                SET result = CONCAT(result, LEFT(tmp, i + 5));
                SET tmp = SUBSTRING(tmp, i + 6);
            ELSE
                -- an utf16 char (U+0000 to U+FFFF)
                SET dst = CONVERT(CHAR(codePoint USING utf16) USING utf8);
                IF dst IS NULL THEN SET dst = ''; END IF;
                SET result = CONCAT(result, LEFT(tmp, i - 1), dst);
                SET tmp = SUBSTRING(tmp, i + 6);
            END IF;
        ELSE
            SET result = CONCAT(result, LEFT(tmp, i + 1));
            SET tmp = SUBSTRING(tmp, i + 2);
        END IF;
    END LOOP;
END
;;
DELIMITER ;
