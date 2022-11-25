<?php
    print_r($_POST);
    if(!isset($_POST['id'])){
        header('Location: index.php?mensaje=error');
    }

    include 'model/conexion.php';
    $id = $_POST['id'];
    $nombre = $_POST['txtNombre'];
    $correo = $_POST['txtCorreo'];
    $usuario = $_POST['txtUsuario'];

    $sentencia = $bd->prepare("UPDATE usuarios SET nombre = ?, correo = ?, usuario = ? where id = ?;");
    $resultado = $sentencia->execute([$nombre, $correo, $usuario, $id]);

    if ($resultado === TRUE) {
        header('Location: index.php?mensaje=editado');
    } else {
        header('Location: index.php?mensaje=error');
        exit();
    }
    
?>