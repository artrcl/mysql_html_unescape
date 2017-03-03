
-- ----------------------------
-- Function structure for binToUuid
-- ----------------------------
DROP FUNCTION IF EXISTS `binToUuid`;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `binToUuid`(_bin BINARY(16)) RETURNS binary(36)
    NO SQL
    DETERMINISTIC
BEGIN
    RETURN LCASE(
        CONCAT_WS(
            '-',
            HEX(SUBSTR(_bin, 5, 4)),
            HEX(SUBSTR(_bin, 3, 2)),
            HEX(SUBSTR(_bin, 1, 2)),
            HEX(SUBSTR(_bin, 9, 2)),
            HEX(SUBSTR(_bin, 11))
        )
    );
END
;;
DELIMITER ;
