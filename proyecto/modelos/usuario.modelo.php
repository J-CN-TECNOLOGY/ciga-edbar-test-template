<?php
require_once "conexion.php";

class UsuarioModelo{
//  LOGIN DE USUARIO   
static public function mdlIniciarSeccion($usuario, $password){
    $stmt = conexion::conectar()->prepare  ("select*                       
                                             from usuarios u
                                            inner join perfiles p
                                               on u.id_perfil_usuario = p.id_perfil
                                            inner join perfil_modulo pm
                                                on pm.id_perfil = u.id_perfil_usuario
                                            inner join modulos m
                                                on m.id = pm.id_modulo
                                            where u.usuario = :usuario
                                            and u.clave = :password
                                            and vista_inico = 1");
    $stmt->bindParam(":usuario",$usuario, PDO::PARAM_STR);
    $stmt->bindParam(":password",$password, PDO::PARAM_STR);
    $stmt->execute();
    return $stmt-> fetchAll(PDO::FETCH_CLASS);
    }
}