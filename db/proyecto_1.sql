-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 02-04-2022 a las 06:38:19
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
-- Base de datos: `proyecto_1`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `pcr_ListarProductos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pcr_ListarProductos` ()  BEGIN

SELECT '' as detalles,
 p.id,
 p.codigo_producto,
 c.id_categoria,
 c.nombre_categoria,
 p.descripcion_producto,
 round (p.precio_compra_producto) as precio_compra,
 round(p.precio_venta_producto) as precio_venta,
 round(p.utilidad) as utilidad,
 
 case when c.aplica_peso = 1 then concat(p.stock_producto,'kg(s)') ELSE
 concat(p.stock_producto,'Und(s)') end as stock,
 case when c.aplica_peso = 1 then concat(p.minimo_stock_producto,'kg(s)') ELSE
 concat(p.minimo_stock_producto,'Und(s)') end as minimo_stock,
 case when c.aplica_peso = 1 then concat(p.ventas_producto,'kg(s)') ELSE
 concat(p.ventas_producto,'Und(s)') end as ventas,
 p.fecha_creacion_producto,
 p.fecha_actualizacion_producto,
 '' as opciones
 
 
from productos p inner join categorias c on p.id_categoria_producto = c.id_categoria order by p.id desc;


END$$

DROP PROCEDURE IF EXISTS `prc_ListarProductosMasVendidos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosMasVendidos` ()  BEGIN

SELECT p.codigo_producto,
	   p.descripcion_producto,
sum(vd.cantidad) as cantidad, sum(round(vd.total_venta)) as total_venta 
from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
GROUP by p.codigo_producto, 
p.descripcion_producto
ORDER BY (round(vd.total_venta)) DESC LIMIT 10;


END$$

DROP PROCEDURE IF EXISTS `prc_ListarProductosPocoStock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosPocoStock` ()  BEGIN
SELECT p.codigo_producto,
	   p.descripcion_producto,
       p.stock_producto,
       p.minimo_stock_producto
FROM productos p
where p.stock_producto <= p.minimo_stock_producto
order by p.stock_producto asc;




end$$

DROP PROCEDURE IF EXISTS `prc_ObtenerDatosDashboard`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerDatosDashboard` ()  BEGIN
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
	   IFNULL(ROUND(totalCompras),0) AS totalCompras,
       IFNULL(ROUND(totalVentas),0) AS totalVentas,
       IFNULL(ROUND(ganancias),0) AS ganancias,
       IFNULL(productosPocoStock,0) AS productosPocoStock,
       IFNULL(ROUND(ventasHoy),0) AS ventasHoy;

END$$

DROP PROCEDURE IF EXISTS `prc_ObtenerVentasMesActual`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerVentasMesActual` ()  BEGIN
SELECT date(vc.fecha_venta) as fecha_venta,
		sum(round(vc.total_venta)) as total_venta,
        sum(round(vc.total_venta)) as total_venta_ant
FROM venta_cabecera vc
where date(vc.fecha_venta) >= date(last_day(now() - INTERVAL 12 month) + INTERVAL 1 day)
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
  `nombre_categoria` text CHARACTER SET utf8 COLLATE utf8_spanish_ci,
  `aplica_peso` int(11) NOT NULL,
  `fecha_creacion_categoria` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion_categoria` date DEFAULT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=462 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`, `aplica_peso`, `fecha_creacion_categoria`, `fecha_actualizacion_categoria`) VALUES
(443, 'Aceite', 0, '2022-04-02 03:02:21', '2022-04-02'),
(444, 'cereales', 0, '2022-04-02 03:02:21', '2022-04-02'),
(445, 'Chocolate', 0, '2022-04-02 03:02:21', '2022-04-02'),
(446, 'conservas', 0, '2022-04-02 03:02:21', '2022-04-02'),
(447, 'dulces', 0, '2022-04-02 03:02:21', '2022-04-02'),
(448, 'embutidos', 0, '2022-04-02 03:02:21', '2022-04-02'),
(449, 'Energizante', 0, '2022-04-02 03:02:21', '2022-04-02'),
(450, 'enlatados', 0, '2022-04-02 03:02:21', '2022-04-02'),
(451, 'Frutas', 1, '2022-04-02 03:02:21', '2022-04-02'),
(452, 'galletas', 0, '2022-04-02 03:02:21', '2022-04-02'),
(453, 'Gaseosa', 0, '2022-04-02 03:02:21', '2022-04-02'),
(454, 'granos', 0, '2022-04-02 03:02:21', '2022-04-02'),
(455, 'lateos', 0, '2022-04-02 03:02:21', '2022-04-02'),
(456, 'Leche', 0, '2022-04-02 03:02:21', '2022-04-02'),
(457, 'licores', 0, '2022-04-02 03:02:22', '2022-04-02'),
(458, 'Mantequilla', 0, '2022-04-02 03:02:22', '2022-04-02'),
(459, 'Aseo', 0, '2022-04-02 03:02:22', '2022-04-02'),
(460, 'Snack', 0, '2022-04-02 03:02:22', '2022-04-02'),
(461, 'Verduras', 1, '2022-04-02 03:02:22', '2022-04-02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

DROP TABLE IF EXISTS `empresa`;
CREATE TABLE IF NOT EXISTS `empresa` (
  `id_empresa` int(11) NOT NULL AUTO_INCREMENT,
  `razon_social` text NOT NULL,
  `NIT` bigint(20) NOT NULL,
  `direccion` text NOT NULL,
  `marca` text NOT NULL,
  `serie_boleta` varchar(4) NOT NULL,
  `nro_correlativo_venta` varchar(8) NOT NULL,
  `email` text NOT NULL,
  PRIMARY KEY (`id_empresa`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`id_empresa`, `razon_social`, `NIT`, `direccion`, `marca`, `serie_boleta`, `nro_correlativo_venta`, `email`) VALUES
(1, 'Cigarrería EDBAR', 10467291241, 'Calle 29 sur 19-31- Restrepo, Bogotá D.C', 'Cigarrería EDBAR', '0002', '00000024', 'cigarreriaedbar@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

DROP TABLE IF EXISTS `productos`;
CREATE TABLE IF NOT EXISTS `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_producto` bigint(13) NOT NULL,
  `id_categoria_producto` int(11) DEFAULT NULL,
  `descripcion_producto` text CHARACTER SET utf8 COLLATE utf8_spanish_ci,
  `precio_compra_producto` float NOT NULL,
  `precio_venta_producto` float NOT NULL,
  `utilidad` int(11) NOT NULL,
  `stock_producto` float DEFAULT NULL,
  `minimo_stock_producto` float DEFAULT NULL,
  `ventas_producto` float DEFAULT NULL,
  `fecha_creacion_producto` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion_producto` date DEFAULT NULL,
  PRIMARY KEY (`id`,`codigo_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=1645 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `codigo_producto`, `id_categoria_producto`, `descripcion_producto`, `precio_compra_producto`, `precio_venta_producto`, `utilidad`, `stock_producto`, `minimo_stock_producto`, `ventas_producto`, `fecha_creacion_producto`, `fecha_actualizacion_producto`) VALUES
(1549, 7755139002809, 458, 'fina', 1500, 1800, 300, 4, 0, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1550, 7755139002810, 453, 'Gloria Fresa 500ml', 2500, 3000, 500, 8, 3, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1551, 7755139002811, 456, 'Gloria evaporada ligth 400g', 2500, 3000, 500, 5, 12, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1552, 7755139002812, 453, 'soda san jorge 40g', 30000, 36000, 6000, 12, 0, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1553, 7755139002813, 457, 'vainilla field 37g', 2000, 2400, 400, 50, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1554, 7755139002814, 458, 'Margarita', 1500, 1800, 300, 2, 6, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1555, 7755139002815, 453, 'soda field 34g', 2000, 2400, 400, 8, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1556, 7755139002816, 451, 'ritz original', 1500, 1800, 300, 20, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1557, 7755139002817, 453, 'ritz queso 34g', 3500, 4200, 700, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1558, 7755139002818, 447, 'Chocobum', 250, 300, 50, 12, 9, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1559, 7755139002819, 451, 'Picaras', 3600, 4320, 720, 20, 12, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1560, 7755139002820, 452, 'oreo original 36g', 750, 900, 150, 12, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1561, 7755139002821, 452, 'club social 26g', 800, 960, 160, 15, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1562, 7755139002822, 451, 'frac vanilla 45.5g', 500, 600, 100, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1563, 7755139002823, 451, 'frac chocolate 45.5g', 4100, 4920, 820, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1564, 7755139002824, 451, 'frac chasica 45.5g', 700, 840, 140, 5, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1565, 7755139002825, 460, 'tuyo 22g', 500, 600, 100, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1566, 7755139002826, 451, 'gn rellenitas 36g chocolate', 600, 720, 120, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1567, 7755139002827, 451, 'gn rellenitas 36g coco', 30, 36, 6, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1568, 7755139002828, 451, 'gn rellenitas 36g coco', 2000, 2400, 400, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1569, 7755139002829, 455, 'cancun', 5200, 6240, 1040, 30, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1570, 7755139002830, 453, 'Big cola 400ml', 3600, 4320, 720, 20, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1571, 7755139002831, 449, 'Zuko Piña', 960, 1152, 192, 20, 6, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1572, 7755139002832, 449, 'Zuko Durazno', 250, 300, 50, 20, 6, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1573, 7755139002833, 460, 'chin chin 32g', 120, 144, 24, 12, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1574, 7755139002834, 450, 'Morocha 30g', 1000, 1200, 200, 12, 12, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1575, 7755139002835, 449, 'Zuko Emoliente', 1200, 1440, 240, 32, 6, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1576, 7755139002836, 448, 'Choco donuts', 1100, 1320, 220, 21, 9, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1577, 7755139002837, 453, 'Pepsi 355ml', 1100, 1320, 220, 20, 10, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1578, 7755139002838, NULL, 'Quaker 120gr', 1500, 1800, 300, 50, 3, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1579, 7755139002839, 445, 'Pulp Durazno 315ml', 1300, 1560, 260, 10, 3, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1580, 7755139002840, 452, 'morochas wafer 37g', 1700, 2040, 340, 10, 5, 0, '2022-04-02 03:02:22', '2022-04-02'),
(1581, 7755139002841, 452, 'Wafer sublime', 1800, 2160, 360, 20, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1582, 7755139002842, 454, 'hony bran 33g', 3000, 3600, 600, 6, 5, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1583, 7755139002843, 451, 'Sublime clásico', 3200, 3840, 640, 13, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1584, 7755139002844, 457, 'Gloria fresa 180ml', 2100, 2520, 420, 12, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1585, 7755139002845, 457, 'Gloria durazno 180ml', 2400, 2880, 480, 15, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1586, 7755139002846, 451, 'Frutado fresa vasito', 2300, 2760, 460, 10, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1587, 7755139002847, 451, 'Frutado durazno vasito', 2500, 3000, 500, 13, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1588, 7755139002848, 445, '3 ositos quinua', 3200, 3840, 640, 15, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1589, 7755139002849, 460, 'Seven Up 500ml', 1200, 1440, 240, 20, 10, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1590, 7755139002850, 445, 'Fanta Kola Inglesa 500ml', 4500, 5400, 900, 10, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1591, 7755139002851, 453, 'Fanta Naranja 500ml', 8500, 10200, 1700, 10, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1592, 7755139002852, 446, 'Noble pq 2 unid', 350, 420, 70, 10, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1593, 7755139002853, 459, 'Suave pq 2 unid', 450, 540, 90, 12, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1594, 7755139002854, 453, 'Pepsi 750ml', 650, 780, 130, 12, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1595, 7755139002855, 453, 'Coca cola 600ml', 450, 540, 90, 12, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1596, 7755139002856, 453, 'Inca Kola 600ml', 850, 1020, 170, 6, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1597, 7755139002857, 459, 'Elite Megarrollo', 350, 420, 70, 12, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1598, 7755139002858, 454, 'Pura vida 395g', 150, 180, 30, 13, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1599, 7755139002859, 454, 'Ideal cremosita 395g', 500, 600, 100, 15, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1600, 7755139002860, 455, 'Ideal Light 395g', 1400, 1680, 280, 15, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1601, 7755139002861, 453, 'Fresa 370ml Laive', 1500, 1800, 300, 13, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1602, 7755139002862, 457, 'Gloria evaporada entera ', 650, 780, 130, 13, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1603, 7755139002863, NULL, 'Laive Ligth caja 480ml', 3200, 3840, 640, 14, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1604, 7755139002864, 453, 'Pepsi 1.5L', 8000, 9600, 1600, 15, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1605, 7755139002865, 457, 'Gloria durazno 500ml', 3200, 3840, 640, 13, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1606, 7755139002866, 457, 'Gloria Vainilla Francesa 500ml', 1200, 1440, 240, 20, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1607, 7755139002867, 457, 'Griego gloria', 5200, 6240, 1040, 20, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1608, 7755139002868, 452, 'Sabor Oro 1.7L', 3000, 3600, 600, 250, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1609, 7755139002869, 458, 'Canchita mantequilla ', 1200, 1440, 240, 20, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1610, 7755139002870, NULL, 'Canchita natural', 800, 960, 160, 20, 2, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1611, 7755139002871, NULL, 'Laive sin lactosa caja 480ml', 600, 720, 120, 20, 3, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1612, 7755139002872, 453, 'Valle Norte 750g', 800, 960, 160, 13, 5, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1613, 7755139002873, 453, 'Battimix', 1200, 1440, 240, 1, 12, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1614, 7755139002874, 460, 'Pringles papas', 2310, 2772, 462, 210, 6, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1615, 7755139002875, 455, 'Costeño 750g', 9800, 11760, 1960, 12, 10, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1616, 7755139002876, 457, 'Faraon amarillo 1k', 1200, 1440, 240, 14, 5, 0, '2022-04-02 03:02:23', '2022-04-02'),
(1617, 7755139002877, 449, 'A1 Trozos ', 950, 1140, 190, 15, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1618, 7755139002878, 458, 'Nova pq 2 unid', 850, 1020, 170, 13, 2, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1619, 7755139002879, 461, 'Suave pq 4 unid', 750, 900, 150, 13, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1620, 7755139002880, 461, 'Florida Trozos ', 950, 1140, 190, 14, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1621, 7755139002881, 453, 'Paracas pq 4 unid', 1500, 1800, 300, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1622, 7755139002882, 450, 'Trozos de atún Campomar', 2500, 3000, 500, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1623, 7755139002883, 450, 'A1 Filete', 250, 300, 50, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1624, 7755139002884, 448, 'Real Trozos', 2550, 3060, 510, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1625, 7755139002885, 451, 'Durazno 1L laive', 900, 1080, 180, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1626, 7755139002886, 459, 'Fresa 1L Laive', 1900, 2280, 380, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1627, 7755139002887, 450, 'A1 Filete Ligth', 3600, 4320, 720, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1628, 7755139002888, 445, 'Lúcuma 1L Gloria', 5000, 6000, 1000, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1629, 7755139002889, 457, 'Fresa 1L Gloria', 5000, 6000, 1000, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1630, 7755139002890, 449, 'Milkito fresa 1L', 5000, 6000, 1000, 10, 1, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1631, 7755139002891, 455, 'Gloria Durazno 1L', 4000, 4800, 800, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1632, 7755139002892, 449, 'Filete de atún Campomar', 80000, 96000, 16000, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1633, 7755139002893, 449, 'Florida Filete Ligth', 800, 960, 160, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1634, 7755139002894, 449, 'Filete de atún Florida ', 600, 720, 120, 10, 5, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1635, 7755139002895, NULL, 'Inca Kola 1.5L', 5400, 6480, 1080, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1636, 7755139002896, NULL, 'Coca Cola 1.5L', 9800, 11760, 1960, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1637, 7755139002897, 449, 'Red Bull 250ml', 10800, 12960, 2160, 20, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1638, 7755139002898, 453, 'Sprite 3L', 20000, 24000, 4000, 10, 2, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1639, 7755139002899, 453, 'Pepsi 3L', 25000, 30000, 5000, 10, 2, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1640, 7755139002900, 455, 'Laive 200gr', 3500, 4200, 700, 10, 3, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1641, 7755139002901, 457, 'Gloria Pote con sal', 1550, 1860, 310, 10, 2, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1642, 7755139002902, 458, 'Deleite 1L', 1300, 1560, 260, 10, 2, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1643, 7755139002903, 458, 'Sao 1L', 2500, 3000, 500, 10, 1, 0, '2022-04-02 03:02:24', '2022-04-02'),
(1644, 7755139002904, 458, 'Cocinero 1L', 3500, 4200, 700, 10, 1, 0, '2022-04-02 03:02:24', '2022-04-02');

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
(1, 'Santiago Garcia', 'quintiagogarcia04@gmail.com', 'admin', '827ccb0eea8a706c4c34a16891f84e7b', 1, '3197913351', 'carrera 107 bis b # 73-41', 1, 'andii'),
(3, 'Claudia Paola', 'claupa1051@gmail.com', 'cajero', '827ccb0eea8a706c4c34a16891f84e7b', 1, '3197531345', 'Calle 58 sur 22-17', 2, 'Andii'),
(4, 'Juan Camilo', 'jucamoro0505@gmail.com', 'cajero', '827ccb0eea8a706c4c34a16891f84e7b', 1, '3123396044', 'Carrera 8 # 32-30 sur', 3, 'Andii');

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
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `venta_cabecera`
--

INSERT INTO `venta_cabecera` (`id_boleta`, `nro_boleta`, `descripcion`, `subtotal`, `igv`, `total_venta`, `fecha_venta`) VALUES
(46, '00000014', 'Venta realizada con Nro Boleta: 00000014', 0, 0, 69000, '2021-02-19 02:54:10'),
(47, '00000015', 'Venta realizada con Nro Boleta: 00000015', 0, 0, 17500, '2021-02-19 03:34:17'),
(48, '00000016', 'Venta realizada con Nro Boleta: 00000016', 0, 0, 16200, '2021-02-19 03:34:51'),
(49, '00000017', 'Venta realizada con Nro Boleta: 00000017', 0, 0, 5000, '2021-02-19 04:01:17'),
(50, '00000018', 'Venta realizada con Nro Boleta: 00000018', 0, 0, 1800, '2021-02-19 04:56:24'),
(51, '00000019', 'Venta realizada con Nro Boleta: 00000019', 0, 0, 21200, '2021-02-19 07:27:17'),
(52, '00000020', 'Venta realizada con Nro Boleta: 00000020', 0, 0, 29500, '2021-02-19 07:29:41'),
(53, '00000021', 'Venta realizada con Nro Boleta: 00000021', 0, 0, 9200, '2021-02-19 07:31:19'),
(54, '00000022', 'Venta realizada con Nro Boleta: 00000022', 0, 0, 1250, '2021-02-19 07:32:55'),
(55, '00000023', 'Venta realizada con Nro Boleta: 00000023', 0, 0, 1800, '2021-02-25 03:27:16'),
(56, '00000024', 'Venta realizada con Nro Boleta: 00000024', 0, 0, 65800, '2021-02-25 03:27:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

DROP TABLE IF EXISTS `venta_detalle`;
CREATE TABLE IF NOT EXISTS `venta_detalle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nro_boleta` varchar(8) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL,
  `codigo_producto` bigint(20) NOT NULL,
  `cantidad` float NOT NULL,
  `total_venta` float NOT NULL,
  `fecha_venta` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=646 DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id`, `nro_boleta`, `codigo_producto`, `cantidad`, `total_venta`, `fecha_venta`) VALUES
(521, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(522, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(523, '00000016', 7751271021975, 4, 3300, '2022-03-17 20:18:05'),
(528, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(529, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(530, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(531, '00000019', 7750182002363, 10, 7200, '2022-03-17 20:18:18'),
(532, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(533, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(534, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(535, '00000022', 10002, 5, 1250, '2022-03-17 20:18:11'),
(536, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(537, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(538, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(539, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(540, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(541, '00000016', 7750885012928, 1, 800, '2022-03-17 15:00:58'),
(542, '00000016', 7750106002608, 1, 800, '2022-03-17 15:00:58'),
(543, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(544, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(545, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(546, '00000019', 7750182002363, 7, 7200, '2022-03-17 20:18:24'),
(547, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(549, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(550, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(551, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(552, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(553, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(554, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(555, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(556, '00000016', 7750885012928, 1, 800, '2022-03-17 15:00:58'),
(557, '00000016', 7750106002608, 1, 800, '2022-03-17 15:00:58'),
(558, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(559, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(560, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(561, '00000019', 7750182002363, 4, 7200, '2022-03-17 15:00:58'),
(562, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(563, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(564, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(565, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(566, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(567, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(568, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(569, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(570, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(571, '00000016', 7750885012928, 1, 800, '2022-03-17 15:00:58'),
(572, '00000016', 7750106002608, 1, 800, '2022-03-17 15:00:58'),
(573, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(574, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(575, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(576, '00000019', 7750182002363, 4, 7200, '2022-03-17 15:00:58'),
(577, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(578, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(579, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(580, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(581, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(582, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(583, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(584, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(585, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(586, '00000016', 7750885012928, 1, 800, '2022-03-17 15:00:58'),
(587, '00000016', 7750106002608, 1, 800, '2022-03-17 15:00:58'),
(588, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(589, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(590, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(591, '00000019', 7750182002363, 4, 7200, '2022-03-17 15:00:58'),
(592, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(593, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(594, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(595, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(596, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(597, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(598, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(599, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(600, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(602, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(603, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(604, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(605, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(606, '00000019', 7750182002363, 4, 7200, '2022-03-17 15:00:58'),
(607, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(608, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(609, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(610, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(612, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(613, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(614, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(615, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(616, '00000016', 7750885012928, 1, 800, '2022-03-17 15:00:58'),
(617, '00000016', 7750106002608, 1, 800, '2022-03-17 15:00:58'),
(618, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(619, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(620, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(621, '00000019', 7750182002363, 4, 7200, '2022-03-17 15:00:58'),
(622, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(623, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(624, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(625, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(626, '00000014', 7755139002809, 3, 69000, '2022-03-17 15:00:58'),
(627, '00000015', 7754725000281, 5, 17500, '2022-03-17 15:00:58'),
(628, '00000016', 7751271021975, 1, 3300, '2022-03-17 15:00:58'),
(629, '00000016', 7750182006088, 1, 2500, '2022-03-17 15:00:58'),
(630, '00000016', 7750151003902, 1, 8800, '2022-03-17 15:00:58'),
(631, '00000016', 7750885012928, 1, 800, '2022-03-17 15:00:58'),
(632, '00000016', 7750106002608, 1, 800, '2022-03-17 15:00:58'),
(633, '00000017', 7751271027656, 1, 5000, '2022-03-17 15:00:58'),
(634, '00000018', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(635, '00000019', 7754725000281, 4, 14000, '2022-03-17 15:00:58'),
(636, '00000019', 7750182002363, 4, 7200, '2022-03-17 15:00:58'),
(637, '00000020', 7759222002097, 1, 9500, '2022-03-17 15:00:58'),
(638, '00000020', 7755139002809, 1, 20000, '2022-03-17 15:00:58'),
(639, '00000021', 10001, 4, 9200, '2022-03-17 15:00:58'),
(640, '00000022', 10002, 0.25, 1250, '2022-03-17 15:00:58'),
(641, '00000023', 7750182002363, 1, 1800, '2022-03-17 15:00:58'),
(642, '00000024', 10001, 1, 2300, '2022-03-17 15:00:58'),
(643, '00000024', 7501006559019, 1, 3500, '2022-03-17 15:00:58'),
(644, '00000024', 7755139002809, 3, 60000, '2022-03-17 15:00:58'),
(645, '00000025', 7755139002809, 3, 85000, '2022-03-17 15:10:10');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
