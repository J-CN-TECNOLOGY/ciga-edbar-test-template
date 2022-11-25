<?php
    session_start();

    include 'conexion.php';

    $correo = $_POST['correo'];
    $contrasena = $_POST['contrasena'];

    $validar_login = mysqli_query($conexion, "SELECT * FROM usuario WHERE correo='$correo'");
    $reg = mysqli_fetch_array($validar_login);


    if (password_verify($contrasena,$reg['contrasena'])) {
        echo '¡La contraseña es válida!';
        if(mysqli_num_rows($validar_login) > 0){
            $_SESSION['usuario'] = $correo;
            header("location: proyecto/index.php");
        }else{
            echo '
                <script>
                    alert("Usuario no existe, por favor verifique los datos introducidos");
                    window.location = "../index.php"
                </script>
            ';
        }
    } else {
        echo '
            <script>
                alert("La contraseña o el correo son incorrectos por favor verifique los datos");
                window.location = "../index.php"
            </script>
        ';
    }
    exit();
    
?>