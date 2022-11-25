<?php
    //print_r($_POST);
    if(empty($_POST["oculto"]) || empty($_POST["txtNombre"]) || empty($_POST["txtCorreo"]) || empty($_POST["txtUsuario"])){
        header('Location: index.php?mensaje=falta');
        exit();
    }

    include_once 'model/conexion.php';
    $nombre = $_POST["txtNombre"];
    $correo = $_POST["txtCorreo"];
    $usuario = $_POST["txtUsuario"];
    
    $sentencia = $bd->prepare("INSERT INTO usuarios(nombre,correo,usuario) VALUES (?,?,?);");
    $resultado = $sentencia->execute([$nombre,$correo,$usuario]);

    if ($resultado === TRUE) {
        header('Location: index.php?mensaje=registrado');
    } else {
        header('Location: index.php?mensaje=error');
        exit();
    }
    
?>