-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 25-06-2022 a las 03:07:45
-- Versión del servidor: 5.7.36
-- Versión de PHP: 7.4.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ra`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `prc_eliminar_venta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_eliminar_venta` (IN `p_nro_boleta` VARCHAR(8))  BEGIN

DECLARE v_codigo VARCHAR(20);
DECLARE v_cantidad FLOAT;
DECLARE done INT DEFAULT FALSE;
DECLARE cursor_i CURSOR FOR 
SELECT codigo_producto,cantidad 
FROM venta_detalle 
where CAST(nro_boleta AS CHAR CHARACTER SET utf8)  = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_i;
read_loop: LOOP
FETCH cursor_i INTO v_codigo, v_cantidad;

	IF done THEN
	  LEAVE read_loop;
	END IF;
    
    UPDATE PRODUCTOS 
       SET stock_producto = stock_producto + v_cantidad
    WHERE CAST(codigo_producto AS CHAR CHARACTER SET utf8) = CAST(v_codigo AS CHAR CHARACTER SET utf8);
    
   DELETE FROM VENTA_DETALLE WHERE CAST(nro_boleta AS CHAR CHARACTER SET utf8) = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;
    DELETE FROM VENTA_CABECERA WHERE CAST(nro_boleta AS CHAR CHARACTER SET utf8)  = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;

END LOOP;
CLOSE cursor_i;

SELECT 'Se eliminó correctamente la venta';
END$$

DROP PROCEDURE IF EXISTS `prc_ListarCategorias`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarCategorias` ()  BEGIN
select * from categorias;
END$$

DROP PROCEDURE IF EXISTS `prc_ListarProductos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductos` ()  SELECT   '' as detalles,
                                                    id,
                                                    codigo_producto,
                                                    id_categoria_producto,
                                                    nombre_categoria,
                                                    descripcion_producto,
                                                    ROUND(precio_compra_producto,2) as precio_compra_producto,
                                                    ROUND(precio_venta_producto,2) as precio_venta_producto,
                                                    ROUND(utilidad,2) as utilidad,
                                                    case when c.aplica_peso = 1 then concat(stock_producto,' Kg(s)')
                                                        else concat(stock_producto,' Und(s)') end as stock_producto,
                                                    case when c.aplica_peso = 1 then concat(minimo_stock_producto,' Kg(s)')
                                                        else concat(minimo_stock_producto,' Und(s)') end as minimo_stock_producto,
                                                    case when c.aplica_peso = 1 then concat(ventas_producto,' Kg(s)') 
                                                        else concat(ventas_producto,' Und(s)') end as ventas_producto,
                                                    fecha_creacion_producto,
                                                    fecha_actualizacion_producto,
                                                    '' as acciones
                                                FROM productos p INNER JOIN categorias c on p.id_categoria_producto = c.id_categoria order by p.id desc$$

DROP PROCEDURE IF EXISTS `prc_ListarProductosMasVendidos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosMasVendidos` ()  NO SQL
BEGIN

select  p.codigo_producto,
		p.descripcion_producto,
        sum(vd.cantidad) as cantidad,
        sum(Round(vd.total_venta,2)) as total_venta
from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
group by p.codigo_producto,
		p.descripcion_producto
order by  sum(Round(vd.total_venta,2)) DESC
limit 10;

END$$

DROP PROCEDURE IF EXISTS `prc_ListarProductosPocoStock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosPocoStock` ()  NO SQL
BEGIN
select p.codigo_producto,
		p.descripcion_producto,
        p.stock_producto,
        p.minimo_stock_producto
from productos p
where p.stock_producto <= p.minimo_stock_producto
order by p.stock_producto asc;
END$$

DROP PROCEDURE IF EXISTS `prc_ObtenerDatosDashboard`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerDatosDashboard` ()  NO SQL
BEGIN
declare totalProductos int;
declare totalCompras float;
declare totalVentas float;
declare ganancias float;
declare productosPocoStock int;
declare ventasHoy float;

SET totalProductos = (SELECT count(*) FROM productos p);
SET totalCompras = (select sum(p.precio_compra_producto*p.stock_producto) from productos p);
set totalVentas = (select sum(vc.total_venta) from venta_cabecera vc where EXTRACT(MONTH FROM vc.fecha_venta) = EXTRACT(MONTH FROM curdate()) and EXTRACT(YEAR FROM vc.fecha_venta) = EXTRACT(YEAR FROM curdate()));
set ganancias = (select sum(vd.total_venta - (p.precio_compra_producto * vd.cantidad)) from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
                 where EXTRACT(MONTH FROM vd.fecha_venta) = EXTRACT(MONTH FROM curdate()) and EXTRACT(YEAR FROM vd.fecha_venta) = EXTRACT(YEAR FROM curdate()));
set productosPocoStock = (select count(1) from productos p where p.stock_producto <= p.minimo_stock_producto);
set ventasHoy = (select sum(vc.total_venta) from venta_cabecera vc where vc.fecha_venta = curdate());

SELECT IFNULL(totalProductos,0) AS totalProductos,
	   IFNULL(ROUND(totalCompras,2),0) AS totalCompras,
       IFNULL(ROUND(totalVentas,2),0) AS totalVentas,
       IFNULL(ROUND(ganancias,2),0) AS ganancias,
       IFNULL(productosPocoStock,0) AS productosPocoStock,
       IFNULL(ROUND(ventasHoy,2),0) AS ventasHoy;

END$$

DROP PROCEDURE IF EXISTS `prc_obtenerNroBoleta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_obtenerNroBoleta` ()  NO SQL
select serie_boleta,
		IFNULL(LPAD(max(c.nro_correlativo_venta)+1,8,'0'),'00000001') nro_venta 
from empresa c$$

DROP PROCEDURE IF EXISTS `prc_ObtenerVentasMesActual`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerVentasMesActual` ()  NO SQL
BEGIN
SELECT date(vc.fecha_venta) as fecha_venta,
		sum(round(vc.total_venta,2)) as total_venta,
        sum(round(vc.total_venta,2)) as total_venta_ant
FROM venta_cabecera vc
where date(vc.fecha_venta) >= date(last_day(now() - INTERVAL 1 month) + INTERVAL 1 day)
and date(vc.fecha_venta) <= last_day(date(CURRENT_DATE))
group by date(vc.fecha_venta);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

DROP TABLE IF EXISTS `categorias`;
CREATE TABLE IF NOT EXISTS `categorias` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_categoria` text COLLATE utf8_spanish_ci,
  `aplica_peso` int(11) NOT NULL,
  `fecha_creacion_categoria` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion_categoria` date DEFAULT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=306 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`, `aplica_peso`, `fecha_creacion_categoria`, `fecha_actualizacion_categoria`) VALUES
(287, 'Frutas', 1, '2022-06-24 03:58:23', '2022-06-24'),
(288, 'Verduras', 1, '2022-06-24 03:58:23', '2022-06-24'),
(289, 'Snack', 0, '2022-06-24 03:58:23', '2022-06-24'),
(290, 'Avena', 0, '2022-06-24 03:58:23', '2022-06-24'),
(291, 'Energizante', 0, '2022-06-24 03:58:23', '2022-06-24'),
(292, 'Jugo', 0, '2022-06-24 03:58:23', '2022-06-24'),
(293, 'Refresco', 0, '2022-06-24 03:58:23', '2022-06-24'),
(294, 'Mantequilla', 0, '2022-06-24 03:58:23', '2022-06-24'),
(295, 'Gaseosa', 0, '2022-06-24 03:58:23', '2022-06-24'),
(296, 'Aceite', 0, '2022-06-24 03:58:23', '2022-06-24'),
(297, 'Yogurt', 0, '2022-06-24 03:58:23', '2022-06-24'),
(298, 'Arroz', 0, '2022-06-24 03:58:23', '2022-06-24'),
(299, 'Leche', 0, '2022-06-24 03:58:23', '2022-06-24'),
(300, 'Papel Higiénico', 0, '2022-06-24 03:58:23', '2022-06-24'),
(301, 'Atún', 0, '2022-06-24 03:58:23', '2022-06-24'),
(302, 'Chocolate', 0, '2022-06-24 03:58:23', '2022-06-24'),
(303, 'Wafer', 0, '2022-06-24 03:58:23', '2022-06-24'),
(304, 'Golosina', 0, '2022-06-24 03:58:23', '2022-06-24'),
(305, 'Galletas', 0, '2022-06-24 03:58:23', '2022-06-24');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

DROP TABLE IF EXISTS `empresa`;
CREATE TABLE IF NOT EXISTS `empresa` (
  `id_empresa` int(11) NOT NULL AUTO_INCREMENT,
  `razon_social` text NOT NULL,
  `RUT` int(10) NOT NULL,
  `direccion` text NOT NULL,
  `serie_boleta` varchar(4) NOT NULL,
  `nro_correlativo_venta` varchar(8) NOT NULL,
  `email` text NOT NULL,
  PRIMARY KEY (`id_empresa`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`id_empresa`, `razon_social`, `RUT`, `direccion`, `serie_boleta`, `nro_correlativo_venta`, `email`) VALUES
(2, 'CIGARRERIA EDBAR', 890903934, 'Carrera 13 N. 28D-06 sur', 'B001', '37', 'edbarcigarreria@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

DROP TABLE IF EXISTS `modulos`;
CREATE TABLE IF NOT EXISTS `modulos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `modulo` varchar(45) DEFAULT NULL,
  `padre_id` int(11) DEFAULT NULL,
  `vista` varchar(45) DEFAULT NULL,
  `icon_menu` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `modulos`
--

INSERT INTO `modulos` (`id`, `modulo`, `padre_id`, `vista`, `icon_menu`) VALUES
(1, 'Tablero Principal', NULL, 'dashboard.php', 'fas fa-tachometer-alt'),
(2, 'Ventas', NULL, '', 'fas fa-store-alt'),
(3, 'Punto de Venta', 2, 'ventas.php', 'far fa-circle'),
(4, 'Administrar Ventas', 2, 'administrar_ventas.php', 'far fa-circle'),
(5, 'Productos', NULL, NULL, 'fas fa-cart-plus'),
(6, 'Inventario', 5, 'productos.php', 'far fa-circle'),
(7, 'Carga Masiva', 5, 'carga_masiva_productos.php', 'far fa-circle'),
(8, 'Categorías', 5, 'categorias.php', 'far fa-circle'),
(9, 'Compras', NULL, 'compras.php', 'fas fa-dolly'),
(10, 'Reportes', NULL, 'reportes.php', 'fas fa-chart-line'),
(11, 'Configuración', NULL, 'configuracion.php', 'fas fa-cogs'),
(12, 'Usuarios', NULL, 'usuarios.php', 'fas fa-users'),
(13, 'Roles y Perfiles', NULL, 'roles_perfiles.php', 'fas fa-tablet-alt');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfiles`
--

DROP TABLE IF EXISTS `perfiles`;
CREATE TABLE IF NOT EXISTS `perfiles` (
  `id_perfil` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(45) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id_perfil`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfiles`
--

INSERT INTO `perfiles` (`id_perfil`, `descripcion`, `estado`) VALUES
(1, 'Administrador', 1),
(2, 'Vendedor', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil_modulo`
--

DROP TABLE IF EXISTS `perfil_modulo`;
CREATE TABLE IF NOT EXISTS `perfil_modulo` (
  `idperfil_modulo` int(11) NOT NULL AUTO_INCREMENT,
  `id_perfil` int(11) DEFAULT NULL,
  `id_modulo` int(11) DEFAULT NULL,
  `vista_inicio` tinyint(4) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`idperfil_modulo`),
  KEY `id_perfil` (`id_perfil`),
  KEY `id_modulo` (`id_modulo`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `perfil_modulo`
--

INSERT INTO `perfil_modulo` (`idperfil_modulo`, `id_perfil`, `id_modulo`, `vista_inicio`, `estado`) VALUES
(1, 1, 1, 1, 1),
(3, 1, 3, NULL, 1),
(6, 1, 6, NULL, 1),
(7, 1, 7, NULL, 1),
(8, 1, 8, NULL, 1),
(9, 1, 9, NULL, 1),
(10, 1, 10, NULL, 1),
(11, 1, 11, NULL, 1),
(12, 1, 12, NULL, 1),
(13, 1, 13, NULL, 1),
(15, 1, 4, NULL, 1),
(16, 1, 5, NULL, 1),
(17, 1, 2, NULL, 1),
(18, 2, 2, NULL, 1),
(19, 2, 3, 1, 1),
(20, 2, 4, NULL, 1),
(21, 2, 10, NULL, 1),
(24, 2, 1, NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

DROP TABLE IF EXISTS `productos`;
CREATE TABLE IF NOT EXISTS `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_producto` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `id_categoria_producto` int(11) DEFAULT NULL,
  `descripcion_producto` text COLLATE utf8_spanish_ci,
  `precio_compra_producto` float NOT NULL,
  `precio_venta_producto` float NOT NULL,
  `precio_mayor_producto` float DEFAULT NULL,
  `precio_oferta_producto` float DEFAULT NULL,
  `utilidad` float NOT NULL,
  `stock_producto` float DEFAULT NULL,
  `minimo_stock_producto` float DEFAULT NULL,
  `ventas_producto` float DEFAULT NULL,
  `fecha_creacion_producto` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion_producto` date DEFAULT NULL,
  PRIMARY KEY (`id`,`codigo_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=1252 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `codigo_producto`, `id_categoria_producto`, `descripcion_producto`, `precio_compra_producto`, `precio_venta_producto`, `precio_mayor_producto`, `precio_oferta_producto`, `utilidad`, `stock_producto`, `minimo_stock_producto`, `ventas_producto`, `fecha_creacion_producto`, `fecha_actualizacion_producto`) VALUES
(1156, '7755139002813', 287, 'vainilla field 37g', 1200, 1440, NULL, NULL, 240, 24, 10, 0, '2022-06-24 03:58:23', '2022-06-24'),
(1157, '7755139002815', 287, 'soda field 34g', 1500, 1800, NULL, NULL, 300, 18, 5, 0, '2022-06-24 03:58:23', '2022-06-24'),
(1158, '7755139002816', 287, 'ritz original', 2500, 3000, NULL, NULL, 500, 24, 10, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1159, '7755139002826', 287, 'gn rellenitas 36g chocolate', 3000, 3600, NULL, NULL, 600, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1160, '7755139002827', 287, 'gn rellenitas 36g coco', 3200, 3840, NULL, NULL, 640, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1161, '7755139002828', 287, 'gn rellenitas 36g coco', 5200, 6240, NULL, NULL, 1040, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1162, '7755139002812', 287, 'soda san jorge 40g', 6200, 7440, NULL, NULL, 1240, 0, 0, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1163, '7755139002825', 289, 'tuyo 22g', 7500, 9000, NULL, NULL, 1500, 20, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1164, '7755139002822', 287, 'frac vanilla 45.5g', 6500, 7800, NULL, NULL, 1300, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1165, '7755139002823', 287, 'frac chocolate 45.5g', 1200, 1440, NULL, NULL, 240, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1166, '7755139002824', 287, 'frac chasica 45.5g', 1450, 1740, NULL, NULL, 290, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1167, '7755139002814', 287, 'Margarita', 1500, 1800, NULL, NULL, 300, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1168, '7755139002821', 287, 'club social 26g', 7800, 9360, NULL, NULL, 1560, 36, 10, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1169, '7755139002836', 287, 'Choco donuts', 5200, 6240, NULL, NULL, 1040, 18, 9, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1170, '7755139002820', 287, 'oreo original 36g', 1000, 1200, NULL, NULL, 200, 30, 10, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1171, '7755139002819', 287, 'Picaras', 1200, 1440, NULL, NULL, 240, 24, 12, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1172, '7755139002818', 287, 'Chocobum', 3600, 4320, NULL, NULL, 720, 18, 9, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1173, '7755139002835', 299, 'Zuko Emoliente', 6500, 7800, NULL, NULL, 1300, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1174, '7755139002817', 287, 'ritz queso 34g', 1500, 1800, NULL, NULL, 300, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1175, '7755139002829', 290, 'cancun', 2500, 3000, NULL, NULL, 500, 24, 10, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1176, '7755139002834', 287, 'Morocha 30g', 3200, 3840, NULL, NULL, 640, 24, 12, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1177, '7755139002833', 288, 'chin chin 32g', 3600, 4320, NULL, NULL, 720, 16, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1178, '7755139002831', 299, 'Zuko Piña', 3800, 4560, NULL, NULL, 760, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1179, '7755139002832', 299, 'Zuko Durazno', 7800, 9360, NULL, NULL, 1560, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1180, '7755139002842', 287, 'hony bran 33g', 3600, 4320, NULL, NULL, 720, 18, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1181, '7755139002841', 287, 'Wafer sublime', 6300, 7560, NULL, NULL, 1260, 24, 12, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1182, '7755139002830', 297, 'Big cola 400ml', 5400, 6480, NULL, NULL, 1080, 15, 10, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1183, '7755139002839', 300, 'Pulp Durazno 315ml', 2500, 3000, NULL, NULL, 500, 6, 3, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1184, '7755139002840', 289, 'morochas wafer 37g', 5200, 6240, NULL, NULL, 1040, 12, 5, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1185, '7755139002843', 287, 'Sublime clásico', 3600, 4320, NULL, NULL, 720, 24, 12, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1186, '7755139002838', 302, 'Quaker 120gr', 1200, 1440, NULL, NULL, 240, 6, 3, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1187, '7755139002852', 292, 'Noble pq 2 unid', 4500, 5400, NULL, NULL, 900, 10, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1188, '7755139002846', 295, 'Frutado fresa vasito', 4700, 5640, NULL, NULL, 940, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1189, '7755139002847', 295, 'Frutado durazno vasito', 4800, 5760, NULL, NULL, 960, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1190, '7755139002850', 297, 'Fanta Kola Inglesa 500ml', 6500, 7800, NULL, NULL, 1300, 12, 6, 0, '2022-06-24 03:58:24', '2022-06-24'),
(1191, '7755139002851', 297, 'Fanta Naranja 500ml', 12050, 14460, NULL, NULL, 2410, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1192, '7755139002837', 297, 'Pepsi 355ml', 1200, 1440, NULL, NULL, 240, 15, 10, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1193, '7755139002844', 295, 'Gloria fresa 180ml', 3600, 4320, NULL, NULL, 720, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1194, '7755139002845', 295, 'Gloria durazno 180ml', 15200, 18240, NULL, NULL, 3040, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1195, '7755139002849', 297, 'Seven Up 500ml', 3200, 3840, NULL, NULL, 640, 20, 10, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1196, '7755139002848', 302, '3 ositos quinua', 5200, 6240, NULL, NULL, 1040, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1197, '7755139002853', 292, 'Suave pq 2 unid', 3200, 3840, NULL, NULL, 640, 10, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1198, '7755139002857', 292, 'Elite Megarrollo', 1500, 1800, NULL, NULL, 300, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1199, '7755139002861', 295, 'Fresa 370ml Laive', 1800, 2160, NULL, NULL, 360, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1200, '7755139002855', 297, 'Coca cola 600ml', 5200, 6240, NULL, NULL, 1040, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1201, '7755139002856', 297, 'Inca Kola 600ml', 6500, 7800, NULL, NULL, 1300, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1202, '7755139002858', 293, 'Pura vida 395g', 3500, 4200, NULL, NULL, 700, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1203, '7755139002854', 297, 'Pepsi 750ml', 1500, 1800, NULL, NULL, 300, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1204, '7755139002860', 293, 'Ideal Light 395g', 3200, 3840, NULL, NULL, 640, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1205, '7755139002863', 293, 'Laive Ligth caja 480ml', 1500, 1800, NULL, NULL, 300, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1206, '7755139002874', 293, 'Pringles papas', 4500, 5400, NULL, NULL, 900, 12, 6, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1207, '7755139002873', 295, 'Battimix', 3500, 4200, NULL, NULL, 700, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1208, '7755139002859', 293, 'Ideal cremosita 395g', 3600, 4320, NULL, NULL, 720, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1209, '7755139002872', 294, 'Valle Norte 750g', 9600, 11520, NULL, NULL, 1920, 10, 5, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1210, '7755139002871', 293, 'Laive sin lactosa caja 480ml', 8600, 10320, NULL, NULL, 1720, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1211, '7755139002862', 293, 'Gloria evaporada entera ', 6800, 8160, NULL, NULL, 1360, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1212, '7755139002869', 293, 'Canchita mantequilla ', 9500, 11400, NULL, NULL, 1900, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1213, '7755139002870', 293, 'Canchita natural', 5900, 7080, NULL, NULL, 1180, 3, 2, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1214, '7755139002876', 294, 'Faraon amarillo 1k', 2500, 3000, NULL, NULL, 500, 10, 5, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1215, '7755139002811', 293, 'Gloria evaporada ligth 400g', 5400, 6480, NULL, NULL, 1080, 24, 12, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1216, '7755139002868', 297, 'Sabor Oro 1.7L', 5600, 6720, NULL, NULL, 1120, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1217, '7755139002867', 295, 'Griego gloria', 5700, 6840, NULL, NULL, 1140, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1218, '7755139002875', 294, 'Costeño 750g', 3500, 4200, NULL, NULL, 700, 20, 10, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1219, '7755139002810', 295, 'Gloria Fresa 500ml', 1200, 1440, NULL, NULL, 240, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1220, '7755139002865', 295, 'Gloria durazno 500ml', 3600, 4320, NULL, NULL, 720, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1221, '7755139002866', 295, 'Gloria Vainilla Francesa 500ml', 8500, 10200, NULL, NULL, 1700, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1222, '7755139002878', 292, 'Nova pq 2 unid', 4500, 5400, NULL, NULL, 900, 6, 2, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1223, '7755139002864', 297, 'Pepsi 1.5L', 6500, 7800, NULL, NULL, 1300, 6, 3, 0, '2022-06-24 03:58:25', '2022-06-24'),
(1224, '7755139002879', 292, 'Suave pq 4 unid', 3500, 4200, NULL, NULL, 700, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1225, '7755139002884', 291, 'Real Trozos', 1200, 1440, NULL, NULL, 240, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1226, '7755139002883', 291, 'A1 Filete', 1500, 1800, NULL, NULL, 300, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1227, '7755139002882', 291, 'Trozos de atún Campomar', 1700, 2040, NULL, NULL, 340, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1228, '7755139002881', 292, 'Paracas pq 4 unid', 1800, 2160, NULL, NULL, 360, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1229, '7755139002892', 291, 'Filete de atún Campomar', 1900, 2280, NULL, NULL, 380, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1230, '7755139002880', 291, 'Florida Trozos ', 2000, 2400, NULL, NULL, 400, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1231, '7755139002877', 291, 'A1 Trozos ', 2100, 2520, NULL, NULL, 420, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1232, '7755139002897', 301, 'Red Bull 250ml', 2200, 2640, NULL, NULL, 440, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1233, '7755139002894', 291, 'Filete de atún Florida ', 3600, 4320, NULL, NULL, 720, 12, 5, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1234, '7755139002893', 291, 'Florida Filete Ligth', 6500, 7800, NULL, NULL, 1300, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1235, '7755139002885', 295, 'Durazno 1L laive', 2300, 2760, NULL, NULL, 460, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1236, '7755139002886', 295, 'Fresa 1L Laive', 7800, 9360, NULL, NULL, 1560, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1237, '7755139002888', 295, 'Lúcuma 1L Gloria', 8700, 10440, NULL, NULL, 1740, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1238, '7755139002889', 295, 'Fresa 1L Gloria', 8600, 10320, NULL, NULL, 1720, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1239, '7755139002890', 295, 'Milkito fresa 1L', 9600, 11520, NULL, NULL, 1920, 3, 1, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1240, '7755139002891', 295, 'Gloria Durazno 1L', 6900, 8280, NULL, NULL, 1380, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1241, '7755139002895', 297, 'Inca Kola 1.5L', 8600, 10320, NULL, NULL, 1720, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1242, '7755139002896', 297, 'Coca Cola 1.5L', 7800, 9360, NULL, NULL, 1560, 1, 3, 0, '2022-06-24 04:04:08', '2022-06-24'),
(1243, '7755139002887', 291, 'A1 Filete Ligth', 6500, 7800, NULL, NULL, 1300, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1244, '7755139002898', 297, 'Sprite 3L', 5600, 6720, NULL, NULL, 1120, 4, 2, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1245, '7755139002899', 297, 'Pepsi 3L', 1250, 1500, NULL, NULL, 250, 4, 2, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1246, '7755139002900', 298, 'Laive 200gr', 3650, 4380, NULL, NULL, 730, 6, 3, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1247, '7755139002901', 298, 'Gloria Pote con sal', 1520, 1824, NULL, NULL, 304, 3, 2, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1248, '7755139002902', 296, 'Deleite 1L', 1590, 1908, NULL, NULL, 318, 4, 2, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1249, '7755139002903', 296, 'Sao 1L', 3500, 4200, NULL, NULL, 700, 3, 1, 0, '2022-06-24 03:58:26', '2022-06-24'),
(1250, '7755139002904', 296, 'Cocinero 1L', 1500, 1800, NULL, NULL, 300, 0, 1, 0, '2022-06-24 04:03:49', '2022-06-24'),
(1251, '7755139002809', 294, 'Paisana extra 5k', 3500, 4200, NULL, NULL, 700, 1, 0, 0, '2022-06-24 03:58:26', '2022-06-24');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE IF NOT EXISTS `usuario` (
  `idusuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `correo` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `usuario` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `clave` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `estado` int(11) NOT NULL DEFAULT '1',
  `telefono` varchar(30) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `id_rol` int(11) NOT NULL,
  `empresa` varchar(64) COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`idusuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `correo`, `usuario`, `clave`, `estado`, `telefono`, `direccion`, `id_rol`, `empresa`) VALUES
(1, 'camilo castro', 'cami2580@gmail.com', 'admin', '827ccb0eea8a706c4c34a16891f84e7b', 1, '312256325', 'calle 68 sur 22-19', 1, 'andii'),
(3, 'Santiago Garcia', 'santi@gmail.com', 'cajero', '827ccb0eea8a706c4c34a16891f84e7b', 1, '321232123', 'av del amor 25-36', 2, 'quintiago.s.a'),
(4, 'Nelly Cleves', 'nelly@gmil.com', 'cajero', '827ccb0eea8a706c4c34a16891f84e7b', 1, '3699635455', 'carrera 36-58-85', 0, 'gumerico');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_cabecera`
--

DROP TABLE IF EXISTS `venta_cabecera`;
CREATE TABLE IF NOT EXISTS `venta_cabecera` (
  `id_boleta` int(11) NOT NULL AUTO_INCREMENT,
  `nro_boleta` varchar(8) NOT NULL,
  `descripcion` text,
  `subtotal` float NOT NULL,
  `igv` float NOT NULL,
  `total_venta` float DEFAULT NULL,
  `fecha_venta` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_boleta`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `venta_cabecera`
--

INSERT INTO `venta_cabecera` (`id_boleta`, `nro_boleta`, `descripcion`, `subtotal`, `igv`, `total_venta`, `fecha_venta`) VALUES
(46, '00000014', 'Venta realizada con Nro Boleta: 00000014', 0, 0, 8400, '2022-06-13 15:54:10'),
(47, '00000015', 'Venta realizada con Nro Boleta: 00000015', 0, 0, 8520, '2022-06-13 03:34:17'),
(48, '16', 'Venta realizada con Nro Boleta: 00000016\r\n', 4320, 0, 4320, '2022-06-22 01:34:51');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

DROP TABLE IF EXISTS `venta_detalle`;
CREATE TABLE IF NOT EXISTS `venta_detalle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nro_boleta` varchar(8) CHARACTER SET utf8 NOT NULL,
  `codigo_producto` bigint(20) NOT NULL,
  `cantidad` float NOT NULL,
  `total_venta` float NOT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=526 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id`, `nro_boleta`, `codigo_producto`, `cantidad`, `total_venta`, `fecha_venta`) VALUES
(521, '00000014', 7755139002809, 1, 6720, '2021-11-19 02:54:10'),
(522, '00000014', 7754725000281, 1, 1680, '2021-11-19 03:34:17'),
(523, '00000015', 7751271021975, 1, 4200, '2021-11-19 03:34:51'),
(524, '00000015', 7750182006088, 1, 4320, '2021-11-19 03:34:51'),
(525, '16', 7750182006088, 10, 4320, '2022-06-22 01:34:51');

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD CONSTRAINT `id_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfiles` (`id_perfil`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
