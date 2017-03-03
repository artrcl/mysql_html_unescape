
-- ----------------------------
-- Function structure for uuidToBin
-- ----------------------------
DROP FUNCTION IF EXISTS `uuidToBin`;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `uuidToBin`(_uuid BINARY(36)) RETURNS binary(16)
    NO SQL
    DETERMINISTIC
BEGIN
    RETURN UNHEX(
        CONCAT(
            SUBSTR(_uuid, 15, 4),
            SUBSTR(_uuid, 10, 4),
            SUBSTR(_uuid, 1, 8),
            SUBSTR(_uuid, 20, 4),
            SUBSTR(_uuid, 25)
        )
    );
END
;;
DELIMITER ;
